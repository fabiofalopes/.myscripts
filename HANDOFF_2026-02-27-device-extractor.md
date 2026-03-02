# Handoff: Circuit Board / Device Knowledge Extractor Pipeline

**Date**: 2026-02-27
**Session**: Testing Pass 1 extraction on Eaton ePDU images
**Status**: ✅ Working (with known issues to address)

---

## Quick Resume Commands

```bash
# Jump to project
cd ~/projetos/hub/.myscripts/circuit-board-knowledge-extractor

# Run Pass 1 extraction (with rate limit awareness)
SKIP_EXISTING=true ./workflows/pass1-extraction.sh ~/Downloads/eaton-ePDU/ ~/Downloads/eaton-ePDU-pass1/

# View results
ls ~/Downloads/eaton-ePDU-pass1/
cat ~/Downloads/eaton-ePDU-pass1/IMG_5883.jpg.json | jq '.analysis'
```

---

## What We Tested Today

### Test Case: Eaton ePDU Device Images

**Input**: 20 device photos (converted from HEIC to JPG)

**Pipeline**: Pass 1 of 5-pass architecture (single-image extraction)

**Result**: ✅ Successfully extracting device information, but Groq rate limiting blocks bulk processing

---

## What Works

### 1. Pass 1 Extraction Pipeline

**File**: `workflows/pass1-extraction.sh`

**Stages**:
- Stage 1: Generate descriptive filename via AI
- Stage 2: Extract visible text (labels, model numbers, serial numbers)
- Stage 3: Structured JSON analysis (objects, identifiers, specs)
- Stage 4: Expert OCR pass
- Stage 5: Multi-scale OCR pass
- Stage 6: Aggregate all data into JSON

**Sample Output** (`~/Downloads/eaton-ePDU-pass1/IMG_5883.jpg.json`):

```json
{
  "generated_filename": "eaton-ups-device",
  "description": "### Device Label\nePDU\n### Control Panel\nESC\n1",
  "analysis": {
    "image_type": "photo",
    "description": "Close-up photo of an Eaton ePDU device showing control panel and ports",
    "objects": ["Eaton ePDU device", "control panel", "network ports", "USB port"],
    "technical_details": {
      "identifiers": {
        "model_numbers": ["ePDU"]
      },
      "specifications": "Eaton ePDU power distribution unit"
    }
  },
  "ocr": {
    "expert": "- EATON\n- ePDU\n- USB\n- Network ports"
  }
}
```

### 2. Vision Model: Groq Llama 4 Maverick

**Model**: `Groq|meta-llama/llama-4-maverick-17b-128e-instruct`

**Performance**:
- ✅ Good image understanding
- ✅ Accurate text extraction
- ✅ Fast (~7s per image)
- ❌ **Rate limits hit on bulk processing** (10+ images)

### 3. HEIC → JPG Converter

**File**: `workflows/heic-to-jpeg-converter.sh`

**Status**: ✅ Working perfectly

**Usage**:
```bash
bash workflows/heic-to-jpeg-converter.sh -v ~/Downloads/eaton-ePDU
```

**Output**: 19 JPEGs at 95% quality, ~3-6M each

---

## Bugs Fixed Today

### Bug 1: Vendor/Model String Not Parsed

**Problem**: Model string `Groq|meta-llama/...` passed directly to `-m` flag, causing `could not find vendor` error.

**Fix**: Split model string into vendor and model in new `run_fabric_vision()` function:

```bash
run_fabric_vision() {
    local image="$1"
    local pattern="$2"
    local vendor="${VISION_MODEL%|*}"
    local model="${VISION_MODEL#*|}"
    fabric-ai -a "$image" -p "$pattern" -V "$vendor" -m "$model" 2>/dev/null || echo ""
}
```

**Files Modified**: `workflows/pass1-extraction.sh`

### Bug 2: Case-Insensitive File Extension

**Problem**: `.JPG` files rejected by validation regex.

**Fix**: Convert filename to lowercase before regex check.

---

## Known Issues & Improvements Needed

### 1. Rate Limiting (CRITICAL)

**Problem**: Groq API throttles bulk requests. Processing 20 images timed out after 10 min.

**Impact**: Cannot process large batches without hitting limits.

**Solutions to Implement**:

1. **Rate limit aware processing**
   ```bash
   # Add delay between images
   sleep 5  # or configurable delay
   ```

2. **Batch processing with checkpoints**
   - Process in small batches (5-10 images)
   - Save progress state
   - Resume from interruption

3. **Retry with exponential backoff**
   ```bash
   retry_count=0
   max_retries=3
   while [[ $retry_count -lt $max_retries ]]; do
       run_fabric_vision "$image" "$pattern" && break
       ((retry_count++))
       sleep $((2 ** retry_count))
   done
   ```

4. **Provider fallback**
   - Try Groq first (fast, rate limited)
   - Fallback to Ollama (local, no rate limits but slower)
   - Fallback to OpenRouter (pay-per-use)

### 2. Pattern Failures

**Issue**: Some fabric patterns return empty output occasionally:
- `expert-ocr-engine` sometimes returns 0 chars
- `multi-scale-ocr` frequently returns 0 chars

**Fix**: Accept empty output as valid (already implemented), but log warnings more visibly.

### 3. Naming & Organization

**Current**: Generic "circuit-board" name, but it works for any devices.

**Suggested Renames**:

```
circuit-board-knowledge-extractor/
├── → device-knowledge-extractor/     # More generic name
├── → image-knowledge-extractor/      # Even more generic
```

**Better Script Wrapping**:

Create a top-level entrypoint that:
```bash
#!/usr/bin/env bash
# device-extractor.sh - Simple wrapper

source lib/rate-limiter.sh
source lib/provider-fallback.sh

main() {
    local input_dir="$1"
    local output_dir="${2:-./output}"

    # Rate limit aware processing
    rate_limit_init --provider Groq --max-reqs-per-minute 10

    # Process with fallback
    process_with_fallback "$input_dir" "$output_dir" \
        --primary-provider Groq \
        --fallback-provider Ollama \
        --batch-size 5
}
```

### 4. Configuration

**Current**: Hardcoded models in script.

**Improvement**: Config file at `config.json`:

```json
{
  "vision": {
    "primary": {
      "provider": "Groq",
      "model": "meta-llama/llama-4-maverick-17b-128e-instruct",
      "rate_limit": 10
    },
    "fallback": {
      "provider": "Ollama",
      "model": "llava-phi3:latest"
    }
  },
  "processing": {
    "batch_size": 5,
    "delay_between_images": 5,
    "max_retries": 3
  }
}
```

### 5. Logging

**Current**: Console output + basic log file.

**Improvements**:

```bash
# Structured logging
log_level=INFO  # DEBUG, INFO, WARN, ERROR
log_to_file="./logs/$(date +%Y%m%d-%H%M%S).log"

# Rate limit logging
log_rate_limit "Groq" "waiting 5s before next request"

# Progress tracking
log_progress "Processed 10/20 images (50%)"
```

---

## Architecture Summary

### 5-Pass Vision (Planned, Only Pass 1 Implemented)

| Pass | Status | Description |
|------|--------|-------------|
| Pass 1 | ✅ Implemented | Individual image extraction (stages 1-6) |
| Pass 2 | 📝 Planned | Component aggregation across images |
| Pass 3 | 📝 Planned | AI consensus building (canonical names) |
| Pass 4 | 📝 Planned | Cross-validation with consensus |
| Pass 5 | 📝 Planned | Final synthesis & documentation |

### Patterns Used (fabric-custom-patterns/)

| Pattern | Status | Purpose |
|---------|--------|---------|
| `name-file-gen` | ✅ Working | Generate descriptive filenames |
| `image-text-extraction` | ✅ Working | Extract visible text |
| `analyze-image-json` | ✅ Working | Structured JSON analysis |
| `expert-ocr-engine` | ⚠️ Partial | Expert OCR (sometimes empty) |
| `multi-scale-ocr` | ⚠️ Partial | Multi-scale OCR (often empty) |

---

## Test Data

**Eaton ePDU Images**:
- Location: `~/Downloads/eaton-ePDU/`
- Count: 20 JPGs (1x IMG_0029.JPG + 19x IMG_XXXX.jpg)
- Source: iPhone HEIC → JPG conversion
- Content: Device front panels, ports, labels

**Pass 1 Output**:
- Location: `~/Downloads/eaton-ePDU-pass1/`
- Status: Partially complete (10/20 images)
- Reason: Timeout from rate limits

---

## Model Configuration Notes

### Groq (Primary - Fast but Rate Limited)

**Vision Model**: `meta-llama/llama-4-maverick-17b-128e-instruct`
- ✅ Best vision understanding tested
- ✅ Fast (~7s per image)
- ❌ Rate limited (~10-15 images/min, may vary)

**Text Model**: `llama-3.3-70b-versatile`
- Not currently used (vision model does all work)

### Ollama (Fallback - Slow but Unlimited)

**Models Available**:
- `llava-phi3:latest` - Vision capable
- `gemma3:12b-vision` - Vision capable
- `qwen3-vl:8b` - Vision capable

**Command**: Check availability:
```bash
ollama list
```

### Z AI (Disabled - Balance Issue)

**Issue**: Direct API returns `429 Insufficient balance`
**Note**: OpenCode uses Z AI through its own gateway (free), but fabric-ai only supports direct APIs.

---

## Next Steps (Priority Order)

### High Priority (Make Pipeline Production-Ready)

1. **Implement rate limit aware processing**
   - Add configurable delay between images
   - Implement exponential backoff retry
   - Log rate limit events

2. **Create provider fallback system**
   - Try Groq → Ollama → stop
   - Configurable in config file

3. **Batch processing with resume capability**
   - Process 5-10 images at a time
   - Save progress state
   - Resume from interruption

4. **Better error handling**
   - Detailed error logging
   - Graceful degradation
   - Clear user feedback

### Medium Priority (Improve UX)

5. **Rename project to `device-knowledge-extractor`**
   - More accurate name
   - Update all references

6. **Create simple wrapper script**
   - Single command to run pipeline
   - Abstract away complexity

7. **Add configuration file**
   - `config.json` for all settings
   - Easy to adjust without editing scripts

8. **Improve logging**
   - Structured JSON logs
   - Progress bar
   - Rate limit status

### Low Priority (Future Enhancements)

9. **Implement Pass 2-5** (consensus pipeline)
   - Component aggregation
   - Cross-image consensus
   - Final documentation

10. **Web UI** (optional)
    - Drag-and-drop interface
    - Real-time progress
    - Export options

---

## Resume from Empty Context

To continue this project from a fresh session:

1. **Navigate to project**:
   ```bash
   cd ~/projetos/hub/.myscripts/circuit-board-knowledge-extractor
   ```

2. **Review this handoff**:
   ```bash
   cat HANDOFF_2026-02-27.md
   ```

3. **Check current state**:
   ```bash
   # See existing output
   ls ~/Downloads/eaton-ePDU-pass1/

   # Test on single image
   ./workflows/pass1-extraction.sh ~/Downloads/eaton-ePDU/IMG_5883.jpg /tmp/test/
   ```

4. **Start from priority**:
   - Implement rate limiting (High Priority #1)
   - Create provider fallback (High Priority #2)
   - Add batch processing (High Priority #3)

5. **Document progress**:
   - Update this handoff as you go
   - Mark completed items
   - Log new findings

---

## Files Modified Today

1. `workflows/pass1-extraction.sh`
   - Added `run_fabric_vision()` function
   - Fixed vendor/model string parsing
   - Fixed case-insensitive file extension

2. `workflows/heic-to-jpeg-converter.sh`
   - (No changes - already working)

---

## Commands Reference

### Run Pass 1 Extraction

```bash
# Single image
./workflows/pass1-extraction.sh /path/to/image.jpg /path/to/output/

# Directory (all images)
./workflows/pass1-extraction.sh /path/to/images/ /path/to/output/

# With options
SKIP_EXISTING=true ./workflows/pass1-extraction.sh ~/Downloads/ePDU/ ~/Downloads/ePDU-pass1/
VERBOSE=true ./workflows/pass1-extraction.sh ~/Downloads/ePDU/ ~/Downloads/ePDU-pass1/
```

### Convert HEIC to JPG

```bash
# With verbose output
bash workflows/heic-to-jpeg-converter.sh -v ~/Downloads/ePDU/

# With quality setting
bash workflows/heic-to-jpeg-converter.sh -q 85 ~/Downloads/ePDU/
```

### View Results

```bash
# List all output files
ls ~/Downloads/eaton-ePDU-pass1/

# View single result
cat ~/Downloads/eaton-ePDU-pass1/IMG_5883.jpg.json | jq '.'

# Extract specific fields
cat ~/Downloads/eaton-ePDU-pass1/*.json | jq '.analysis.technical_details.identifiers'
```

---

## Contact / Context

**Project**: Device Knowledge Extractor (formerly Circuit Board Knowledge Extractor)
**Location**: `~/projetos/hub/.myscripts/circuit-board-knowledge-extractor/`
**Primary Tools**: fabric-ai, jq, bash, ImageMagick
**Key Models**: Groq Llama 4 Maverick (vision), Ollama (fallback)
**Last Tested**: 2026-02-27

---

## Appendix: Error Log (from testing)

### Error 1: Vendor not found
```
Requested Model = Groq|meta-llama/llama-4-maverick-17b-128e-instruct
Default Model = glm-4.7
Default Vendor = Z AI.

could not find vendor.
```
**Cause**: Model string passed directly to `-m` flag
**Fix**: Split into `-V "Groq"` and `-m "meta-llama/..."`

### Error 2: Rate limiting (timeout)
```
Processing 20 images...
[10 min timeout]
```
**Cause**: Groq API rate limits (exact limit unknown)
**Fix**: Implement rate limit aware processing (pending)

### Error 3: Z AI insufficient balance
```
429 Too Many Requests {"code":"1113","message":"Insufficient balance or no resource package. Please recharge."}
```
**Cause**: Direct Z AI API account has no credits
**Note**: OpenCode uses Z AI through separate gateway (free access)

---

**End of Handoff**
