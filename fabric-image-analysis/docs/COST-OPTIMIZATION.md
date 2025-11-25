# Cost Optimization Strategy

**Purpose**: Reduce API costs while maintaining or improving quality  
**Target**: 40-50% cost reduction vs Phase 1  
**Principle**: Use the right model for the right task

---

## Table of Contents
1. [Current Costs (Phase 1)](#current-costs-phase-1)
2. [Available Models](#available-models)
3. [Model Selection Strategy](#model-selection-strategy)
4. [Cost Reduction Techniques](#cost-reduction-techniques)
5. [Implementation](#implementation)
6. [Measurement & Tracking](#measurement--tracking)

---

## Current Costs (Phase 1)

### Model Usage
| Stage | Pattern | Model | Type | Notes |
|-------|---------|-------|------|-------|
| 1. Filename | `name-file-gen` | `llama-4-maverick-17b-128e` | Vision | Fixed: was using text model |
| 2. Description | `image-text-extraction` | `llama-4-maverick-17b-128e` | Vision | Primary vision task |
| 3. Analysis | `analyze-image-json` | `llama-4-maverick-17b-128e` | Vision | Detailed analysis |
| 4. Expert OCR | `expert-ocr-engine` | `llama-4-maverick-17b-128e` | Vision | OCR extraction |
| 5. Multi-scale OCR | `multi-scale-ocr` | `llama-4-maverick-17b-128e` | Vision | OCR at scales |
| 6. Aggregation | `json-parser` | `llama-3.3-70b-versatile` | Text | JSON building |

### Cost Profile
- **Vision calls**: 5 per image (Stages 1-5)
- **Text calls**: 1 per image (Stage 6)
- **Expensive**: `llama-4-maverick-17b-128e` used heavily
- **Processing time**: ~13-21 seconds per image

### Cost Drivers
1. **Vision model overuse** - Using detailed model for all vision tasks
2. **No task differentiation** - Simple and complex tasks use same model
3. **No context reuse** - Re-learning domain context each image
4. **Redundant processing** - Some stages may not be needed for all images

---

## Available Models

### Vision Models (Groq)

#### llama-4-maverick-17b-128e-instruct ⚠️ EXPENSIVE
- **Capabilities**: Vision input, detailed analysis, high-quality OCR
- **Context**: 128K tokens (extended context)
- **Best for**: Complex analysis, detailed OCR, structured outputs
- **Cost**: Higher tier
- **Current use**: All vision stages (1-5)

#### llama-4-scout-17b-16e-instruct 💰 CHEAPER
- **Capabilities**: Vision input, basic analysis, standard OCR
- **Context**: 16K tokens (standard context)
- **Best for**: Simple descriptions, basic OCR, quick analysis
- **Cost**: Lower tier (~30-40% cheaper estimated)
- **Potential use**: Stages 1, 2, 4

### Text Models (Groq)

#### llama-3.3-70b-versatile 💰 MEDIUM COST
- **Capabilities**: Strong text processing, JSON generation
- **Context**: Large context window
- **Best for**: Complex text tasks, JSON aggregation
- **Cost**: Medium tier
- **Current use**: Stage 6 (aggregation)

#### qwen/qwen3-32b 💎 BEST VALUE
- **Capabilities**: Strong reasoning, good at structured output
- **Context**: Good context window
- **Best for**: Validation, reasoning, complex text tasks
- **Cost**: Lower cost, excellent quality/price ratio
- **Potential use**: Validation, context building, KB analysis

### Local Models (Ollama) 🆓 FREE

#### deepseek-r1:8b
- **Capabilities**: Reasoning, text processing
- **Context**: Standard
- **Best for**: Non-critical tasks, testing, offline work
- **Cost**: Free (runs locally)
- **Potential use**: Development, testing, optional fallback

---

## Model Selection Strategy

### Vision Task Classification

#### Tier 1: Simple Vision Tasks 💰 USE CHEAPER MODEL
**Use**: `llama-4-scout-17b-16e`

**Tasks**:
- **Stage 1**: Filename generation (semantic understanding)
- **Stage 2**: Basic description (what's in the image)
- **Stage 4**: Expert OCR (if image is simple/clean)

**Rationale**:
- These tasks don't require extended context
- Quality difference is minimal for straightforward images
- Cost savings: ~30-40% per call

**Quality Check**:
```bash
# A/B test outputs
OUTPUT_CHEAP=$(fabric-ai -a image.jpg -p name-file-gen -m llama-4-scout-17b-16e)
OUTPUT_DETAILED=$(fabric-ai -a image.jpg -p name-file-gen -m llama-4-maverick-17b-128e)

# Compare quality manually
# If cheap model is 90%+ as good → use it
```

---

#### Tier 2: Complex Vision Tasks 🎯 USE DETAILED MODEL
**Use**: `llama-4-maverick-17b-128e`

**Tasks**:
- **Stage 3**: Structured analysis (needs detailed understanding)
- **Stage 5**: Multi-scale OCR (complex, multi-resolution)
- **High-accuracy mode**: All OCR tasks (when enabled)

**Rationale**:
- These tasks benefit from extended context
- Require deep scene understanding
- Quality is critical here

**No compromise**: Keep using best model for these

---

### Text Task Classification

#### Tier 1: Simple Text Tasks 💰 USE VERSATILE MODEL
**Use**: `llama-3.3-70b-versatile`

**Tasks**:
- **Stage 6**: JSON aggregation (current)
- Simple text transformations

**Rationale**:
- Fast, reliable for structured outputs
- Current usage is appropriate

---

#### Tier 2: Reasoning Tasks 💎 USE QWEN
**Use**: `qwen/qwen3-32b`

**Tasks**:
- KB file selection (needs reasoning)
- Context summarization
- OCR validation (cross-referencing)
- Consistency checking
- Error correction

**Rationale**:
- Excellent reasoning capabilities
- Cheaper than llama-3.3-70b
- Better at complex logic tasks

**Example**:
```bash
# Instead of:
fabric-ai -p validate-ocr -m llama-3.3-70b-versatile

# Use:
fabric-ai -p validate-ocr -m qwen/qwen3-32b --strategy=cot
```

---

#### Tier 3: Non-Critical Tasks 🆓 USE LOCAL (Optional)
**Use**: `deepseek-r1:8b` (Ollama)

**Tasks**:
- Development testing
- Non-critical validation
- Offline work

**Rationale**:
- Free (runs locally)
- Good for iteration without API costs
- Optional - only if Ollama installed

---

## Cost Reduction Techniques

### 1. Adaptive Model Selection 💡

**Concept**: Choose model based on task complexity

```bash
# Detect image complexity
assess_image_complexity() {
    local image="$1"
    
    # Simple heuristics:
    # - File size (smaller = simpler)
    # - Quick vision check (how much text/detail)
    
    local filesize=$(stat -f%z "$image")
    
    if [[ $filesize -lt 1000000 ]]; then
        echo "simple"
    else
        echo "complex"
    fi
}

# Select model accordingly
select_vision_model() {
    local complexity="$1"
    local stage="$2"
    
    if [[ "$stage" == "analysis" ]]; then
        # Always use detailed for analysis
        echo "$VISION_MODEL_DETAILED"
    elif [[ "$complexity" == "simple" ]]; then
        echo "$VISION_MODEL_QUICK"
    else
        echo "$VISION_MODEL_DETAILED"
    fi
}
```

**Savings**: 20-30% on vision costs

---

### 2. Context Reuse 💡

**Concept**: Don't re-explain domain context for each image

**Phase 1** (wasteful):
```
Image 1: "Analyze this circuit board..." → Full analysis
Image 2: "Analyze this circuit board..." → Full analysis (relearning)
Image 3: "Analyze this circuit board..." → Full analysis (relearning)
```

**Phase 2** (efficient):
```
Image 1: "Analyze this circuit board..." → Full analysis + extract context
Image 2: "This is image 2 of Ubiquiti router series [context]" → Faster
Image 3: "This is image 3, you've seen [context]" → Faster
```

**Implementation**: Use Fabric sessions
```bash
# Maintain session across batch
fabric-ai -a image.jpg \
    --session="batch-2025-10-21" \
    -p analyze-image-json
```

**Savings**: 10-20% through reduced token usage and faster inference

---

### 3. Selective Stage Execution 💡

**Concept**: Not all images need all stages

```bash
# Quick image assessment
assess_image_needs() {
    local image="$1"
    
    # Quick check: Is there visible text?
    local has_text=$(fabric-ai -a "$image" \
        -p quick-text-check \
        -m llama-4-scout-17b-16e)
    
    if [[ "$has_text" == "no" ]]; then
        # Skip OCR stages entirely
        echo "skip_ocr"
    else
        echo "full_pipeline"
    fi
}

process_image() {
    local image="$1"
    local needs=$(assess_image_needs "$image")
    
    # Always: Stages 1-3
    generate_filename "$image"
    extract_text "$image"
    analyze_image "$image"
    
    # Conditionally: Stages 4-5
    if [[ "$needs" != "skip_ocr" ]]; then
        run_expert_ocr "$image"
        run_multi_scale_ocr "$image"
    fi
    
    # Always: Stage 6
    aggregate_json "$image"
}
```

**Savings**: 20-40% for images without text (saves 2 vision calls)

---

### 4. Batch Context Optimization 💡

**Concept**: Process similar images together, reuse KB context

```bash
# Group images by similarity
group_images() {
    # Images of same equipment type benefit from shared context
    # Could use filename patterns, metadata, or quick classification
}

# Process groups with shared context
process_group() {
    local group_context="$1"
    shift
    local images=("$@")
    
    # Load KB context once
    load_kb_context "$group_context"
    
    # Process all with same context
    for image in "${images[@]}"; do
        process_image_with_context "$image" "$group_context"
    done
}
```

**Savings**: 5-15% through context amortization

---

### 5. Local Model Fallback 💡

**Concept**: Use free local models for non-critical tasks

```bash
# Check if Ollama is available
if command -v ollama >/dev/null; then
    LOCAL_AVAILABLE=true
    LOCAL_MODEL="deepseek-r1:8b"
fi

# Use for testing/development
test_pattern() {
    if [[ "$LOCAL_AVAILABLE" == "true" ]]; then
        # Use local model for testing
        fabric-ai -V Ollama -m "$LOCAL_MODEL" -p "$pattern"
    else
        # Fall back to cloud
        fabric-ai -m "$TEXT_MODEL_SIMPLE" -p "$pattern"
    fi
}
```

**Savings**: Variable, mainly for development iteration

---

## Implementation

### Configuration Variables

```bash
#############################################
# Model Configuration - Phase 2
#############################################

# Vision Models
readonly VISION_MODEL_DETAILED="${VISION_MODEL_DETAILED:-meta-llama/llama-4-maverick-17b-128e-instruct}"
readonly VISION_MODEL_QUICK="${VISION_MODEL_QUICK:-meta-llama/llama-4-scout-17b-16e-instruct}"

# Text Models
readonly TEXT_MODEL_SIMPLE="${TEXT_MODEL_SIMPLE:-llama-3.3-70b-versatile}"
readonly TEXT_MODEL_REASONING="${TEXT_MODEL_REASONING:-qwen/qwen3-32b}"

# Local Models (optional)
readonly LOCAL_MODEL="${LOCAL_MODEL:-deepseek-r1:8b}"
readonly LOCAL_AVAILABLE=$(command -v ollama >/dev/null && echo "true" || echo "false")

# Cost Optimization Flags
readonly COST_OPTIMIZE="${COST_OPTIMIZE:-false}"
readonly SKIP_OCR_WHEN_NO_TEXT="${SKIP_OCR_WHEN_NO_TEXT:-true}"
readonly USE_ADAPTIVE_MODELS="${USE_ADAPTIVE_MODELS:-true}"
```

### Model Selection Functions

```bash
#############################################
# Adaptive Model Selection
#############################################

select_vision_model_for_stage() {
    local stage="$1"
    local complexity="${2:-medium}"  # simple, medium, complex
    
    # Cost optimization disabled? Use best models
    if [[ "$COST_OPTIMIZE" != "true" ]]; then
        echo "$VISION_MODEL_DETAILED"
        return
    fi
    
    case "$stage" in
        "filename"|"description")
            # Simple tasks can use quick model
            if [[ "$complexity" == "simple" || "$USE_ADAPTIVE_MODELS" == "true" ]]; then
                echo "$VISION_MODEL_QUICK"
            else
                echo "$VISION_MODEL_DETAILED"
            fi
            ;;
        "analysis"|"multi-scale-ocr")
            # Always use detailed for complex tasks
            echo "$VISION_MODEL_DETAILED"
            ;;
        "expert-ocr")
            # OCR can use quick for simple images
            if [[ "$complexity" == "simple" ]]; then
                echo "$VISION_MODEL_QUICK"
            else
                echo "$VISION_MODEL_DETAILED"
            fi
            ;;
        *)
            # Default to detailed
            echo "$VISION_MODEL_DETAILED"
            ;;
    esac
}

select_text_model_for_task() {
    local task="$1"
    
    case "$task" in
        "validation"|"reasoning"|"kb-selection"|"context-summary")
            # Use reasoning model for complex tasks
            echo "$TEXT_MODEL_REASONING"
            ;;
        "simple"|"json-aggregation"|"filename")
            # Use simple model for straightforward tasks
            echo "$TEXT_MODEL_SIMPLE"
            ;;
        *)
            # Default
            echo "$TEXT_MODEL_SIMPLE"
            ;;
    esac
}
```

### Updated Processing Functions

```bash
generate_filename() {
    local image="$1"
    local complexity="${2:-simple}"
    
    debug "Stage 1: Generating filename for $image"
    
    # Select model based on optimization settings
    local model=$(select_vision_model_for_stage "filename" "$complexity")
    
    debug "Using model: $model"
    
    local candidate
    candidate=$(fabric-ai -a "$image" -p "$PATTERN_FILENAME" -m "$model" 2>/dev/null | tr -d '\n\r' | xargs)
    
    if validate_slug "$candidate"; then
        debug "Generated filename: $candidate"
        echo "$candidate"
        return 0
    fi
    
    warn "Invalid slug generated, using sanitized original: $candidate"
    local fallback
    fallback=$(basename "$image" | sed 's/\.[^.]*$//' | sanitize_filename)
    
    debug "Fallback filename: $fallback"
    echo "$fallback"
}

# Similar updates for other stages...
```

### Cost Tracking

```bash
#############################################
# Cost Tracking
#############################################

declare -A MODEL_USAGE_COUNT
declare -A MODEL_USAGE_TOKENS

track_model_usage() {
    local model="$1"
    local tokens="${2:-0}"
    
    # Increment call count
    ((MODEL_USAGE_COUNT["$model"]++))
    
    # Add tokens
    ((MODEL_USAGE_TOKENS["$model"]+=$tokens))
}

report_costs() {
    info "═══════════════════════════════════════"
    info "Model Usage Report"
    info "═══════════════════════════════════════"
    
    for model in "${!MODEL_USAGE_COUNT[@]}"; do
        local count=${MODEL_USAGE_COUNT["$model"]}
        local tokens=${MODEL_USAGE_TOKENS["$model"]}
        info "  $model: $count calls, ~$tokens tokens"
    done
    
    info "═══════════════════════════════════════"
}
```

---

## Measurement & Tracking

### Metrics to Track

#### Cost Metrics
- [ ] API calls per image (by model)
- [ ] Token usage (input + output)
- [ ] Estimated cost per image
- [ ] Total batch cost
- [ ] Cost comparison vs Phase 1

#### Quality Metrics
- [ ] Transcription accuracy (manual spot-checks)
- [ ] Consistency across images
- [ ] JSON validation success rate
- [ ] Processing time per image

#### Optimization Metrics
- [ ] Model substitution rate (cheap vs expensive)
- [ ] OCR skip rate
- [ ] Context reuse effectiveness
- [ ] Session token growth

### Benchmarking Plan

#### Baseline (Phase 1)
```bash
# Process 10 images with Phase 1 config
COST_OPTIMIZE=false ./image-metadata-pipeline.sh sample-images/

# Record:
# - Total time
# - API calls (estimated cost)
# - Quality assessment
```

#### Optimized (Phase 2)
```bash
# Process same 10 images with Phase 2 config
COST_OPTIMIZE=true ./image-metadata-pipeline.sh sample-images/

# Record:
# - Total time
# - API calls (actual cost)
# - Quality assessment
# - Model usage breakdown
```

#### Comparison
```bash
# Generate comparison report
compare_runs() {
    local phase1_log="$1"
    local phase2_log="$2"
    
    # Extract metrics
    # Calculate savings
    # Assess quality delta
    
    echo "Cost Reduction: X%"
    echo "Quality Delta: Y%"
    echo "Time Delta: Z%"
}
```

### A/B Testing

```bash
# Test model substitutions
test_model_quality() {
    local image="$1"
    local pattern="$2"
    
    # Run with both models
    local output_cheap=$(fabric-ai -a "$image" -p "$pattern" -m "$VISION_MODEL_QUICK")
    local output_expensive=$(fabric-ai -a "$image" -p "$pattern" -m "$VISION_MODEL_DETAILED")
    
    # Compare outputs
    echo "=== Cheap Model ===" > comparison.txt
    echo "$output_cheap" >> comparison.txt
    echo "" >> comparison.txt
    echo "=== Expensive Model ===" >> comparison.txt
    echo "$output_expensive" >> comparison.txt
    
    # Manual review or automated scoring
}
```

---

## Expected Results

### Cost Reduction Breakdown

| Technique | Savings | Notes |
|-----------|---------|-------|
| Adaptive vision models | 20-30% | Use scout for simple tasks |
| qwen3 for text reasoning | 10-15% | Cheaper than llama-3.3-70b |
| Selective OCR skipping | 10-20% | Skip when no text detected |
| Context reuse | 10-15% | Session-based efficiency |
| Batch optimization | 5-10% | Amortize KB context |
| **Total** | **40-50%** | Combined effect |

### Quality Targets

| Metric | Phase 1 | Phase 2 Target | How |
|--------|---------|----------------|-----|
| OCR Accuracy | Baseline | +10-20% | Context validation |
| Consistency | Baseline | +30-50% | Cross-referencing |
| JSON Validity | 100% | 100% | Maintained |
| Processing Speed | Baseline | Similar or faster | Better models |

---

## Usage

### Enable Cost Optimization
```bash
# Enable all cost optimizations
COST_OPTIMIZE=true ./image-metadata-pipeline.sh images/

# Individual flags
USE_ADAPTIVE_MODELS=true \
SKIP_OCR_WHEN_NO_TEXT=true \
./image-metadata-pipeline.sh images/
```

### Disable for Quality-Critical Work
```bash
# Use best models for everything
COST_OPTIMIZE=false ./image-metadata-pipeline.sh critical-images/
```

### Cost Reporting
```bash
# Enable verbose cost tracking
VERBOSE=true \
TRACK_COSTS=true \
./image-metadata-pipeline.sh images/

# View cost report
cat pipeline-costs.log
```

---

## Future Optimizations

### Dynamic Model Selection Based on Results
- Start with cheap model
- If output quality is low → retry with expensive model
- Learn which images need which models

### Caching
- Cache KB context summaries
- Cache common equipment profiles
- Reuse across runs

### Parallel Processing
- Process multiple images simultaneously
- Rate limit to avoid API throttling
- Estimate: 2-3x faster batch processing

### Streaming
- Stream outputs for faster perceived performance
- Process next image while current one is writing

---

**Status**: 📋 Strategy Documented - Ready for Phase 2.2 Implementation

**Note**: All cost optimizations must maintain Phase 1 quality or better. Quality is paramount; cost savings are secondary.
