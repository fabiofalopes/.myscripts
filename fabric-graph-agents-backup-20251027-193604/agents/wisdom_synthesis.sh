#!/bin/bash
# Wisdom Synthesis Agent
# Extracts insights and creates strategic action plans from multiple inputs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

source "$LIB_DIR/dimensional.sh"
source "$LIB_DIR/graph.sh"
source "$LIB_DIR/quality.sh"

AGENT_NAME="wisdom_synthesis"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$SCRIPT_DIR/../output/run-$TIMESTAMP-$AGENT_NAME"

mkdir -p "$RUN_DIR"/{input-dimensions,output,logs}

log() {
    echo "[$(date +%H:%M:%S)] $1" | tee -a "$RUN_DIR/logs/agent.log"
}

main() {
    local input_source="$1"
    
    if [ -z "$input_source" ]; then
        echo "Usage: $0 <input_file_or_directory>"
        echo ""
        echo "Examples:"
        echo "  $0 research-notes.md"
        echo "  $0 ./agent-outputs/"
        echo "  $0 'Complex multi-dimensional text input'"
        exit 1
    fi
    
    log "🧠 Wisdom Synthesis Agent starting..."
    log "   Input source: $input_source"
    
    # Step 1: Prepare input
    log "📊 Preparing synthesis input..."
    local combined_input=""
    
    if [ -f "$input_source" ]; then
        # Single file
        log "   Reading file: $input_source"
        combined_input=$(cat "$input_source")
    elif [ -d "$input_source" ]; then
        # Directory - combine all markdown files
        log "   Reading directory: $input_source"
        combined_input=$(find "$input_source" -name "*.md" -type f -exec cat {} \; -exec echo "" \;)
    else
        # Treat as direct text input
        log "   Using direct text input"
        combined_input="$input_source"
    fi
    
    if [ -z "$combined_input" ]; then
        echo "Error: No input content found"
        exit 1
    fi
    
    # Extract dimensions
    local dim_dir=$(extract_dimensions "$combined_input" "$RUN_DIR/input-dimensions")
    local dim_count=$(ls -1 "$dim_dir"/*.md 2>/dev/null | wc -l)
    log "   Dimensions extracted: $dim_count"
    
    # Step 2: Build execution graph for wisdom synthesis
    log "🧠 Planning synthesis strategy..."
    
    local graph=$(cat <<'EOF'
{
  "strategy": "sequential_enrichment",
  "graph": {
    "nodes": [
      {
        "id": "node-1",
        "pattern": "extract_wisdom",
        "input_dimensions": ["all"],
        "parallel_group": 1,
        "description": "Extract core wisdom and principles"
      },
      {
        "id": "node-2",
        "pattern": "extract_insights",
        "input_dimensions": ["node-1"],
        "parallel_group": 2,
        "description": "Identify key insights"
      },
      {
        "id": "node-3",
        "pattern": "extract_recommendations",
        "input_dimensions": ["node-2"],
        "parallel_group": 3,
        "description": "Generate actionable recommendations"
      },
      {
        "id": "node-4",
        "pattern": "improve_prompt",
        "input_dimensions": ["node-3"],
        "parallel_group": 4,
        "description": "Refine for next iteration"
      }
    ],
    "execution_order": [[1], [2], [3], [4]]
  }
}
EOF
)
    
    echo "$graph" > "$RUN_DIR/graph.json"
    
    # Step 3: Execute graph
    log "⚙️  Executing synthesis graph..."
    
    # Load all dimensions
    local all_dims=$(load_dimensions "$dim_dir" "all")
    local temp_input="$RUN_DIR/temp_input.md"
    echo "$all_dims" > "$temp_input"
    
    # Execute node 1: Extract wisdom
    log "   → Extracting wisdom..."
    cat "$temp_input" | fabric -p extract_wisdom > "$RUN_DIR/output/node-1.md" 2>&1 || {
        log "   ⚠️  extract_wisdom failed, using input"
        cp "$temp_input" "$RUN_DIR/output/node-1.md"
    }
    
    # Execute node 2: Extract insights
    log "   → Identifying insights..."
    cat "$RUN_DIR/output/node-1.md" | fabric -p extract_insights > "$RUN_DIR/output/node-2.md" 2>&1 || {
        log "   ⚠️  extract_insights failed, using previous output"
        cp "$RUN_DIR/output/node-1.md" "$RUN_DIR/output/node-2.md"
    }
    
    # Execute node 3: Extract recommendations
    log "   → Generating recommendations..."
    cat "$RUN_DIR/output/node-2.md" | fabric -p extract_recommendations > "$RUN_DIR/output/node-3.md" 2>&1 || {
        log "   ⚠️  extract_recommendations failed, using previous output"
        cp "$RUN_DIR/output/node-2.md" "$RUN_DIR/output/node-3.md"
    }
    
    # Execute node 4: Improve for next iteration
    log "   → Refining for next iteration..."
    cat "$RUN_DIR/output/node-3.md" | fabric -p improve_prompt > "$RUN_DIR/output/node-4.md" 2>&1 || {
        log "   ⚠️  improve_prompt failed, using previous output"
        cp "$RUN_DIR/output/node-3.md" "$RUN_DIR/output/node-4.md"
    }
    
    # Final output is node-4
    cp "$RUN_DIR/output/node-4.md" "$RUN_DIR/output/final.md"
    
    # Step 4: Validate quality
    log "✅ Validating output quality..."
    local quality=$(validate_output "$RUN_DIR/output/final.md" 80 2>/dev/null || echo '{"quality_score": 0, "pass": false}')
    echo "$quality" > "$RUN_DIR/quality.json"
    
    local score=$(echo "$quality" | jq -r '.quality_score' 2>/dev/null || echo "N/A")
    local pass=$(echo "$quality" | jq -r '.pass' 2>/dev/null || echo "false")
    log "   Quality score: $score/100 ($([ "$pass" = "true" ] && echo "PASS" || echo "FAIL"))"
    
    # Step 5: Create strategic summary
    log "📋 Creating strategic summary..."
    cat > "$RUN_DIR/output/strategic-summary.md" <<EOF
# Strategic Summary

**Generated**: $(date)
**Source**: $input_source
**Dimensions Analyzed**: $dim_count

## Key Insights

$(cat "$RUN_DIR/output/node-2.md" | grep -E "^[-*]|^##" | head -10)

## Priority Recommendations

$(cat "$RUN_DIR/output/node-3.md" | grep -E "^[-*]|^\d+\." | head -10)

## Next Steps

$(cat "$RUN_DIR/output/node-4.md" | grep -E "^[-*]|^\d+\." | head -5)

---

See full analysis in: final.md
EOF
    
    # Step 6: Extract action items
    log "✅ Extracting action items..."
    cat "$RUN_DIR/output/node-3.md" | grep -iE "(action|todo|implement|configure|set up|install)" | head -15 > "$RUN_DIR/output/action-items.txt" 2>/dev/null || {
        log "   ⚠️  No action items extracted"
        echo "# Action Items\n\nSee final.md for recommendations." > "$RUN_DIR/output/action-items.txt"
    }
    
    # Step 7: Create metadata
    local end_time=$(date +%s)
    local start_time=$(stat -f %B "$RUN_DIR" 2>/dev/null || stat -c %Y "$RUN_DIR" 2>/dev/null || echo "$end_time")
    local duration=$((end_time - start_time))
    
    cat > "$RUN_DIR/run-metadata.json" <<EOF
{
  "run_id": "run-$TIMESTAMP-$AGENT_NAME",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agent": "$AGENT_NAME",
  "input_source": "$input_source",
  "dimensions_extracted": $dim_count,
  "patterns_executed": ["extract_wisdom", "extract_insights", "extract_recommendations", "improve_prompt"],
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
    echo "                    WISDOM SYNTHESIS"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    cat "$RUN_DIR/output/strategic-summary.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📁 Full output: $RUN_DIR"
    echo "📊 Quality score: $score/100"
    echo "⏱️  Execution time: ${duration}s"
    echo "📋 Strategic summary: $RUN_DIR/output/strategic-summary.md"
    echo "✅ Action items: $RUN_DIR/output/action-items.txt"
    echo ""
}

main "$@"
