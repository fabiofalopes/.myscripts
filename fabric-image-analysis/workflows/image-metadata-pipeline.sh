#!/bin/bash

# Exit on error, undefined variables, pipe failures
set -euo pipefail

# Enable extended globbing
shopt -s nullglob

#############################################
# Configuration
#############################################

# Models
readonly VISION_MODEL="${VISION_MODEL:-meta-llama/llama-4-maverick-17b-128e-instruct}"
readonly TEXT_MODEL="${TEXT_MODEL:-llama-3.3-70b-versatile}"

# Processing options
readonly SKIP_EXISTING="${SKIP_EXISTING:-false}"
readonly VERBOSE="${VERBOSE:-false}"
readonly MAX_RETRIES="${MAX_RETRIES:-2}"

# Phase 2 options
readonly ENABLE_CONTEXT="${ENABLE_CONTEXT:-false}"
readonly SESSION_NAME="${SESSION_NAME:-pipeline-$(date +%Y%m%d-%H%M%S)}"
readonly KEEP_SESSION="${KEEP_SESSION:-false}"

# Patterns
readonly PATTERN_FILENAME="name-file-gen"
readonly PATTERN_TEXT_EXTRACTION="image-text-extraction"
readonly PATTERN_ANALYZE_JSON="analyze-image-json"
readonly PATTERN_OCR_EXPERT="expert-ocr-engine"
readonly PATTERN_OCR_MULTI="multi-scale-ocr"
readonly PATTERN_JSON_PARSER="json-parser"

# Output
readonly PIPELINE_VERSION="1.0.0"
readonly LOG_FILE="pipeline-errors.log"

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
    
    # Check fabric-ai
    if ! command -v fabric-ai >/dev/null 2>&1; then
        fatal "fabric-ai not found. Install with: brew install fabric-ai"
    fi
    
    # Check jq
    if ! command -v jq >/dev/null 2>&1; then
        fatal "jq not found. Install with: brew install jq"
    fi
    
    # Test fabric-ai connectivity
    if ! echo "test" | fabric-ai -p "$PATTERN_FILENAME" >/dev/null 2>&1; then
        fatal "Cannot connect to fabric-ai. Check API configuration in ~/.config/fabric/.env"
    fi
    
    info "✅ Environment validated"
}

#############################################
# Image Validation
#############################################

validate_image() {
    local image="$1"
    
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
    if [[ "$SKIP_EXISTING" == "true" && -f "${image}.json" ]]; then
        debug "Output already exists (skipping): $image"
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
    local filename="$1"
    
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
# Phase 2: Context Management (Manual Injection)
#############################################

# Global context accumulator
ACCUMULATED_CONTEXT=""
IMAGE_COUNT=0

add_to_context() {
    local new_context="$1"
    
    if [[ -z "$new_context" ]]; then
        return 0
    fi
    
    # Add to accumulated context
    if [[ -z "$ACCUMULATED_CONTEXT" ]]; then
        ACCUMULATED_CONTEXT="$new_context"
    else
        ACCUMULATED_CONTEXT="$ACCUMULATED_CONTEXT $new_context"
    fi
    
    # Trim context if too large (keep last 500 chars)
    if [[ ${#ACCUMULATED_CONTEXT} -gt 500 ]]; then
        ACCUMULATED_CONTEXT="${ACCUMULATED_CONTEXT: -500}"
        debug "Context trimmed to 500 chars"
    fi
    
    ((IMAGE_COUNT++))
    debug "Context updated (image $IMAGE_COUNT): ${ACCUMULATED_CONTEXT:0:100}..."
}

get_context_for_prompt() {
    if [[ -z "$ACCUMULATED_CONTEXT" ]]; then
        echo "No prior context available. This is the first image in the batch."
    else
        echo "Previous images in this batch showed: $ACCUMULATED_CONTEXT"
    fi
}

extract_context() {
    local json="$1"
    
    # Extract key entities from JSON for context building
    local context=""
    
    # Extract equipment/model info
    local equipment=$(echo "$json" | jq -r '.analysis.technical_details.identifiers.model_numbers[]? // empty' 2>/dev/null | head -3 | tr '\n' ', ')
    if [[ -n "$equipment" ]]; then
        context+="Models: ${equipment%, }. "
    fi
    
    # Extract serial number patterns (not full serials for privacy)
    local serial_count=$(echo "$json" | jq -r '.analysis.technical_details.identifiers.serial_numbers | length' 2>/dev/null)
    if [[ "$serial_count" -gt 0 ]]; then
        context+="Has $serial_count serial number(s). "
    fi
    
    # Extract main objects
    local objects=$(echo "$json" | jq -r '.analysis.objects[]? // empty' 2>/dev/null | head -3 | tr '\n' ', ')
    if [[ -n "$objects" ]]; then
        context+="Components: ${objects%, }. "
    fi
    
    # Extract device type
    local device_type=$(echo "$json" | jq -r '.analysis.technical_details.specifications // empty' 2>/dev/null | head -c 50)
    if [[ -n "$device_type" ]]; then
        context+="Type: $device_type. "
    fi
    
    echo "$context"
}

init_session() {
    if [[ "$ENABLE_CONTEXT" == "true" ]]; then
        info "Context-aware mode enabled (manual injection)"
        ACCUMULATED_CONTEXT=""
        IMAGE_COUNT=0
        return 0
    fi
}

cleanup_session() {
    if [[ "$ENABLE_CONTEXT" == "true" ]]; then
        info "Processed $IMAGE_COUNT images with context"
    fi
}

#############################################
# Stage 1: Filename Generation
#############################################

generate_filename() {
    local image="$1"
    
    debug "Stage 1: Generating filename for $image"
    
    # Run fabric pattern (no session for vision models)
    local candidate
    candidate=$(fabric-ai -a "$image" -p "$PATTERN_FILENAME" -m "$VISION_MODEL" 2>/dev/null | tr -d '\n\r' | xargs)
    
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
    
    # Run fabric pattern (no session for vision models)
    local output
    output=$(fabric-ai -a "$image" -p "$PATTERN_TEXT_EXTRACTION" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
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
    
    # Choose pattern based on context mode
    local pattern="$PATTERN_ANALYZE_JSON"
    
    # Run fabric pattern with optional context
    local raw
    if [[ "$ENABLE_CONTEXT" == "true" ]]; then
        pattern="analyze-image-json-with-context"
        local context_text=$(get_context_for_prompt)
        debug "Using context: ${context_text:0:100}..."
        raw=$(fabric-ai -a "$image" -p "$pattern" -m "$VISION_MODEL" -v="#context:$context_text" 2>&1)
    else
        raw=$(fabric-ai -a "$image" -p "$pattern" -m "$VISION_MODEL" 2>&1)
    fi
    
    # Check if command failed
    if [[ $? -ne 0 ]]; then
        warn "fabric-ai command failed for $image"
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
    output=$(fabric-ai -a "$image" -p "$PATTERN_OCR_EXPERT" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
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
    output=$(fabric-ai -a "$image" -p "$PATTERN_OCR_MULTI" -m "$VISION_MODEL" 2>/dev/null || echo "")
    
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
    
    info "Processing: $image"
    
    local start_time
    start_time=$(date +%s)
    
    # Stage 0: Validate image
    if ! validate_image "$image"; then
        local ret=$?
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
    local output_file="${image}.json"
    if echo "$final_json" | jq . > "$output_file" 2>/dev/null; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        info "✅ Successfully processed: $image (${duration}s)"
        
        # Extract and add context for next image if context is enabled
        if [[ "$ENABLE_CONTEXT" == "true" ]]; then
            local context_info
            context_info=$(extract_context "$final_json")
            if [[ -n "$context_info" ]]; then
                add_to_context "$context_info"
                debug "Added to context: $context_info"
            fi
        fi
        
        return 0
    else
        error "Failed to write output for $image"
        return 1
    fi
}

#############################################
# Process Directory (Batch)
#############################################

process_directory() {
    local dir="$1"
    
    info "Starting batch processing in: $dir"
    
    # Initialize session if context is enabled
    init_session
    
    # Find all images
    local images=()
    while IFS= read -r -d '' file; do
        images+=("$file")
    done < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -print0)
    
    local total=${#images[@]}
    
    if [[ $total -eq 0 ]]; then
        warn "No images found in $dir"
        cleanup_session
        return 0
    fi
    
    info "Found $total images to process"
    if [[ "$ENABLE_CONTEXT" == "true" ]]; then
        info "Context-aware mode: ENABLED (session: $SESSION_NAME)"
    fi
    
    local success=0
    local failed=0
    local skipped=0
    
    for image in "${images[@]}"; do
        if process_image "$image"; then
            ((success++))
        else
            ((failed++))
        fi
    done
    
    # Cleanup session
    cleanup_session
    
    # Summary
    info "═══════════════════════════════════════"
    info "Batch processing complete"
    info "  Total:   $total"
    info "  Success: $success"
    info "  Failed:  $failed"
    info "═══════════════════════════════════════"
    
    if [[ $failed -gt 0 ]]; then
        warn "See $LOG_FILE for error details"
        return 1
    fi
    
    return 0
}

#############################################
# Main
#############################################

main() {
    # Parse arguments
    local target="${1:-.}"
    
    # Initialize log
    > "$LOG_FILE"
    
    info "Image Metadata Pipeline v${PIPELINE_VERSION}"
    info "═══════════════════════════════════════"
    
    # Validate environment
    validate_environment
    
    # Process target
    if [[ -f "$target" ]]; then
        # Single file
        process_image "$target"
    elif [[ -d "$target" ]]; then
        # Directory
        process_directory "$target"
    else
        fatal "Invalid target: $target (must be file or directory)"
    fi
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi