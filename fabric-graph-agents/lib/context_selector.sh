#!/bin/bash
# INTELLIGENT CONTEXT SELECTOR
# Selects relevant context based on question semantics and domain knowledge

# Source domain knowledge
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ============================================================================
# CORE FUNCTIONS
# ============================================================================

# Analyze question to determine domain and required context
analyze_question() {
    local question="$1"
    local output_format="${2:-json}"  # json or bash
    
    # Use fabric to understand the question
    echo "$question" | fabric -p improve_prompt | \
    python3 -c "
import sys, json, re

question = sys.stdin.read()

# Domain detection patterns
domains = {
    'wireless-security': ['wpa', 'wifi', 'wireless', '802.11', 'ssid', 'ap', 'client', 'radio'],
    'network-segmentation': ['vlan', 'network', 'segmentation', 'firewall', 'zone', 'subnet'],
    'ssh-access': ['ssh', 'dropbear', 'authentication', 'key', 'password', 'login'],
    'monitoring': ['log', 'monitor', 'ids', 'ips', 'suricata', 'zeek', 'alert'],
    'hardware': ['uart', 'u-boot', 'flash', 'hardware', 'physical', 'chip', 'atheros'],
    'threat-modeling': ['threat', 'attack', 'vulnerability', 'exploit', 'risk'],
    'configuration': ['config', 'uci', 'setup', 'install', 'configure']
}

# Detect domains
detected_domains = []
q_lower = question.lower()
for domain, keywords in domains.items():
    if any(kw in q_lower for kw in keywords):
        detected_domains.append(domain)

# If no specific domain, it's comprehensive
if not detected_domains:
    detected_domains = ['comprehensive']

# Determine scope
scope = 'specific' if len(detected_domains) == 1 else 'broad'

# Extract key entities (hardware, software, protocols)
entities = []
entity_patterns = [
    r'(wpa[23]?)',
    r'(802\.11\w*)',
    r'(atheros \w+)',
    r'(ar\d+)',
    r'(openwrt [\d.]+)',
    r'(dropbear)',
    r'(suricata|zeek)',
]
for pattern in entity_patterns:
    matches = re.findall(pattern, q_lower, re.IGNORECASE)
    entities.extend(matches)

result = {
    'domains': detected_domains,
    'scope': scope,
    'entities': list(set(entities)),
    'requires_hardware_context': 'hardware' in detected_domains or any('ar' in e or 'atheros' in e for e in entities),
    'requires_threat_context': 'threat' in q_lower or 'attack' in q_lower or 'secure' in q_lower,
    'requires_config_context': 'config' in q_lower or 'setup' in q_lower or 'how' in q_lower
}

print(json.dumps(result, indent=2))
"
}

# Select relevant files based on domain analysis
select_context_files() {
    local domains="$1"  # comma-separated
    local include_threat_model="${2:-true}"
    local include_hardware="${3:-false}"
    
    local files=()
    
    # Always include if threat modeling needed
    if [ "$include_threat_model" = "true" ]; then
        files+=("$PROJECT_ROOT/context-fabric/ULTRA-CONTEXT - RED-TEAM RENAISSANCE DAY.md")
    fi
    
    # Hardware context
    if [ "$include_hardware" = "true" ]; then
        files+=("$PROJECT_ROOT/context-fabric/airrouter-lab--setup-guide-attack-defense.md")
        files+=("$PROJECT_ROOT/context-fabric/ubiquiti-air-router-openrouter-hardware-capabilities.md")
    fi
    
    # Domain-specific files
    IFS=',' read -ra DOMAIN_ARRAY <<< "$domains"
    for domain in "${DOMAIN_ARRAY[@]}"; do
        case "$domain" in
            wireless-security)
                files+=("$PROJECT_ROOT/security-hardening/03-wireless-hardening.md")
                ;;
            network-segmentation)
                files+=("$PROJECT_ROOT/security-hardening/02-network-segmentation.md")
                ;;
            ssh-access)
                files+=("$PROJECT_ROOT/security-hardening/01-initial-lockdown.md")
                ;;
            monitoring)
                files+=("$PROJECT_ROOT/security-hardening/04-monitoring-logging.md")
                ;;
            comprehensive)
                files+=("$PROJECT_ROOT/security-hardening/00-attack-surface-baseline.md")
                files+=("$PROJECT_ROOT/security-hardening/MASTER-CHECKLIST.md")
                ;;
        esac
    done
    
    # Return unique files
    printf '%s\n' "${files[@]}" | sort -u
}

# Extract relevant sections from files based on keywords
extract_relevant_sections() {
    local file="$1"
    shift
    local keywords=("$@")
    
    if [ ${#keywords[@]} -eq 0 ]; then
        # No keywords, return whole file
        cat "$file"
        return
    fi
    
    # Use awk to extract sections containing keywords
    awk -v keywords="${keywords[*]}" '
    BEGIN {
        split(keywords, kw_array, " ")
        in_relevant_section = 0
        buffer = ""
    }
    /^#/ {
        # New section - check if relevant
        section_header = tolower($0)
        in_relevant_section = 0
        for (i in kw_array) {
            if (index(section_header, tolower(kw_array[i])) > 0) {
                in_relevant_section = 1
                break
            }
        }
        if (in_relevant_section) {
            if (buffer != "") print buffer
            buffer = $0 "\n"
        } else {
            buffer = ""
        }
        next
    }
    {
        if (in_relevant_section) {
            # Check if line contains keywords
            line_lower = tolower($0)
            for (i in kw_array) {
                if (index(line_lower, tolower(kw_array[i])) > 0) {
                    buffer = buffer $0 "\n"
                    next
                }
            }
            # Include context lines
            buffer = buffer $0 "\n"
        }
    }
    END {
        if (buffer != "") print buffer
    }
    ' "$file"
}

# Main context selection function
select_context() {
    local question="$1"
    local max_tokens="${2:-4000}"
    local output_file="${3:-/dev/stdout}"
    
    # Analyze question
    local analysis=$(analyze_question "$question")
    
    # Extract analysis results
    local domains=$(echo "$analysis" | python3 -c "import sys, json; print(','.join(json.load(sys.stdin)['domains']))")
    local entities=$(echo "$analysis" | python3 -c "import sys, json; print(' '.join(json.load(sys.stdin)['entities']))")
    local requires_hardware=$(echo "$analysis" | python3 -c "import sys, json; print(str(json.load(sys.stdin)['requires_hardware_context']).lower())")
    local requires_threat=$(echo "$analysis" | python3 -c "import sys, json; print(str(json.load(sys.stdin)['requires_threat_context']).lower())")
    
    # Select files
    local files=$(select_context_files "$domains" "$requires_threat" "$requires_hardware")
    
    # Build context
    {
        echo "# CONTEXT FOR QUESTION: $question"
        echo ""
        echo "## ANALYSIS"
        echo "$analysis"
        echo ""
        echo "## RELEVANT CONTEXT"
        echo ""
        
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                echo "### Source: $(basename "$file")"
                echo ""
                if [ -n "$entities" ]; then
                    extract_relevant_sections "$file" $entities
                else
                    cat "$file"
                fi
                echo ""
                echo "---"
                echo ""
            fi
        done <<< "$files"
    } > "$output_file"
    
    # Truncate if needed (rough token estimation: 1 token ≈ 4 chars)
    local max_chars=$((max_tokens * 4))
    if [ -f "$output_file" ] && [ "$output_file" != "/dev/stdout" ]; then
        local file_size=$(wc -c < "$output_file")
        if [ "$file_size" -gt "$max_chars" ]; then
            head -c "$max_chars" "$output_file" > "${output_file}.tmp"
            mv "${output_file}.tmp" "$output_file"
            echo "" >> "$output_file"
            echo "[Context truncated to fit token limit]" >> "$output_file"
        fi
    fi
}

# ============================================================================
# CLI INTERFACE
# ============================================================================

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Script is being run directly
    case "${1:-}" in
        analyze)
            analyze_question "${2:-What is my security posture?}"
            ;;
        select)
            select_context "${2:-What is my security posture?}" "${3:-4000}" "${4:-}"
            ;;
        *)
            echo "Usage: $0 {analyze|select} <question> [max_tokens] [output_file]"
            echo ""
            echo "Examples:"
            echo "  $0 analyze 'How secure is my wireless?'"
            echo "  $0 select 'WPA3 vulnerabilities' 3000 context.md"
            exit 1
            ;;
    esac
fi
