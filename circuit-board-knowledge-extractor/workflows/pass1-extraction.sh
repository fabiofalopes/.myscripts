#!/bin/bash

# Exit on error, undefined variables, pipe failures
set -euo pipefail

# Enable extended globbing
shopt -s nullglob

#############################################
# Configuration
#############################################

# Models
readonly VISION_MODEL="${VISION_MODEL:-Groq-Llama-4-Maverick-17B-128E-Instruct}"
readonly TEXT_MODEL="${TEXT_MODEL:-Groq-Llama-3.3-70B-Instruct-Preview-Spec}"

# Processing options
readonly SKIP_EXISTING="${SKIP_EXISTING:-false}"
readonly VERBOSE="${VERBOSE:-true}"
readonly MAX_RETRIES="${MAX_RETRIES:-2}"

# Phase 2 options
readonly ENABLE_CONTEXT="${ENABLE_CONTEXT:-false}"
readonly SESSION_NAME="${SESSION_NAME:-pipeline-$(date +%Y%m%d-%H%M%S)}"

# Patterns
readonly PATTERN_FILENAME="name-file-gen"
readonly PATTERN_TEXT_EXTRACTION="image-text-extraction"
readonly PATTERN_ANALYZE_JSON="analyze-image-json"
readonly PATTERN_OCR_EXPERT="expert-ocr-engine"
readonly PATTERN_OCR_MULTI="multi-scale-ocr"

# Output
readonly PIPELINE_VERSION="1.0.0"
readonly LOG_FILE="pipeline-errors.log"

# Default Output Directory
OUTPUT_DIR="data/pass1"

#############################################
# Logging Functions
#############################################

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

info() {
    log "INFO: $*"
}

warn() {
    log "WARN: $*" >&2
}

error() {
    log "ERROR: $*" >&2
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE"
}

fatal() {
    log "FATAL: $*" >&2
    exit 1
}

debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        log "DEBUG: $*" >&2
    fi
}

#############################################
# Environment Validation
#############################################

validate_environment() {
    info "Validating environment..."
    
    # Check fabric
    if ! command -v fabric >/dev/null 2>&1; then
        fatal "fabric not found."
    fi
    
    # Check jq
    if ! command -v jq >/dev/null 2>&1; then
        fatal "jq not found. Install with: brew install jq"
    fi
    
    info "✅ Environment validated"
}

#############################################
# Image Validation
#############################################

validate_image() {
    local image="$1"
    local output_path="$2"
    
    # File exists?
    if [[ ! -f "$image" ]]; then
        debug "File not found: $image"
        return 1
    fi
    
    # File readable?
    if [[ ! -r "$image" ]]; then
        debug "File not readable: $image"
        return 1
    fi
    
    # Valid extension?
    if [[ ! "$image" =~ \.(jpg|jpeg|png)$ ]]; then
        debug "Not a supported image format: $image"
        return 1
    fi
    
    # Skip if output exists and SKIP_EXISTING=true
    if [[ "$SKIP_EXISTING" == "true" && -f "$output_path" ]]; then
        debug "Output already exists (skipping): $output_path"
        return 2  # Special code for "skip"
    fi
    
    return 0
}

#############################################
# Slug Validation
#############################################

validate_slug() {
    local slug="$1"
    
    # Must match: lowercase letters, numbers, hyphens only
    if [[ -z "$slug" ]]; then
        return 1
    fi
    
    if [[ "$slug" =~ ^[a-z0-9-]+$ ]]; then
        return 0
    fi
    
    return 1
}

sanitize_filename() {
    local filename="${1:-}"
    
    if [[ -z "$filename" ]]; then
        # Read from stdin
        filename=$(cat)
    fi
    
    # Convert to lowercase, replace spaces with hyphens, remove special chars
    echo "$filename" | tr 'A-Z ' 'a-z-' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g'
}

#############################################
# JSON Validation
#############################################

validate_json() {
    local json="$1"
    
    if [[ -z "$json" ]]; then
        return 1
    fi
    
    if echo "$json" | jq empty 2>/dev/null; then
        return 0
    fi
    
    return 1
}

extract_json_from_markdown() {
    local text="$1"
    
    # Try to extract JSON from markdown code blocks
    local extracted
    extracted=$(echo "$text" | sed -n '/```json/,/```/p' | sed '1d;$d')
    
    if [[ -n "$extracted" ]] && validate_json "$extracted"; then
        echo "$extracted"
        return 0
    fi
    
    # Try to find JSON anywhere in text (macOS compatible)
    extracted=$(echo "$text" | grep -o '{.*}' | head -1)
    
    if [[ -n "$extracted" ]] && validate_json "$extracted"; then
        echo "$extracted"
        return 0
    fi
    
    return 1
}

#############################################
# Stage 1: Filename Generation
#############################################

generate_filename() {
    local image="$1"
    
    debug "Stage 1: Generating filename for $image"
    
    # Run fabric pattern
    local candidate
    candidate=$(fabric -a "$image" -p "$PATTERN_FILENAME" -m "$VISION_MODEL" 2>/dev/null | tr -d '\n\r' | xargs)
    
    # Validate slug
    if validate_slug "$candidate"; then
        debug "Generated filename: $candidate"
        echo "$candidate"
        return 0
    fi
    
    # Fallback: sanitize original filename
    warn "Invalid slug generated, using sanitized original: $candidate"
    local fallback
    fallback=$(basename "$image" | sed 's/\.[^.]*$//' | sanitize_filename)
    
    debug "Fallback filename: $fallback"
    echo "$fallback"
}

#############################################
# Stage 2: Text Extraction
#############################################

extract_text() {
    local image="${1:-}"
    
    if [[ -z "$image" ]]; then
        error "extract_text: image parameter is required"
        echo "[No description available]"
        return 1
    fi
    
    debug "Stage 2: Extracting text from $image"
    
    # Run fabric pattern
    local output
    output=$(fabric -a "$image" -p "$PATTERN_TEXT_EXTRACTION" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
    if [[ -z "$output" ]] || [[ ${#output} -lt 20 ]]; then
        warn "Empty or short text extraction for $image"
        echo "[No description available]"
        return 0
    fi
    
    debug "Text extraction complete (${#output} chars)"
    echo "$output"
}

#############################################
# Stage 3: Structured Analysis
#############################################

analyze_image() {
    local image="$1"
    
    debug "Stage 3: Analyzing image structure $image"
    
    local pattern="$PATTERN_ANALYZE_JSON"
    
    # Run fabric pattern
    local raw
    raw=$(fabric -a "$image" -p "$pattern" -m "$VISION_MODEL" 2>&1)
    
    # Check if command failed
    if [[ $? -ne 0 ]]; then
        warn "fabric command failed for $image"
        echo "{}"
        return 0
    fi
    
    # Try to validate JSON
    if validate_json "$raw"; then
        debug "Analysis JSON valid"
        echo "$raw"
        return 0
    fi
    
    # Try to extract JSON from markdown
    local extracted
    if extracted=$(extract_json_from_markdown "$raw"); then
        debug "Extracted JSON from markdown"
        echo "$extracted"
        return 0
    fi
    
    # Fallback to empty object
    warn "Invalid JSON from analyze-image-json for $image"
    debug "Raw output (first 200 chars): ${raw:0:200}"
    echo "{}"
}

#############################################
# Stage 4: Expert OCR
#############################################

run_expert_ocr() {
    local image="$1"
    
    debug "Stage 4: Running expert OCR on $image"
    
    local output
    output=$(fabric -a "$image" -p "$PATTERN_OCR_EXPERT" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
    # Empty is acceptable
    debug "Expert OCR complete (${#output} chars)"
    echo "$output"
}

#############################################
# Stage 5: Multi-Scale OCR
#############################################

run_multi_scale_ocr() {
    local image="$1"
    
    debug "Stage 5: Running multi-scale OCR on $image"
    
    local output
    output=$(fabric -a "$image" -p "$PATTERN_OCR_MULTI" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
    # Empty is acceptable
    debug "Multi-scale OCR complete (${#output} chars)"
    echo "$output"
}

#############################################
# Stage 6: JSON Aggregation
#############################################

aggregate_json() {
    local original_file="$1"
    local generated_name="$2"
    local description="$3"
    local analysis="$4"
    local ocr_expert="$5"
    local ocr_multi="$6"
    
    debug "Stage 6: Aggregating JSON"
    
    # Build JSON using jq
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq -n \
        --arg orig "$original_file" \
        --arg gen "$generated_name" \
        --arg desc "$description" \
        --argjson analysis "$analysis" \
        --arg ocr_expert "$ocr_expert" \
        --arg ocr_multi "$ocr_multi" \
        --arg timestamp "$timestamp" \
        --arg version "$PIPELINE_VERSION" \
        '{
            original_filename: $orig,
            generated_filename: $gen,
            description: $desc,
            analysis: $analysis,
            ocr: {
                expert: $ocr_expert,
                multi_scale: $ocr_multi
            },
            metadata: {
                processed_at: $timestamp,
                pipeline_version: $version,
                models_used: {
                    vision: "'"$VISION_MODEL"'",
                    text: "'"$TEXT_MODEL"'"
                }
            }
        }'
}

#############################################
# Process Single Image
#############################################

process_image() {
    local image="$1"
    local out_dir="$2"
    
    local base_name=$(basename "$image")
    local output_file="${out_dir}/${base_name}.json"
    
    info "Processing: $image -> $output_file"
    
    local start_time
    start_time=$(date +%s)
    
    # Stage 0: Validate image
    validate_image "$image" "$output_file"
    local ret=$?
    
    if [[ $ret -ne 0 ]]; then
        if [[ $ret -eq 2 ]]; then
            info "⏭️  Skipped (already processed): $image"
            return 0
        else
            error "Invalid image: $image"
            return 1
        fi
    fi
    
    # Stage 1: Generate filename
    local generated_filename
    generated_filename=$(generate_filename "$image") || {
        error "Failed to generate filename for $image"
        return 1
    }
    
    # Stage 2: Extract text
    local description
    description=$(extract_text "$image") || {
        error "Failed to extract text from $image"
        return 1
    }
    
    # Stage 3: Analyze image
    local analysis
    analysis=$(analyze_image "$image") || {
        error "Failed to analyze $image"
        return 1
    }
    
    # Ensure analysis is valid JSON (fallback to empty object)
    if ! validate_json "$analysis"; then
        warn "Analysis returned invalid JSON, using empty object"
        analysis="{}"
    fi
    
    # Stage 4: Expert OCR
    local ocr_expert
    ocr_expert=$(run_expert_ocr "$image") || {
        error "Failed to run expert OCR on $image"
        return 1
    }
    
    # Stage 5: Multi-scale OCR
    local ocr_multi
    ocr_multi=$(run_multi_scale_ocr "$image") || {
        error "Failed to run multi-scale OCR on $image"
        return 1
    }
    
    # Stage 6: Aggregate JSON
    local final_json
    final_json=$(aggregate_json "$image" "$generated_filename" "$description" "$analysis" "$ocr_expert" "$ocr_multi") || {
        error "Failed to aggregate JSON for $image"
        return 1
    }
    
    # Validate final JSON
    if ! validate_json "$final_json"; then
        error "Final JSON validation failed for $image"
        debug "Final JSON (first 500 chars): ${final_json:0:500}"
        return 1
    fi
    
    # Write output
    if echo "$final_json" | jq . > "$output_file" 2>/dev/null; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        info "✅ Successfully processed: $image (${duration}s)"
        return 0
    else
        error "Failed to write output for $image"
        return 1
    fi
}

#############################################
# Main
#############################################

main() {
    local target="${1:-}"
    local out_dir="${2:-$OUTPUT_DIR}"
    
    # Initialize log
    > "$LOG_FILE"
    
    info "Pass 1 Extraction Pipeline v${PIPELINE_VERSION}"
    info "═══════════════════════════════════════"
    info "Output Directory: $out_dir"
    
    # Create output directory
    mkdir -p "$out_dir"
    
    # Validate environment
    validate_environment
    
    # Process target
    if [[ -f "$target" ]]; then
        # Single file
        process_image "$target" "$out_dir"
    elif [[ -d "$target" ]]; then
        # Directory
        info "Processing directory: $target"
        
        local images=()
        while IFS= read -r -d '' file; do
            images+=("$file")
        done < <(find "$target" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)
        
        for image in "${images[@]}"; do
            process_image "$image" "$out_dir"
        done
    else
        fatal "Invalid target: $target (must be file or directory)"
    fi
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
