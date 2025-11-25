# Architecture

## System Overview
The Image Metadata Pipeline is a bash-orchestrated sequential processing system that leverages fabric-ai patterns and LLM models to extract comprehensive metadata from images.

## Design Principles
1. **Sequential Processing** - Each stage completes before the next begins
2. **Model Specialization** - Different models for different tasks (vision vs. text processing)
3. **Validation at Every Stage** - Output from each pattern is validated before proceeding
4. **Idempotent Operations** - Re-running pipeline on same image produces same result
5. **Fail-Fast with Logging** - Errors stop processing but are logged for review

## Data Flow Architecture

```
┌─────────────────┐
│  Input Image    │
│   (*.jpg)       │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 1: Filename Generation           │
│  Pattern: name-file-gen                 │
│  Model: llama-3.3-70b-versatile         │
│  Output: Slugified filename string      │
│  Validation: Slug format check          │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 2: Text Extraction               │
│  Pattern: image-text-extraction         │
│  Model: llama-4-maverick-17b (vision)   │
│  Output: Descriptive text               │
│  Validation: Non-empty string check     │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 3: Structured Analysis           │
│  Pattern: analyze-image-json            │
│  Model: llama-4-maverick-17b (vision)   │
│  Output: JSON object                    │
│  Validation: Valid JSON parsing         │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 4: Expert OCR                    │
│  Pattern: expert-ocr-engine             │
│  Model: llama-4-maverick-17b (vision)   │
│  Output: Extracted text                 │
│  Validation: String format check        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 5: Multi-Scale OCR               │
│  Pattern: multi-scale-ocr               │
│  Model: llama-4-maverick-17b (vision)   │
│  Output: Extracted text at scales       │
│  Validation: String format check        │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│  Stage 6: JSON Aggregation              │
│  Pattern: json-parser                   │
│  Model: llama-3.3-70b-versatile         │
│  Input: All previous outputs combined   │
│  Output: Unified JSON structure         │
│  Validation: Final JSON validation      │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│  Output File    │
│ image.jpg.json  │
└─────────────────┘
```

## Component Architecture

### Core Script: `image-metadata-pipeline.sh`

```bash
#!/bin/bash

# Function Structure:
# 1. validate_environment()      - Check all requirements present
# 2. validate_image()            - Verify image file exists and is readable
# 3. generate_filename()         - Stage 1 processing
# 4. validate_slug()             - Validate filename format
# 5. extract_text()              - Stage 2 processing
# 6. analyze_image()             - Stage 3 processing
# 7. run_expert_ocr()            - Stage 4 processing
# 8. run_multi_scale_ocr()       - Stage 5 processing
# 9. aggregate_json()            - Stage 6 processing
# 10. validate_json()            - Final output validation
# 11. write_output()             - Save JSON to file
# 12. process_image()            - Main orchestration function
# 13. process_directory()        - Batch processing wrapper
```

### Error Handling Architecture

```
┌──────────────────────┐
│  Try Process Image   │
└──────┬───────────────┘
       │
       ▼
   ┌───────┐
   │Success│────────────────────────┐
   └───┬───┘                        │
       │                            ▼
       │                    ┌───────────────┐
       │                    │ Write Output  │
       │                    └───────────────┘
       │
   ┌───▼───┐
   │ Error │
   └───┬───┘
       │
       ▼
┌─────────────────────┐
│  Log Error Details  │
│  - Filename         │
│  - Stage Failed     │
│  - Error Message    │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│  Continue Next      │
│  (if batch mode)    │
└─────────────────────┘
```

## Model Selection Strategy

### Vision-Capable Models (Stages 2-5)
**Model**: `meta-llama/llama-4-maverick-17b-128e-instruct`

**Rationale**:
- Supports vision input (images)
- OCR capabilities verified
- Fast inference on Groq
- Consistent output quality

**Used for**:
- `image-text-extraction`
- `analyze-image-json`
- `expert-ocr-engine`
- `multi-scale-ocr`

### Text Processing Models (Stages 1, 6)
**Model**: `llama-3.3-70b-versatile`

**Rationale**:
- No vision needed (text input only)
- Superior text understanding
- Better JSON generation
- Faster for text-only tasks

**Used for**:
- `name-file-gen` (if text-based fallback)
- `json-parser` (aggregation stage)

## Validation Architecture

### Slug Validation (Stage 1)
```bash
validate_slug() {
    local slug="$1"
    # Must match: lowercase letters, numbers, hyphens only
    # No spaces, special chars, or uppercase
    if [[ ! "$slug" =~ ^[a-z0-9-]+$ ]]; then
        return 1
    fi
    return 0
}
```

### JSON Validation (Stages 3, 6)
```bash
validate_json() {
    local json_string="$1"
    # Use jq to parse and validate
    if echo "$json_string" | jq empty 2>/dev/null; then
        return 0
    fi
    return 1
}
```

## File System Architecture

### Input Structure
```
working-directory/
├── image1.jpg
├── image2.jpg
└── image3.jpg
```

### Output Structure
```
working-directory/
├── image1.jpg
├── image1.jpg.json          # metadata
├── image1.jpg.log           # processing log (if errors)
├── image2.jpg
├── image2.jpg.json
└── pipeline-errors.log      # aggregated errors
```

## Concurrency Model
**Single-threaded sequential processing**

Rationale:
- API rate limits make parallelism problematic
- Sequential processing ensures predictable behavior
- Easier debugging and error tracking
- Sufficient for typical batch sizes (10-100 images)

Future consideration: Add parallel processing with rate limiting if needed.

## State Management
**Stateless per image**

- Each image processed independently
- No shared state between image processing
- Output files are the only persistent state
- Re-running on same image overwrites previous output (idempotent)

## Logging Architecture

### Log Levels
1. **INFO** - Normal progress (image X of Y)
2. **WARN** - Recoverable issues (retry attempts)
3. **ERROR** - Failures (stage failed, continuing)
4. **FATAL** - Cannot continue (missing dependencies)

### Log Destinations
- **stdout** - Progress and info messages
- **stderr** - Warnings and errors
- **File** - Detailed error log (`pipeline-errors.log`)

## Configuration Management
Script reads from environment variables with fallbacks:

```bash
# Model configuration
VISION_MODEL="${VISION_MODEL:-meta-llama/llama-4-maverick-17b-128e-instruct}"
TEXT_MODEL="${TEXT_MODEL:-llama-3.3-70b-versatile}"

# Processing options
SKIP_EXISTING="${SKIP_EXISTING:-false}"  # Skip if .json exists
VERBOSE="${VERBOSE:-false}"               # Detailed logging
```

## Extensibility Points
1. **Additional patterns** - Easy to add new fabric-ai pattern stages
2. **Custom models** - Override via environment variables
3. **Output formats** - JSON structure is versioned and extensible
4. **Pre/post processing hooks** - Functions can be added before/after stages
