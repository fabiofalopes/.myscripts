#!/bin/bash
# Simple graph visualizer - shows execution flow in ASCII

visualize_graph() {
    local graph_file="$1"
    
    if [ ! -f "$graph_file" ]; then
        echo "Error: Graph file not found: $graph_file"
        return 1
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "                    EXECUTION GRAPH"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Extract strategy
    local strategy=$(jq -r '.strategy' "$graph_file" 2>/dev/null || echo "unknown")
    echo "Strategy: $strategy"
    echo ""
    
    # Show execution order
    echo "Execution Flow:"
    echo ""
    
    local group_num=0
    jq -c '.graph.execution_order[]' "$graph_file" 2>/dev/null | while read -r group; do
        group_num=$((group_num + 1))
        
        echo "┌─ Group $group_num (Parallel) ─────────────────────────────"
        
        # Get nodes in this group
        echo "$group" | jq -r '.[]' | while read -r node_id; do
            # Get node details
            local node=$(jq ".graph.nodes[] | select(.id==\"node-$node_id\")" "$graph_file" 2>/dev/null)
            local pattern=$(echo "$node" | jq -r '.pattern' 2>/dev/null)
            local desc=$(echo "$node" | jq -r '.description' 2>/dev/null)
            
            echo "│  ├─ node-$node_id: $pattern"
            echo "│  │   └─ $desc"
        done
        
        echo "└────────────────────────────────────────────────────────────"
        echo "         ↓"
    done
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
}

# CLI interface
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ -z "$1" ]; then
        echo "Usage: $0 <graph.json>"
        echo ""
        echo "Example: $0 output/run-*/graph.json"
        exit 1
    fi
    
    visualize_graph "$1"
fi
