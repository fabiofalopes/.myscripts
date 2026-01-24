# Technical Analysis: Existing Fabric Infrastructure

**Date**: 2026-01-23  
**Purpose**: Document current capabilities and integration points

---

## 🔍 Existing System: fabric-image-analysis

### Location
`~/.myscripts/fabric-image-analysis/`

### Status
✅ Production-ready (Phase 1 complete, Phase 2 in development)

### Core Capabilities

#### 1. Sequential 6-Stage Pipeline
**Script**: `workflows/image-metadata-pipeline.sh` (673 lines)

**Pipeline Flow**:
```
Stage 1: Filename Generation (name-file-gen)
  ↓ Model: llama-4-maverick-17b
  ↓ Output: Slugified filename
  
Stage 2: Text Extraction (image-text-extraction)
  ↓ Model: llama-4-maverick-17b
  ↓ Output: Full description text
  
Stage 3: Structured Analysis (analyze-image-json)
  ↓ Model: llama-4-maverick-17b
  ↓ Output: JSON with objects, technical details, layout
  
Stage 4: Expert OCR (expert-ocr-engine)
  ↓ Model: llama-4-maverick-17b
  ↓ Output: Extracted text
  
Stage 5: Multi-Scale OCR (multi-scale-ocr)
  ↓ Model: llama-4-maverick-17b
  ↓ Output: Multi-resolution text
  
Stage 6: JSON Aggregation (json-parser)
  ↓ Model: llama-3.3-70b
  ↓ Output: Unified JSON structure
```

**Processing Time**: ~20-25 seconds per image

#### 2. Context-Aware Mode (Phase 2)
**Enabled via**: `ENABLE_CONTEXT=true`

**Mechanism**: Manual context injection (not fabric sessions)
- Extracts key info from each processed image
- Injects into next image's prompt via `-v` flag
- Avoids 413 errors (Request Entity Too Large)

**Context Extraction** (from JSON):
- Model numbers
- Serial numbers (count only, not full for privacy)
- Main objects/components
- Device type

**Context Window**: Last 500 chars (auto-trimmed)

**Patterns with Context Support**:
- `analyze-image-json-with-context`
- `expert-ocr-with-context`
- `multi-scale-ocr-with-context`

#### 3. Validation & Error Handling
- JSON validation at every stage (jq-based)
- Automatic JSON extraction from markdown blocks
- Retry logic with backoff (MAX_RETRIES=2)
- Comprehensive error logging (pipeline-errors.log)
- Skip-existing capability (SKIP_EXISTING=true)

#### 4. Output Structure
**Per Image**: `image.jpg.json`

```json
{
  "original_filename": "string",
  "generated_filename": "string (slug)",
  "description": "string",
  "analysis": {
    "image_type": "photo|diagram|screenshot|document",
    "objects": ["array"],
    "text_content": {
      "visible_text": ["array"],
      "labels": ["array"],
      "serial_numbers": ["array"]
    },
    "technical_details": {
      "identifiers": {
        "model_numbers": ["array"],
        "serial_numbers": ["array"],
        "part_numbers": ["array"]
      },
      "specifications": ["array"]
    },
    "layout": { "composition": "string", "orientation": "string" },
    "colors": { "dominant": ["array"], "palette": ["array"] },
    "quality_assessment": { "clarity": "string", "lighting": "string" }
  },
  "ocr": {
    "expert": "string",
    "multi_scale": "string"
  },
  "metadata": {
    "processed_at": "ISO 8601",
    "pipeline_version": "1.0.0",
    "models_used": { "vision": "string", "text": "string" }
  }
}
```

### Environment Variables
```bash
VISION_MODEL="meta-llama/llama-4-maverick-17b-128e-instruct"
TEXT_MODEL="llama-3.3-70b-versatile"
SKIP_EXISTING="false"
VERBOSE="false"
MAX_RETRIES="2"
ENABLE_CONTEXT="false"
SESSION_NAME="pipeline-YYYYMMDD-HHMMSS"
```

---

## 📦 Fabric Custom Patterns

### Location
`~/.myscripts/fabric-custom-patterns/`

### OCR-Related Patterns (Existing)

#### 1. expert-ocr-engine
**Purpose**: Technical identifier extraction  
**Focus**: Model numbers, serial numbers, MAC addresses, labels  
**Output**: Markdown-formatted text (bullets/code blocks)  
**Key Feature**: Preserves exact spelling, capitalization, spacing

**Prompt Highlights**:
- "Transcribe **every** character exactly as it appears"
- "Focus on technical identifiers"
- "Do not add explanations"

#### 2. multi-scale-ocr
**Purpose**: Multi-resolution text capture  
**Approach**: Analyzes text at different scales  
**Use Case**: Handles both large and tiny text in same image

#### 3. analyze-image-json
**Purpose**: Structured analysis with JSON output  
**Output Schema**: Comprehensive (see above)  
**Validation**: Strict JSON format enforcement

**Key Sections**:
- `image_type`: Photo, screenshot, diagram, etc.
- `objects`: All identified components
- `text_content`: OCR results with locations
- `technical_details.identifiers`: Model/serial/part numbers
- `quality`: Clarity, lighting assessment

#### 4. image-text-extraction
**Purpose**: Full semantic description  
**Output**: Natural language text  
**Use Case**: Human-readable summary

#### 5. Context-Aware Variants
- `analyze-image-json-with-context`
- `expert-ocr-with-context`
- `multi-scale-ocr-with-context`

**Mechanism**: Accept context via `-v="#context:..."`

### Other Relevant Patterns
- `name-file-gen`: Slugified filename generation
- `json-parser`: JSON aggregation and repair
- `validate_extraction`: Validation logic

---

## 🔧 Integration Points for New System

### What We Can Reuse Directly

#### 1. Entire Pass 1 Pipeline
```bash
# Just call the existing script
./fabric-image-analysis/workflows/image-metadata-pipeline.sh \
  ~/Desktop/Salto\ encoder/converted/
```

**Benefit**: Don't reinvent the wheel, 673 lines of tested code

#### 2. Context Injection Mechanism
```bash
# Pattern for Pass 4 re-analysis
fabric-ai -a image.jpg -p analyze-image-json-with-context \
  -m llama-4-maverick-17b \
  -v="#context:Canonical components: STM32F103C8T6, LM1117..."
```

**Benefit**: Already handles context without session bloat

#### 3. JSON Extraction & Validation
```bash
# Functions we can copy/adapt
validate_json() { ... }
extract_json_from_markdown() { ... }
```

**Benefit**: Robust error handling already implemented

### What We Need to Build

#### 1. Component Extraction Logic
```bash
# New: extract-components.jq
jq -r '
  .analysis.technical_details.identifiers.model_numbers[]?,
  .analysis.technical_details.identifiers.part_numbers[]?,
  .analysis.text_content.visible_text[]?
' *.json | sort | uniq -c
```

#### 2. Similarity Grouping
```bash
# New: Use fzf or custom bash logic for fuzzy matching
# Group variants like: ["STM32F103", "STM32F1O3", "STM32F103C"]
```

#### 3. Consensus Patterns (4 New)
- `component-consensus-builder/system.md`
- `ocr-error-detector/system.md`
- `technical-identifier-validator/system.md`
- `circuit-board-synthesizer/system.md`

#### 4. Orchestration Script
```bash
# New: circuit-board-extractor.sh
# Coordinates all 5 passes
```

---

## 🎯 Target Data Analysis

### Location
`~/Desktop/drive-download-20260123T185902Z-3-001/Salto ncoder /`

### File Inventory
```
17 images total
Format: HEIC (not JPG/PNG!)
Size: 958KB - 4.1MB
Names: IMG_5935.HEIC - IMG_5961.HEIC (with gaps)
```

### Files
```
IMG_5935.HEIC  3.8MB
IMG_5936.HEIC  3.7MB
IMG_5937.HEIC  1.3MB
IMG_5938.HEIC  4.2MB
IMG_5939.HEIC  3.4MB
IMG_5940.HEIC  2.8MB
IMG_5941.HEIC  3.0MB
IMG_5942.HEIC  2.4MB
IMG_5943.HEIC  2.7MB
IMG_5944.HEIC  2.0MB
IMG_5945.HEIC  1.6MB
IMG_5946.HEIC  959KB
IMG_5947.HEIC  1.2MB
IMG_5958.HEIC  2.8MB
IMG_5959.HEIC  2.5MB
IMG_5960.HEIC  2.3MB
IMG_5961.HEIC  2.3MB
```

### Critical Issue: Format Conversion Required

**Current Pipeline**: Only handles `.jpg`, `.jpeg`, `.png`  
**Target Files**: All `.HEIC`  
**Solution**: Pre-processing step to convert HEIC → JPEG

**Conversion Options**:

1. **ImageMagick** (recommended)
   ```bash
   magick convert input.HEIC output.jpg
   ```

2. **heif-convert** (lighter)
   ```bash
   heif-convert input.HEIC output.jpg
   ```

3. **Batch Script**
   ```bash
   for file in *.HEIC; do
     magick convert "$file" "${file%.HEIC}.jpg"
   done
   ```

**Quality Considerations**:
- Preserve resolution (no downscaling)
- Quality setting: 95% (high quality)
- Metadata preservation (EXIF)

---

## 🧪 Testing Strategy

### Phase 1 Testing: Sample Set
**Select**: 3 images with different characteristics
- IMG_5935.HEIC (largest, likely detailed)
- IMG_5937.HEIC (smallest, likely zoomed)
- IMG_5946.HEIC (medium, likely overview)

**Process**:
1. Convert to JPEG
2. Run through existing pipeline
3. Manually review JSON output
4. Document OCR accuracy
5. Identify error patterns

### Validation Checklist
- [ ] HEIC conversion preserves quality
- [ ] Pipeline processes JPEGs successfully
- [ ] JSON output is valid and comprehensive
- [ ] OCR captures most visible text
- [ ] Technical identifiers extracted correctly
- [ ] Errors are consistent/predictable

---

## 📊 Expected Challenges

### 1. Small Component Text
**Issue**: Circuit board labels are 1-2mm tall  
**Current Capability**: Multi-scale OCR helps but not perfect  
**Mitigation**: Consensus across multiple angles/zooms

### 2. OCR Error Patterns
**Common Mistakes**:
- O ↔ 0 (letter O vs. zero)
- I ↔ 1 (letter I vs. one)
- 8 ↔ B (eight vs. letter B)
- S ↔ 5 (letter S vs. five)

**Detection Strategy**: Pattern recognition in consensus builder

### 3. Ambiguous Components
**Issue**: Is "STM32F103" and "STM32F103C8T6" the same or different?  
**Solution**: Partial matching + confidence scoring

### 4. Processing Time
**Current**: 20-25s per image × 17 images = 5-7 minutes (Pass 1 only)  
**Total**: 5 passes × 7 minutes = 35 minutes  
**Mitigation**: Checkpoint system, parallel processing (future)

---

## 🔗 Dependencies

### Required Tools
- [x] fabric-ai (v1.4.316+)
- [x] jq (JSON processor)
- [ ] ImageMagick or heif-convert (for HEIC)
- [x] bash 4.0+

### API Requirements
- Groq API (for llama-4-maverick)
- Fabric configuration (~/.config/fabric/.env)

### File System
```
~/.myscripts/
  ├── fabric-image-analysis/     ✓ Exists
  ├── fabric-custom-patterns/    ✓ Exists
  └── circuit-board-knowledge-extractor/  ✗ To create
```

---

## 💡 Key Insights

### What Works Well
1. **Sequential pipeline**: Clean, debuggable, proven
2. **Context injection**: Avoids session bloat, works reliably
3. **JSON validation**: Catches errors early
4. **Modular patterns**: Easy to extend

### What Needs Improvement
1. **Multi-image aggregation**: Not built yet
2. **Consensus logic**: No existing patterns
3. **Cross-validation**: Manual process currently
4. **Format support**: HEIC not handled

### Opportunities
1. **Reuse 90% of existing code**: Just add orchestration layer
2. **Pattern library**: Build reusable consensus patterns
3. **Template for other use cases**: Receipts, documents, etc.

---

## 📝 Recommendations

### For Phase 1
1. Start with HEIC conversion script (simple, testable)
2. Test on 3 images first (validate before scaling)
3. Manually verify OCR output (establish ground truth)
4. Document error patterns (inform consensus logic)

### For Pattern Development
1. Study existing patterns' prompt engineering
2. Test consensus logic manually first (LLM playground)
3. Start with simple cases (clear OCR errors)
4. Iterate based on real data

### For Documentation
1. Keep masterplan updated (checkbox progress)
2. Document learnings in session notes
3. Save sample outputs (examples directory)
4. Track metrics (accuracy, time, confidence)

---

**Analysis Complete**: 2026-01-23  
**Next Action**: Begin Phase 1 - HEIC Conversion & Testing
