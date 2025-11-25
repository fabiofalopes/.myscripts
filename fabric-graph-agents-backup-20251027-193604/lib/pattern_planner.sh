#!/bin/bash
# PATTERN GRAPH PLANNER
# Determines optimal pattern execution strategy based on question type

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================================================
# PATTERN KNOWLEDGE BASE
# ============================================================================

# Map question types to pattern strategies
get_pattern_strategy() {
    local question_type="$1"
    
    case "$question_type" in
        security-assessment)
            echo "analyze_risk|ask_secure_by_design_questions|sec-agent"
            ;;
        threat-analysis)
            echo "analyze_threat_report|create_stride_threat_model|extract_insights"
            ;;
        vulnerability-research)
            echo "search_query_generator|deep_search_optimizer"
            ;;
        configuration-validation)
            echo "ask_secure_by_design_questions|analyze_risk|create_report_finding"
            ;;
        wisdom-extraction)
            echo "extract_wisdom|extract_insights|extract_recommendations"
            ;;
        comprehensive-analysis)
            echo "PARALLEL:analyze_risk,analyze_threat_report,ask_secure_by_design_questions|MERGE|sec-agent"
            ;;
        *)
            echo "extract_wisdom|extract_insights"
            ;;
    esac
}

# Classify question type
classify_question() {
    local question="$1"
    
    python3 -c "
import sys

question = '''$question'''.lower()

# Classification logic
if any(word in question for word in ['secure', 'safety', 'protected', 'hardened']):
    if 'how' in question or 'what' in question:
        print('security-assessment')
    else:
        print('configuration-validation')
elif any(word in question for word in ['threat', 'attack', 'exploit', 'vulnerability']):
    if 'research' in question or 'find' in question or 'search' in question:
        print('vulnerability-research')
    else:
        print('threat-analysis')
elif any(word in question for word in ['config', 'setup', 'validate', 'check']):
    print('configuration-validation')
elif any(word in question for word in ['learn', 'understand', 'explain', 'what is']):
    print('wisdom-extraction')
elif any(word in question for word in ['everything', 'complete', 'full', 'comprehensive']):
    print('comprehensive-analysis')
else:
    print('wisdom-extraction')
"
}

# Plan pattern execution graph
plan_pattern_graph() {
    local question="$1"
    local output_format="${2:-bash}"  # bash or json
    
    local question_type=$(classify_question "$question")
    local strategy=$(get_pattern_strategy "$question_type")
    
    if [ "$output_format" = "json" ]; then
        python3 -c "
import json

strategy = '''$strategy'''
question_type = '''$question_type'''

# Parse strategy
steps = []
for step in strategy.split('|'):
    if step.startswith('PARALLEL:'):
        patterns = step.replace('PARALLEL:', '').split(',')
        steps.append({
            'type': 'parallel',
            'patterns': patterns
        })
    elif step == 'MERGE':
        steps.append({
            'type': 'merge',
            'action': 'concatenate'
        })
    else:
        steps.append({
            'type': 'sequential',
            'pattern': step
        })

result = {
    'question_type': question_type,
    'strategy': strategy,
    'execution_plan': steps,
    'estimated_time_seconds': len(steps) * 30  # rough estimate
}

print(json.dumps(result, indent=2))
"
    else
        echo "$strategy"
    fi
}

# Execute pattern graph
execute_pattern_graph() {
    local context_file="$1"
    local strategy="$2"
    local output_dir="$3"
    
    mkdir -p "$output_dir/temp"
    
    local step_num=0
    local current_input="$context_file"
    
    IFS='|' read -ra STEPS <<< "$strategy"
    
    for step in "${STEPS[@]}"; do
        step_num=$((step_num + 1))
        
        if [[ "$step" == PARALLEL:* ]]; then
            # Parallel execution
            local patterns="${step#PARALLEL:}"
            IFS=',' read -ra PATTERN_ARRAY <<< "$patterns"
            
            local pids=()
            for pattern in "${PATTERN_ARRAY[@]}"; do
                cat "$current_input" | fabric -p "$pattern" > "$output_dir/temp/step${step_num}_${pattern}.md" &
                pids+=($!)
            done
            
            # Wait for all parallel jobs
            for pid in "${pids[@]}"; do
                wait "$pid"
            done
            
            # Merge outputs for next step
            cat "$output_dir/temp/step${step_num}"_*.md > "$output_dir/temp/step${step_num}_merged.md"
            current_input="$output_dir/temp/step${step_num}_merged.md"
            
        elif [[ "$step" == "MERGE" ]]; then
            # Already handled in parallel step
            continue
            
        else
            # Sequential execution
            cat "$current_input" | fabric -p "$step" > "$output_dir/temp/step${step_num}_${step}.md"
            current_input="$output_dir/temp/step${step_num}_${step}.md"
        fi
    done
    
    # Final output is the last step
    cat "$current_input"
}

# ============================================================================
# CLI INTERFACE
# ============================================================================

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        classify)
            classify_question "${2:-What is my security posture?}"
            ;;
        plan)
            plan_pattern_graph "${2:-What is my security posture?}" "${3:-bash}"
            ;;
        execute)
            execute_pattern_graph "$2" "$3" "$4"
            ;;
        *)
            echo "Usage: $0 {classify|plan|execute} <question|context_file> [strategy] [output_dir]"
            echo ""
            echo "Examples:"
            echo "  $0 classify 'How secure is my wireless?'"
            echo "  $0 plan 'Find WPA3 vulnerabilities' json"
            echo "  $0 execute context.md 'pattern1|pattern2' output/"
            exit 1
            ;;
    esac
fi
