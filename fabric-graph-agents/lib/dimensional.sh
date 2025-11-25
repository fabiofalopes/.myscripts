#!/bin/bash
# Dimensional input processing orchestration
# Extracts, validates, and manages semantic dimensions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extract dimensions from raw input with quality validation
extract_dimensions() {
    local input="$1"
    local output_dir="$2"
    local max_retries="${3:-2}"
    
    mkdir -p "$output_dir"
    
    local attempt=0
    local extraction=""
    local validation=""
    local action="refine"
    
    while [ "$action" = "refine" ] && [ $attempt -lt $max_retries ]; do
        attempt=$((attempt + 1))
        
        # Run dimension extractor
        if [ $attempt -eq 1 ]; then
            extraction=$(echo "$input" | fabric-ai -p dimension_extractor_ultra)
        else
            # Include refinement guidance
            local suggestions=$(echo "$validation" | jq -r '.suggestions[]' 2>/dev/null || echo "")
            local refined_input="$input\n\nREFINEMENT GUIDANCE:\n$suggestions"
            extraction=$(echo -e "$refined_input" | fabric-ai -p dimension_extractor_ultra)
        fi
        
        # Validate extraction
        validation=$(echo "$extraction" | fabric-ai --pattern validate_extraction)
        action=$(echo "$validation" | jq -r '.action' 2>/dev/null || echo "accept")
        
        if [ "$action" = "accept" ]; then
            break
        fi
    done
    
    # Parse JSON and save dimensions
    local kb_name=$(echo "$extraction" | jq -r '.kb_name' 2>/dev/null || echo "kb-$(date +%Y-%m-%d)-extraction")
    local dim_count=$(echo "$extraction" | jq '.dimensions | length' 2>/dev/null || echo "0")
    
    if [ "$dim_count" -gt 0 ]; then
        # Save each dimension
        echo "$extraction" | jq -r '.dimensions[] | "\(.filename)|\(.content)"' | \
        while IFS='|' read -r filename content; do
            echo "$content" > "$output_dir/$filename"
        done
        
        # Save metadata
        echo "$extraction" | jq '.' > "$output_dir/_metadata.json" 2>/dev/null || \
            echo '{"error": "Failed to parse JSON"}' > "$output_dir/_metadata.json"
        
        # Save validation results
        echo "$validation" | jq '.' > "$output_dir/_validation.json" 2>/dev/null || \
            echo '{"error": "Failed to parse validation"}' > "$output_dir/_validation.json"
    else
        # Fallback: save raw extraction
        echo "$extraction" > "$output_dir/raw_extraction.txt"
        echo '{"error": "No dimensions extracted", "raw_saved": true}' > "$output_dir/_metadata.json"
    fi
    
    echo "$output_dir"
}

# Load dimensions from directory
load_dimensions() {
    local dim_dir="$1"
    local filter="${2:-all}"  # all, technical, cognitive, affective
    
    if [ ! -d "$dim_dir" ]; then
        echo "Error: Directory $dim_dir not found" >&2
        return 1
    fi
    
    if [ "$filter" = "all" ]; then
        # Load all markdown files except metadata
        find "$dim_dir" -name "*.md" -type f -exec cat {} \; -exec echo "" \;
    else
        # Filter by type using metadata
        if [ -f "$dim_dir/_metadata.json" ]; then
            jq -r ".dimensions[] | select(.type==\"$filter\") | .filename" \
                "$dim_dir/_metadata.json" 2>/dev/null | \
            while read -r filename; do
                if [ -f "$dim_dir/$filename" ]; then
                    cat "$dim_dir/$filename"
                    echo ""
                fi
            done
        else
            echo "Error: No metadata file found" >&2
            return 1
        fi
    fi
}

# Get dimension by ID
get_dimension() {
    local dim_dir="$1"
    local dim_id="$2"
    
    if [ ! -f "$dim_dir/_metadata.json" ]; then
        echo "Error: No metadata file found" >&2
        return 1
    fi
    
    local filename=$(jq -r ".dimensions[] | select(.id==\"$dim_id\") | .filename" \
        "$dim_dir/_metadata.json" 2>/dev/null)
    
    if [ -n "$filename" ] && [ -f "$dim_dir/$filename" ]; then
        cat "$dim_dir/$filename"
    else
        echo "Error: Dimension $dim_id not found" >&2
        return 1
    fi
}

# Get dimension metadata
get_dimension_metadata() {
    local dim_dir="$1"
    local dim_id="${2:-}"
    
    if [ ! -f "$dim_dir/_metadata.json" ]; then
        echo "Error: No metadata file found" >&2
        return 1
    fi
    
    if [ -z "$dim_id" ]; then
        # Return all metadata
        cat "$dim_dir/_metadata.json"
    else
        # Return specific dimension metadata
        jq ".dimensions[] | select(.id==\"$dim_id\")" "$dim_dir/_metadata.json" 2>/dev/null
    fi
}

# List all dimensions
list_dimensions() {
    local dim_dir="$1"
    local format="${2:-simple}"  # simple, detailed, json
    
    if [ ! -f "$dim_dir/_metadata.json" ]; then
        echo "Error: No metadata file found" >&2
        return 1
    fi
    
    case "$format" in
        simple)
            jq -r '.dimensions[] | "\(.id): \(.filename)"' "$dim_dir/_metadata.json" 2>/dev/null
            ;;
        detailed)
            jq -r '.dimensions[] | "\(.id): \(.filename) [\(.type), \(.weight)] - \(.keywords | join(", "))"' \
                "$dim_dir/_metadata.json" 2>/dev/null
            ;;
        json)
            jq '.dimensions' "$dim_dir/_metadata.json" 2>/dev/null
            ;;
        *)
            echo "Error: Unknown format $format" >&2
            return 1
            ;;
    esac
}

# Get quality score
get_quality_score() {
    local dim_dir="$1"
    
    if [ -f "$dim_dir/_validation.json" ]; then
        jq -r '.quality_score' "$dim_dir/_validation.json" 2>/dev/null || echo "N/A"
    elif [ -f "$dim_dir/_metadata.json" ]; then
        jq -r '.quality_score' "$dim_dir/_metadata.json" 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

# CLI interface
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        extract)
            extract_dimensions "${2:-}" "${3:-./dimensions}" "${4:-2}"
            ;;
        load)
            load_dimensions "${2:-.}" "${3:-all}"
            ;;
        get)
            get_dimension "${2:-.}" "${3:-dim-001}"
            ;;
        list)
            list_dimensions "${2:-.}" "${3:-simple}"
            ;;
        metadata)
            get_dimension_metadata "${2:-.}" "${3:-}"
            ;;
        quality)
            get_quality_score "${2:-.}"
            ;;
        *)
            echo "Usage: $0 {extract|load|get|list|metadata|quality} [args...]"
            echo ""
            echo "Commands:"
            echo "  extract <input> <output_dir> [max_retries]  - Extract dimensions from input"
            echo "  load <dim_dir> [filter]                     - Load dimensions (filter: all|technical|cognitive|affective)"
            echo "  get <dim_dir> <dim_id>                      - Get specific dimension"
            echo "  list <dim_dir> [format]                     - List dimensions (format: simple|detailed|json)"
            echo "  metadata <dim_dir> [dim_id]                 - Get metadata"
            echo "  quality <dim_dir>                           - Get quality score"
            exit 1
            ;;
    esac
fi
