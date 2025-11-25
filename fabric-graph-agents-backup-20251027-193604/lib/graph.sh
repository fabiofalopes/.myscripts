#!/bin/bash
# Pattern graph execution engine
# Executes fabric patterns in optimal graphs with parallel processing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/dimensional.sh"

# Execute complete pattern graph
execute_graph() {
    local graph_json="$1"
    local input_dir="$2"
    local output_dir="$3"
    
    mkdir -p "$output_dir/temp" "$output_dir/logs"
    
    local start_time=$(date +%s)
    
    # Log graph execution start
    echo "[$(date +%H:%M:%S)] Starting graph execution" | tee -a "$output_dir/logs/graph.log"
    echo "$graph_json" | jq '.' > "$output_dir/graph.json" 2>/dev/null || \
        echo "$graph_json" > "$output_dir/graph.json"
    
    # Get execution order
    local group_num=0
    echo "$graph_json" | jq -c '.graph.execution_order[]' 2>/dev/null | while read -r group; do
        group_num=$((group_num + 1))
        
        echo "[$(date +%H:%M:%S)] Executing parallel group $group_num" | tee -a "$output_dir/logs/graph.log"
        
        # Execute nodes in parallel
        local pids=()
        echo "$group" | jq -r '.[]' 2>/dev/null | while read -r node_id; do
            execute_node "$graph_json" "$node_id" "$input_dir" "$output_dir" &
            pids+=($!)
        done
        
        # Wait for parallel group to complete
        for pid in "${pids[@]}"; do
            wait "$pid" 2>/dev/null || true
        done
        
        echo "[$(date +%H:%M:%S)] Group $group_num complete" | tee -a "$output_dir/logs/graph.log"
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "[$(date +%H:%M:%S)] Graph execution complete in ${duration}s" | tee -a "$output_dir/logs/graph.log"
    
    # Find final output (last node)
    local final_node=$(echo "$graph_json" | jq -r '.graph.execution_order[-1][-1]' 2>/dev/null || echo "")
    if [ -n "$final_node" ] && [ -f "$output_dir/temp/${final_node}.md" ]; then
        cp "$output_dir/temp/${final_node}.md" "$output_dir/final.md"
    fi
}

# Execute single node
execute_node() {
    local graph_json="$1"
    local node_id="$2"
    local input_dir="$3"
    local output_dir="$4"
    
    local node_start=$(date +%s)
    
    # Get node details
    local node=$(echo "$graph_json" | jq ".graph.nodes[] | select(.id==\"$node_id\")" 2>/dev/null)
    
    if [ -z "$node" ] || [ "$node" = "null" ]; then
        echo "[$(date +%H:%M:%S)] Error: Node $node_id not found" | tee -a "$output_dir/logs/graph.log"
        return 1
    fi
    
    local pattern=$(echo "$node" | jq -r '.pattern' 2>/dev/null)
    local description=$(echo "$node" | jq -r '.description' 2>/dev/null || echo "")
    
    echo "[$(date +%H:%M:%S)] Executing $node_id: $pattern - $description" | tee -a "$output_dir/logs/graph.log"
    
    # Build input from dimensions or previous nodes
    local input_content=""
    local input_dims=$(echo "$node" | jq -r '.input_dimensions[]' 2>/dev/null)
    
    for dim in $input_dims; do
        if [[ "$dim" == dim-* ]]; then
            # Dimension ID - load from input directory
            local dim_content=$(get_dimension "$input_dir" "$dim" 2>/dev/null || echo "")
            if [ -n "$dim_content" ]; then
                input_content+="$dim_content"
                input_content+="\n\n---\n\n"
            fi
        elif [[ "$dim" == node-* ]]; then
            # Previous node output
            if [ -f "$output_dir/temp/${dim}.md" ]; then
                input_content+=$(cat "$output_dir/temp/${dim}.md")
                input_content+="\n\n---\n\n"
            fi
        fi
    done
    
    # Execute pattern
    if [ -n "$input_content" ]; then
        echo -e "$input_content" | fabric -p "$pattern" > "$output_dir/temp/${node_id}.md" 2>&1 || {
            echo "[$(date +%H:%M:%S)] Error executing $node_id" | tee -a "$output_dir/logs/graph.log"
            echo "Error executing pattern $pattern" > "$output_dir/temp/${node_id}.md"
        }
    else
        echo "[$(date +%H:%M:%S)] Warning: No input for $node_id" | tee -a "$output_dir/logs/graph.log"
        echo "No input provided" > "$output_dir/temp/${node_id}.md"
    fi
    
    local node_end=$(date +%s)
    local node_duration=$((node_end - node_start))
    
    echo "[$(date +%H:%M:%S)] Node $node_id complete in ${node_duration}s" | tee -a "$output_dir/logs/graph.log"
}

# Plan and execute graph from dimensions
plan_and_execute() {
    local dim_dir="$1"
    local goal="$2"
    local depth="${3:-normal}"
    local output_dir="$4"
    
    mkdir -p "$output_dir"
    
    echo "[$(date +%H:%M:%S)] Planning execution graph..." | tee -a "$output_dir/logs/graph.log"
    
    # Load dimensions metadata
    local dimensions=$(get_dimension_metadata "$dim_dir")
    
    # Create planning input
    local planning_input=$(cat <<EOF
{
  "dimensions": $dimensions,
  "goal": "$goal",
  "depth": "$depth"
}
EOF
)
    
    # Plan graph
    local graph=$(echo "$planning_input" | fabric -p plan_pattern_graph 2>/dev/null || echo '{"error": "Planning failed"}')
    
    echo "[$(date +%H:%M:%S)] Graph planned, executing..." | tee -a "$output_dir/logs/graph.log"
    
    # Execute graph
    execute_graph "$graph" "$dim_dir" "$output_dir"
}

# Merge outputs from parallel nodes
merge_outputs() {
    local output_dir="$1"
    shift
    local node_ids=("$@")
    local merged_file="$output_dir/temp/merged.md"
    
    > "$merged_file"  # Clear file
    
    for node_id in "${node_ids[@]}"; do
        if [ -f "$output_dir/temp/${node_id}.md" ]; then
            echo "# Output from $node_id" >> "$merged_file"
            echo "" >> "$merged_file"
            cat "$output_dir/temp/${node_id}.md" >> "$merged_file"
            echo "" >> "$merged_file"
            echo "---" >> "$merged_file"
            echo "" >> "$merged_file"
        fi
    done
    
    echo "$merged_file"
}

# Get graph execution statistics
get_graph_stats() {
    local output_dir="$1"
    
    if [ ! -f "$output_dir/logs/graph.log" ]; then
        echo "No execution log found"
        return 1
    fi
    
    local total_time=$(grep "complete in" "$output_dir/logs/graph.log" | tail -1 | grep -oE '[0-9]+s' | tr -d 's')
    local node_count=$(find "$output_dir/temp" -name "node-*.md" -type f | wc -l)
    local errors=$(grep -c "Error" "$output_dir/logs/graph.log" 2>/dev/null || echo "0")
    
    cat <<EOF
{
  "total_time_seconds": ${total_time:-0},
  "nodes_executed": $node_count,
  "errors": $errors,
  "output_files": $(find "$output_dir/temp" -name "*.md" -type f | wc -l)
}
EOF
}

# CLI interface
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        execute)
            execute_graph "${2:-}" "${3:-.}" "${4:-./output}"
            ;;
        node)
            execute_node "${2:-}" "${3:-node-1}" "${4:-.}" "${5:-./output}"
            ;;
        plan-execute)
            plan_and_execute "${2:-.}" "${3:-answer security question}" "${4:-normal}" "${5:-./output}"
            ;;
        merge)
            shift
            output_dir="$1"
            shift
            merge_outputs "$output_dir" "$@"
            ;;
        stats)
            get_graph_stats "${2:-./output}"
            ;;
        *)
            echo "Usage: $0 {execute|node|plan-execute|merge|stats} [args...]"
            echo ""
            echo "Commands:"
            echo "  execute <graph_json> <input_dir> <output_dir>           - Execute complete graph"
            echo "  node <graph_json> <node_id> <input_dir> <output_dir>    - Execute single node"
            echo "  plan-execute <dim_dir> <goal> [depth] <output_dir>      - Plan and execute"
            echo "  merge <output_dir> <node_id1> <node_id2> ...            - Merge node outputs"
            echo "  stats <output_dir>                                      - Get execution stats"
            exit 1
            ;;
    esac
fi
