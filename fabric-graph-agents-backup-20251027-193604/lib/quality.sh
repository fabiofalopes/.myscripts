#!/bin/bash
# Output quality validation
# Scores outputs on actionability, specificity, completeness, and structure

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate output quality
validate_output() {
    local output_file="$1"
    local threshold="${2:-80}"
    
    if [ ! -f "$output_file" ]; then
        echo '{"error": "File not found", "quality_score": 0, "pass": false}'
        return 1
    fi
    
    # Use Python for quality analysis
    python3 <<EOF
import sys
import json
import re

def check_actionable(text):
    """Check for action verbs, specific steps, clear recommendations"""
    action_indicators = [
        'configure', 'set', 'enable', 'disable', 'install', 'run', 'check',
        'verify', 'test', 'update', 'modify', 'add', 'remove', 'create',
        'uci set', 'uci add', 'uci commit', 'opkg install'
    ]
    
    text_lower = text.lower()
    matches = sum(1 for word in action_indicators if word in text_lower)
    
    # Check for numbered steps or bullet points
    has_steps = bool(re.search(r'^\d+\.', text, re.MULTILINE))
    has_bullets = text.count('-') >= 5 or text.count('*') >= 5
    
    score = min(100, (matches * 8) + (has_steps * 20) + (has_bullets * 15))
    return score

def check_specific(text):
    """Check for specific details vs generic advice"""
    generic_phrases = [
        'best practices', 'it depends', 'generally', 'usually', 'typically',
        'consider', 'might want to', 'you should probably', 'it\'s recommended'
    ]
    
    specific_indicators = [
        r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}',  # IP addresses
        r'wpa[23]', r'802\.11\w*',  # Protocols
        r'uci (set|add|delete|commit)',  # Commands
        r'fabric -p \w+',  # Fabric commands
        r'/etc/\w+',  # File paths
        r'port \d+',  # Port numbers
    ]
    
    text_lower = text.lower()
    generic_count = sum(1 for phrase in generic_phrases if phrase in text_lower)
    specific_count = sum(1 for pattern in specific_indicators if re.search(pattern, text, re.IGNORECASE))
    
    # Penalize generic, reward specific
    score = max(0, min(100, (specific_count * 12) - (generic_count * 8) + 40))
    return score

def check_complete(text):
    """Check if output addresses all aspects comprehensively"""
    word_count = len(text.split())
    
    # Check for multiple sections
    section_count = text.count('#')
    
    # Check for examples
    has_examples = '```' in text or 'example:' in text.lower()
    
    # Completeness based on length and structure
    length_score = min(60, word_count / 10)  # Up to 600 words = 60 points
    structure_score = min(25, section_count * 5)  # Up to 5 sections = 25 points
    example_score = 15 if has_examples else 0
    
    score = length_score + structure_score + example_score
    return min(100, score)

def check_structured(text):
    """Check for clear structure (headers, lists, sections)"""
    has_headers = text.count('#') >= 2
    has_lists = text.count('-') >= 5 or text.count('*') >= 5
    has_code = '```' in text
    has_sections = text.count('##') >= 2
    
    score = (
        (has_headers * 30) +
        (has_lists * 25) +
        (has_code * 25) +
        (has_sections * 20)
    )
    return min(100, score)

def identify_issues(text, scores):
    """Identify specific quality problems"""
    issues = []
    
    if scores["actionable"] < 70:
        issues.append("Output lacks actionable recommendations with specific steps")
    if scores["specific"] < 70:
        issues.append("Output is too generic, needs specific technical details")
    if scores["complete"] < 70:
        issues.append("Output seems incomplete or too brief")
    if scores["structured"] < 70:
        issues.append("Output lacks clear structure with headers and sections")
    
    # Check for common problems
    if 'TODO' in text or 'TBD' in text:
        issues.append("Contains placeholder text (TODO/TBD)")
    if len(text.split()) < 100:
        issues.append("Output is very short (< 100 words)")
    if text.count('#') == 0:
        issues.append("No headers or sections found")
    
    return issues

# Read file
try:
    with open("$output_file", 'r') as f:
        content = f.read()
except Exception as e:
    print(json.dumps({"error": str(e), "quality_score": 0, "pass": false}))
    sys.exit(1)

# Calculate scores
scores = {
    "actionable": check_actionable(content),
    "specific": check_specific(content),
    "complete": check_complete(content),
    "structured": check_structured(content)
}

overall = sum(scores.values()) / len(scores)
issues = identify_issues(content, scores)

result = {
    "quality_score": round(overall, 1),
    "scores": scores,
    "pass": overall >= $threshold,
    "threshold": $threshold,
    "issues": issues,
    "word_count": len(content.split()),
    "has_code_examples": '```' in content,
    "section_count": content.count('#')
}

print(json.dumps(result, indent=2))
EOF
}

# Quick quality check (pass/fail only)
quick_check() {
    local output_file="$1"
    local threshold="${2:-80}"
    
    local result=$(validate_output "$output_file" "$threshold")
    local pass=$(echo "$result" | jq -r '.pass' 2>/dev/null || echo "false")
    
    if [ "$pass" = "true" ]; then
        echo "PASS"
        return 0
    else
        echo "FAIL"
        return 1
    fi
}

# Get quality score only
get_score() {
    local output_file="$1"
    
    local result=$(validate_output "$output_file" 80)
    echo "$result" | jq -r '.quality_score' 2>/dev/null || echo "0"
}

# Get issues only
get_issues() {
    local output_file="$1"
    
    local result=$(validate_output "$output_file" 80)
    echo "$result" | jq -r '.issues[]' 2>/dev/null || echo "No issues data"
}

# Validate multiple files
validate_batch() {
    local output_dir="$1"
    local threshold="${2:-80}"
    
    local results="["
    local first=true
    
    find "$output_dir" -name "*.md" -type f | while read -r file; do
        if [ "$first" = true ]; then
            first=false
        else
            results+=","
        fi
        
        local result=$(validate_output "$file" "$threshold")
        local filename=$(basename "$file")
        
        results+=$(cat <<EOF
{
  "file": "$filename",
  "validation": $result
}
EOF
)
    done
    
    results+="]"
    echo "$results" | jq '.'
}

# Generate quality report
generate_report() {
    local output_dir="$1"
    local report_file="${2:-$output_dir/quality-report.md}"
    
    {
        echo "# Quality Validation Report"
        echo ""
        echo "Generated: $(date)"
        echo ""
        echo "## Summary"
        echo ""
        
        local total=0
        local passed=0
        local total_score=0
        
        find "$output_dir" -name "*.md" -type f | while read -r file; do
            local result=$(validate_output "$file" 80)
            local score=$(echo "$result" | jq -r '.quality_score')
            local pass=$(echo "$result" | jq -r '.pass')
            
            total=$((total + 1))
            total_score=$(echo "$total_score + $score" | bc)
            
            if [ "$pass" = "true" ]; then
                passed=$((passed + 1))
            fi
            
            echo "### $(basename "$file")"
            echo ""
            echo "- **Score**: $score/100"
            echo "- **Status**: $([ "$pass" = "true" ] && echo "✅ PASS" || echo "❌ FAIL")"
            echo ""
            
            local issues=$(echo "$result" | jq -r '.issues[]' 2>/dev/null)
            if [ -n "$issues" ]; then
                echo "**Issues**:"
                echo "$issues" | while read -r issue; do
                    echo "- $issue"
                done
                echo ""
            fi
        done
        
        if [ $total -gt 0 ]; then
            local avg_score=$(echo "scale=1; $total_score / $total" | bc)
            local pass_rate=$(echo "scale=1; $passed * 100 / $total" | bc)
            
            echo ""
            echo "## Overall Statistics"
            echo ""
            echo "- **Total Files**: $total"
            echo "- **Passed**: $passed"
            echo "- **Failed**: $((total - passed))"
            echo "- **Pass Rate**: ${pass_rate}%"
            echo "- **Average Score**: ${avg_score}/100"
        fi
    } > "$report_file"
    
    echo "$report_file"
}

# CLI interface
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        validate)
            validate_output "${2:-}" "${3:-80}"
            ;;
        check)
            quick_check "${2:-}" "${3:-80}"
            ;;
        score)
            get_score "${2:-}"
            ;;
        issues)
            get_issues "${2:-}"
            ;;
        batch)
            validate_batch "${2:-.}" "${3:-80}"
            ;;
        report)
            generate_report "${2:-.}" "${3:-}"
            ;;
        *)
            echo "Usage: $0 {validate|check|score|issues|batch|report} [args...]"
            echo ""
            echo "Commands:"
            echo "  validate <file> [threshold]        - Full validation with details"
            echo "  check <file> [threshold]           - Quick pass/fail check"
            echo "  score <file>                       - Get quality score only"
            echo "  issues <file>                      - Get issues only"
            echo "  batch <dir> [threshold]            - Validate all files in directory"
            echo "  report <dir> [output_file]         - Generate quality report"
            exit 1
            ;;
    esac
fi
