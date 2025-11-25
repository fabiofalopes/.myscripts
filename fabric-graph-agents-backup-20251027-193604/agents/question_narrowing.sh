#!/bin/bash
# Question Narrowing Agent
# Helps users ask better, more specific questions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

source "$LIB_DIR/dimensional.sh"
source "$LIB_DIR/graph.sh"
source "$LIB_DIR/quality.sh"

AGENT_NAME="question_narrowing"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$SCRIPT_DIR/../output/run-$TIMESTAMP-$AGENT_NAME"

mkdir -p "$RUN_DIR"/{input-dimensions,output,logs}

log() {
    echo "[$(date +%H:%M:%S)] $1" | tee -a "$RUN_DIR/logs/agent.log"
}

main() {
    local input="$1"
    
    if [ -z "$input" ]; then
        echo "Usage: $0 '<vague question>'"
        echo ""
        echo "Example: $0 'How secure am I?'"
        exit 1
    fi
    
    log "🤖 Question Narrowing Agent starting..."
    log "   Input: $input"
    
    # Step 1: Dimensionalize input
    log "📊 Extracting dimensions..."
    local dim_dir=$(extract_dimensions "$input" "$RUN_DIR/input-dimensions")
    local dim_count=$(ls -1 "$dim_dir"/*.md 2>/dev/null | wc -l)
    log "   Dimensions extracted: $dim_count"
    
    # Step 2: Build execution graph manually (optimized for question narrowing)
    log "🧠 Planning execution strategy..."
    
    local graph=$(cat <<'EOF'
{
  "strategy": "sequential_enrichment",
  "graph": {
    "nodes": [
      {
        "id": "node-1",
        "pattern": "extract_questions",
        "input_dimensions": ["all"],
        "parallel_group": 1,
        "description": "Extract implicit questions from vague input"
      },
      {
        "id": "node-2",
        "pattern": "improve_prompt",
        "input_dimensions": ["node-1"],
        "parallel_group": 2,
        "description": "Refine questions for clarity"
      },
      {
        "id": "node-3",
        "pattern": "ask_secure_by_design_questions",
        "input_dimensions": ["node-2"],
        "parallel_group": 3,
        "description": "Generate specific security questions"
      }
    ],
    "execution_order": [[1], [2], [3]]
  }
}
EOF
)
    
    echo "$graph" > "$RUN_DIR/graph.json"
    
    # Step 3: Execute graph with all dimensions as input
    log "⚙️  Executing pattern graph..."
    
    # Load all dimensions into single input
    local all_dims=$(load_dimensions "$dim_dir" "all")
    local temp_input="$RUN_DIR/temp_input.md"
    echo "$all_dims" > "$temp_input"
    
    # Execute node 1
    log "   → Extracting questions..."
    cat "$temp_input" | fabric -p extract_questions > "$RUN_DIR/output/node-1.md" 2>&1 || {
        log "   ⚠️  extract_questions failed, using fallback"
        echo "$all_dims" > "$RUN_DIR/output/node-1.md"
    }
    
    # Execute node 2
    log "   → Improving prompts..."
    cat "$RUN_DIR/output/node-1.md" | fabric -p improve_prompt > "$RUN_DIR/output/node-2.md" 2>&1 || {
        log "   ⚠️  improve_prompt failed, using previous output"
        cp "$RUN_DIR/output/node-1.md" "$RUN_DIR/output/node-2.md"
    }
    
    # Execute node 3
    log "   → Generating security questions..."
    cat "$RUN_DIR/output/node-2.md" | fabric -p ask_secure_by_design_questions > "$RUN_DIR/output/node-3.md" 2>&1 || {
        log "   ⚠️  ask_secure_by_design_questions failed, using previous output"
        cp "$RUN_DIR/output/node-2.md" "$RUN_DIR/output/node-3.md"
    }
    
    # Final output is node-3
    cp "$RUN_DIR/output/node-3.md" "$RUN_DIR/output/final.md"
    
    # Step 4: Validate quality
    log "✅ Validating output quality..."
    local quality=$(validate_output "$RUN_DIR/output/final.md" 70 2>/dev/null || echo '{"quality_score": 0, "pass": false}')
    echo "$quality" > "$RUN_DIR/quality.json"
    
    local score=$(echo "$quality" | jq -r '.quality_score' 2>/dev/null || echo "N/A")
    local pass=$(echo "$quality" | jq -r '.pass' 2>/dev/null || echo "false")
    log "   Quality score: $score/100 ($([ "$pass" = "true" ] && echo "PASS" || echo "FAIL"))"
    
    # Step 5: Generate follow-up questions
    log "❓ Generating follow-up questions..."
    cat "$RUN_DIR/output/final.md" | fabric -p extract_questions > "$RUN_DIR/output/follow-up-questions.md" 2>&1 || {
        log "   ⚠️  Failed to generate follow-ups"
        echo "# Follow-up Questions\n\nNo additional questions generated." > "$RUN_DIR/output/follow-up-questions.md"
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
  "patterns_executed": ["extract_questions", "improve_prompt", "ask_secure_by_design_questions"],
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
    echo "                    NARROWED QUESTIONS"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    cat "$RUN_DIR/output/final.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📁 Full output: $RUN_DIR"
    echo "📊 Quality score: $score/100"
    echo "⏱️  Execution time: ${duration}s"
    echo ""
}

main "$@"
