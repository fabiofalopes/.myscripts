#!/bin/bash
# Threat Intelligence Agent
# Generates optimized search queries for security research

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

source "$LIB_DIR/dimensional.sh"
source "$LIB_DIR/graph.sh"
source "$LIB_DIR/quality.sh"

AGENT_NAME="threat_intelligence"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$SCRIPT_DIR/../output/run-$TIMESTAMP-$AGENT_NAME"

mkdir -p "$RUN_DIR"/{input-dimensions,output,logs}

log() {
    echo "[$(date +%H:%M:%S)] $1" | tee -a "$RUN_DIR/logs/agent.log"
}

main() {
    local input="$1"
    
    if [ -z "$input" ]; then
        echo "Usage: $0 '<security topic or threat>'"
        echo ""
        echo "Example: $0 'WPA3 vulnerabilities on Atheros chipsets'"
        exit 1
    fi
    
    log "🔍 Threat Intelligence Agent starting..."
    log "   Input: $input"
    
    # Step 1: Dimensionalize input
    log "📊 Extracting dimensions..."
    local dim_dir=$(extract_dimensions "$input" "$RUN_DIR/input-dimensions")
    local dim_count=$(ls -1 "$dim_dir"/*.md 2>/dev/null | wc -l)
    log "   Dimensions extracted: $dim_count"
    
    # Step 2: Build execution graph for threat intelligence
    log "🧠 Planning threat intelligence strategy..."
    
    local graph=$(cat <<'EOF'
{
  "strategy": "sequential_enrichment",
  "graph": {
    "nodes": [
      {
        "id": "node-1",
        "pattern": "analyze_threat_report",
        "input_dimensions": ["all"],
        "parallel_group": 1,
        "description": "Analyze threat landscape"
      },
      {
        "id": "node-2",
        "pattern": "search_query_generator",
        "input_dimensions": ["node-1"],
        "parallel_group": 2,
        "description": "Generate search queries"
      },
      {
        "id": "node-3",
        "pattern": "deep_search_optimizer",
        "input_dimensions": ["node-2"],
        "parallel_group": 3,
        "description": "Optimize and prioritize queries"
      },
      {
        "id": "node-4",
        "pattern": "search_refiner",
        "input_dimensions": ["node-3"],
        "parallel_group": 4,
        "description": "Refine for specific databases"
      }
    ],
    "execution_order": [[1], [2], [3], [4]]
  }
}
EOF
)
    
    echo "$graph" > "$RUN_DIR/graph.json"
    
    # Step 3: Execute graph
    log "⚙️  Executing pattern graph..."
    
    # Load all dimensions
    local all_dims=$(load_dimensions "$dim_dir" "all")
    local temp_input="$RUN_DIR/temp_input.md"
    echo "$all_dims" > "$temp_input"
    
    # Execute node 1: Analyze threat
    log "   → Analyzing threat landscape..."
    cat "$temp_input" | fabric -p analyze_threat_report > "$RUN_DIR/output/node-1.md" 2>&1 || {
        log "   ⚠️  analyze_threat_report failed, using input"
        cp "$temp_input" "$RUN_DIR/output/node-1.md"
    }
    
    # Execute node 2: Generate queries
    log "   → Generating search queries..."
    cat "$RUN_DIR/output/node-1.md" | fabric -p search_query_generator > "$RUN_DIR/output/node-2.md" 2>&1 || {
        log "   ⚠️  search_query_generator failed, using previous output"
        cp "$RUN_DIR/output/node-1.md" "$RUN_DIR/output/node-2.md"
    }
    
    # Execute node 3: Optimize queries
    log "   → Optimizing search queries..."
    cat "$RUN_DIR/output/node-2.md" | fabric -p deep_search_optimizer > "$RUN_DIR/output/node-3.md" 2>&1 || {
        log "   ⚠️  deep_search_optimizer failed, using previous output"
        cp "$RUN_DIR/output/node-2.md" "$RUN_DIR/output/node-3.md"
    }
    
    # Execute node 4: Refine queries
    log "   → Refining for specific databases..."
    cat "$RUN_DIR/output/node-3.md" | fabric -p search_refiner > "$RUN_DIR/output/node-4.md" 2>&1 || {
        log "   ⚠️  search_refiner failed, using previous output"
        cp "$RUN_DIR/output/node-3.md" "$RUN_DIR/output/node-4.md"
    }
    
    # Final output is node-4
    cp "$RUN_DIR/output/node-4.md" "$RUN_DIR/output/final.md"
    
    # Step 4: Validate quality
    log "✅ Validating output quality..."
    local quality=$(validate_output "$RUN_DIR/output/final.md" 70 2>/dev/null || echo '{"quality_score": 0, "pass": false}')
    echo "$quality" > "$RUN_DIR/quality.json"
    
    local score=$(echo "$quality" | jq -r '.quality_score' 2>/dev/null || echo "N/A")
    local pass=$(echo "$quality" | jq -r '.pass' 2>/dev/null || echo "false")
    log "   Quality score: $score/100 ($([ "$pass" = "true" ] && echo "PASS" || echo "FAIL"))"
    
    # Step 5: Extract key queries
    log "🔎 Extracting prioritized queries..."
    cat "$RUN_DIR/output/final.md" | grep -E "^[-*]|^\d+\." | head -20 > "$RUN_DIR/output/key-queries.txt" 2>/dev/null || {
        log "   ⚠️  Failed to extract queries"
        echo "# Key Queries\n\nSee final.md for complete output." > "$RUN_DIR/output/key-queries.txt"
    }
    
    # Step 6: Create metadata
    local end_time=$(date +%s)
    local start_time=$(stat -f %B "$RUN_DIR" 2>/dev/null || stat -c %Y "$RUN_DIR" 2>/dev/null || echo "$end_time")
    local duration=$((end_time - start_time))
    
    cat > "$RUN_DIR/run-metadata.json" <<EOF
{
  "run_id": "run-$TIMESTAMP-$AGENT_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "$AGENT_NAME",
  "input": "$input",
  "dimensions_extracted": $dim_count,
  "patterns_executed": ["analyze_threat_report", "search_query_generator", "deep_search_optimizer", "search_refiner"],
  "execution_time_seconds": $duration,
  "quality_score": $score,
  "output_location": "$RUN_DIR/output/final.md"
}
EOF
    
    log "✅ Complete! Output: $RUN_DIR/output/final.md"
    log ""
    
    # Display output
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "                  THREAT INTELLIGENCE QUERIES"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    cat "$RUN_DIR/output/final.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📁 Full output: $RUN_DIR"
    echo "📊 Quality score: $score/100"
    echo "⏱️  Execution time: ${duration}s"
    echo "🔎 Key queries: $RUN_DIR/output/key-queries.txt"
    echo ""
}

main "$@"
