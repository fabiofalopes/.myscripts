#!/bin/bash
# Config Validator Agent
# Validates configurations against threat models and security best practices

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

source "$LIB_DIR/dimensional.sh"
source "$LIB_DIR/graph.sh"
source "$LIB_DIR/quality.sh"

AGENT_NAME="config_validator"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RUN_DIR="$SCRIPT_DIR/../output/run-$TIMESTAMP-$AGENT_NAME"

mkdir -p "$RUN_DIR"/{input-dimensions,output,logs}

log() {
    echo "[$(date +%H:%M:%S)] $1" | tee -a "$RUN_DIR/logs/agent.log"
}

main() {
    local config_file="$1"
    local threat_context="${2:-general security}"
    
    if [ -z "$config_file" ]; then
        echo "Usage: $0 <config_file> [threat_context]"
        echo ""
        echo "Example: $0 /etc/config/wireless 'hostile lab environment'"
        echo "Example: $0 firewall.conf"
        exit 1
    fi
    
    if [ ! -f "$config_file" ]; then
        echo "Error: Config file not found: $config_file"
        exit 1
    fi
    
    log "🔒 Config Validator Agent starting..."
    log "   Config file: $config_file"
    log "   Threat context: $threat_context"
    
    # Step 1: Prepare input (config + threat context)
    log "📊 Preparing analysis input..."
    local combined_input=$(cat <<EOF
# Configuration to Validate

File: $config_file

\`\`\`
$(cat "$config_file")
\`\`\`

# Threat Context

$threat_context

# Analysis Required

Validate this configuration against security best practices and the threat context.
Identify vulnerabilities, misconfigurations, and improvement opportunities.
EOF
)
    
    # Extract dimensions from combined input
    local dim_dir=$(extract_dimensions "$combined_input" "$RUN_DIR/input-dimensions")
    local dim_count=$(ls -1 "$dim_dir"/*.md 2>/dev/null | wc -l)
    log "   Dimensions extracted: $dim_count"
    
    # Step 2: Build execution graph for config validation
    log "🧠 Planning validation strategy..."
    
    local graph=$(cat <<'EOF'
{
  "strategy": "sequential_enrichment",
  "graph": {
    "nodes": [
      {
        "id": "node-1",
        "pattern": "ask_secure_by_design_questions",
        "input_dimensions": ["all"],
        "parallel_group": 1,
        "description": "Generate security questions"
      },
      {
        "id": "node-2",
        "pattern": "analyze_risk",
        "input_dimensions": ["node-1"],
        "parallel_group": 2,
        "description": "Assess risk levels"
      },
      {
        "id": "node-3",
        "pattern": "create_report_finding",
        "input_dimensions": ["node-2"],
        "parallel_group": 3,
        "description": "Generate security findings"
      }
    ],
    "execution_order": [[1], [2], [3]]
  }
}
EOF
)
    
    echo "$graph" > "$RUN_DIR/graph.json"
    
    # Step 3: Execute graph
    log "⚙️  Executing validation graph..."
    
    # Load all dimensions
    local all_dims=$(load_dimensions "$dim_dir" "all")
    local temp_input="$RUN_DIR/temp_input.md"
    echo "$all_dims" > "$temp_input"
    
    # Execute node 1: Security questions
    log "   → Generating security questions..."
    cat "$temp_input" | fabric -p ask_secure_by_design_questions > "$RUN_DIR/output/node-1.md" 2>&1 || {
        log "   ⚠️  ask_secure_by_design_questions failed, using input"
        cp "$temp_input" "$RUN_DIR/output/node-1.md"
    }
    
    # Execute node 2: Risk analysis
    log "   → Analyzing risks..."
    cat "$RUN_DIR/output/node-1.md" | fabric -p analyze_risk > "$RUN_DIR/output/node-2.md" 2>&1 || {
        log "   ⚠️  analyze_risk failed, using previous output"
        cp "$RUN_DIR/output/node-1.md" "$RUN_DIR/output/node-2.md"
    }
    
    # Execute node 3: Generate findings
    log "   → Creating security findings..."
    cat "$RUN_DIR/output/node-2.md" | fabric -p create_report_finding > "$RUN_DIR/output/node-3.md" 2>&1 || {
        log "   ⚠️  create_report_finding failed, using previous output"
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
    
    # Step 5: Extract critical findings
    log "⚠️  Extracting critical findings..."
    cat "$RUN_DIR/output/final.md" | grep -iE "(critical|high|severe|vulnerability|risk)" | head -10 > "$RUN_DIR/output/critical-findings.txt" 2>/dev/null || {
        log "   ⚠️  No critical findings extracted"
        echo "# Critical Findings\n\nSee final.md for complete analysis." > "$RUN_DIR/output/critical-findings.txt"
    }
    
    # Step 6: Generate remediation checklist
    log "📋 Generating remediation checklist..."
    cat "$RUN_DIR/output/final.md" | fabric -p extract_recommendations > "$RUN_DIR/output/remediation-checklist.md" 2>&1 || {
        log "   ⚠️  Failed to generate checklist"
        echo "# Remediation Checklist\n\nSee final.md for recommendations." > "$RUN_DIR/output/remediation-checklist.md"
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
  "config_file": "$config_file",
  "threat_context": "$threat_context",
  "dimensions_extracted": $dim_count,
  "patterns_executed": ["ask_secure_by_design_questions", "analyze_risk", "create_report_finding"],
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
    echo "                  CONFIGURATION VALIDATION"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    cat "$RUN_DIR/output/final.md"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    echo "📁 Full output: $RUN_DIR"
    echo "📊 Quality score: $score/100"
    echo "⏱️  Execution time: ${duration}s"
    echo "⚠️  Critical findings: $RUN_DIR/output/critical-findings.txt"
    echo "📋 Remediation: $RUN_DIR/output/remediation-checklist.md"
    echo ""
}

main "$@"
