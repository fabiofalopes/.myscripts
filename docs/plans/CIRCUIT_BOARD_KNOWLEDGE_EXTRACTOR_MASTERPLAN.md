# Circuit Board Knowledge Extractor - Master Development Plan

**Project**: Multi-Pass Consensus-Based OCR System for Circuit Board Documentation  
**Status**: Planning Phase  
**Created**: 2026-01-23  
**Target Use Case**: Salto Encoder circuit board photos (HEIC format)

---

## 🎯 Project Vision

Build an intelligent multi-pass image analysis system that processes folders of circuit board photos to extract accurate, consolidated technical documentation. The system overcomes OCR inaccuracies by aggregating knowledge across multiple images and building consensus on component identifiers.

### Core Problem
Visual models make OCR errors when reading circuit board text. The same component appears with different typos/misreadings across multiple images. We need to:
- Process multiple images of the same subject
- Aggregate readings across images
- Build consensus on "true" component names
- Generate final accurate, structured documentation

### Solution Architecture
Multi-pass pipeline that:
1. **Pass 1**: Individual extraction (existing pipeline)
2. **Pass 2**: Aggregate and identify patterns
3. **Pass 3**: Consensus building (LLM-based)
4. **Pass 4**: Cross-validation with consensus knowledge
5. **Pass 5**: Final synthesis

---

## 📊 Current State Analysis

### ✅ What We Have
- **fabric-image-analysis**: Working 6-stage sequential pipeline
  - Filename generation, text extraction, structured analysis
  - Expert OCR, multi-scale OCR, JSON aggregation
  - Context-aware mode (Phase 2) with manual context injection
  - Processes jpg/jpeg/png only
  
- **Fabric Custom Patterns**: 30+ patterns including:
  - `expert-ocr-engine` - Technical identifier extraction
  - `analyze-image-json` - Structured JSON analysis
  - `multi-scale-ocr` - Multi-resolution text capture
  - Context-aware variants: `*-with-context`

- **Target Data**: 
  - Location: `~/Desktop/drive-download-20260123T185902Z-3-001/Salto ncoder /`
  - Format: 17 HEIC images (IMG_5935-5961)
  - Size: 1-4 MB per image

### ❌ What We Need
- HEIC to JPEG conversion capability
- Multi-pass orchestration system
- Consensus-building logic
- Component aggregation/deduplication
- Cross-image validation
- Final synthesis generator
- New Fabric patterns for consensus

---

## 🏗️ System Architecture

### High-Level Flow
```
[HEIC Images] 
    ↓ (conversion)
[JPEG Images]
    ↓ (Pass 1: Individual Extraction)
[Per-Image JSON Files]
    ↓ (Pass 2: Aggregation)
[Component Database]
    ↓ (Pass 3: Consensus Building)
[Canonical Component Map]
    ↓ (Pass 4: Cross-Validation)
[Refined Analysis]
    ↓ (Pass 5: Synthesis)
[Final Knowledge Document]
```

### Components to Build

#### 1. Image Preparation Layer
- **heic-to-jpeg-converter.sh**
  - Batch convert HEIC → JPEG
  - Preserve metadata
  - Output to processed/ folder

#### 2. Multi-Pass Orchestrator
- **circuit-board-extractor.sh** (main workflow)
  - Orchestrates all 5 passes
  - Progress tracking
  - Checkpoint/resume capability
  - Error handling

#### 3. Aggregation Layer
- **component-aggregator.sh**
  - Extract all components from JSON files
  - Group by similarity
  - Calculate frequency/confidence
  - Output: component-database.json

#### 4. Consensus Layer (NEW Fabric Patterns)
- **component-consensus-builder** pattern
  - Input: Multiple variant readings
  - Output: Canonical name + confidence
  - Uses LLM reasoning

- **ocr-error-detector** pattern
  - Identifies likely OCR errors
  - Context-based validation

- **technical-identifier-validator** pattern
  - Validates against known patterns
  - Flags suspicious readings

#### 5. Synthesis Layer
- **circuit-board-synthesizer** pattern
  - Input: All validated data
  - Output: Comprehensive markdown document
  - Structured sections: components, layout, specifications

- **synthesis-generator.sh**
  - Aggregates all data
  - Calls synthesizer pattern
  - Generates final output

---

## 📋 Development Phases

### Phase 1: Foundation & Validation ✅
**Goal**: Verify existing pipeline works with circuit board images

- [x] Convert HEIC images to JPEG
  - [x] Write heic-to-jpeg-converter.sh
  - [x] Test on 2-3 sample images
  - [x] Verify quality/metadata preservation
  
- [x] Test existing pipeline on circuit boards
  - [x] Run image-metadata-pipeline.sh on 3 sample JPEGs
  - [x] Analyze JSON output quality
  - [x] Document OCR accuracy issues
  - [x] Identify common error patterns

- [x] Baseline metrics
  - [x] Count unique components identified per image
  - [x] Document component name variations
  - [x] Calculate OCR error rate (manual validation)

**Deliverables**: 
- heic-to-jpeg-converter.sh
- Sample JSON outputs (3 images)
- BASELINE_ANALYSIS.md (error patterns, metrics)

**Validation Criteria**:
- ✅ All HEIC files convert successfully
- ✅ Pipeline produces valid JSON for each image
- ✅ At least 50% of component text is readable

---

### Phase 2: Component Aggregation ✅
**Goal**: Extract and aggregate all components across images

- [x] Build component extraction logic
  - [x] Write extract-components.jq (jq script)
  - [x] Extract model numbers, part numbers, labels
  - [x] Extract all OCR text segments
  - [x] Normalize formatting (lowercase, trim)

- [x] Build similarity grouping
  - [x] Implement fuzzy matching (Levenshtein distance)
  - [x] Group similar component names
  - [x] Calculate frequency/confidence
  - [x] Assign confidence scores

- [x] Create component database
  - [x] component-aggregator.sh wrapper script
  - [x] Output: component-database.json structure:
    ```json
    {
      "component_groups": [
        {
          "canonical_candidate": "STM32F103",
          "variants": ["STM32F103", "STM32F1O3", "STM32F103C"],
          "frequency": 5,
          "confidence": 0.85,
          "sources": ["IMG_5935.jpg", "IMG_5936.jpg"]
        }
      ]
    }
    ```

**Deliverables**:
- extract-components.jq
- component-aggregator.sh
- component-database.json (sample)

**Validation Criteria**:
- ✅ All components extracted from JSON files
- ✅ Similar components grouped correctly
- ✅ Confidence scores correlate with OCR quality

---

### Phase 3: Consensus Building 🔲
**Goal**: Create Fabric patterns that determine canonical component names

- [ ] Design consensus-builder pattern
  - [ ] Create fabric-custom-patterns/component-consensus-builder/
  - [ ] Write system.md prompt
  - [ ] Input: Array of variant readings + context
  - [ ] Output: Canonical name + reasoning
  - [ ] Test with sample variants

- [ ] Design error-detector pattern
  - [ ] Create fabric-custom-patterns/ocr-error-detector/
  - [ ] Identify OCR-like errors (O/0, I/1, 8/B)
  - [ ] Flag low-confidence readings

- [ ] Design validator pattern
  - [ ] Create fabric-custom-patterns/technical-identifier-validator/
  - [ ] Validate against component naming patterns
  - [ ] Check format consistency

- [ ] Build consensus orchestrator
  - [ ] consensus-builder.sh wrapper
  - [ ] Process each component group
  - [ ] Generate canonical-components.json
  - [ ] Track validation flags

**Deliverables**:
- 3 new Fabric patterns (system.md files)
- consensus-builder.sh
- canonical-components.json (sample)

**Validation Criteria**:
- ✅ Patterns produce consistent results
- ✅ Manual validation: 90%+ accuracy on canonical names
- ✅ Error detection flags obvious OCR mistakes

---

### Phase 4: Cross-Validation & Refinement 🔲
**Goal**: Re-analyze images with consensus knowledge

- [ ] Enhance context-aware patterns
  - [ ] Update analyze-image-json-with-context
  - [ ] Inject canonical component knowledge
  - [ ] Improve accuracy on second pass

- [ ] Build re-analysis workflow
  - [ ] re-analyze-with-consensus.sh
  - [ ] Use canonical-components.json as context
  - [ ] Generate refined JSON outputs
  - [ ] Compare with Pass 1 results

- [ ] Validation & metrics
  - [ ] Calculate improvement in accuracy
  - [ ] Identify remaining issues
  - [ ] Document edge cases

**Deliverables**:
- Enhanced context-aware patterns
- re-analyze-with-consensus.sh
- IMPROVEMENT_METRICS.md

**Validation Criteria**:
- ✅ Pass 2 accuracy > Pass 1 accuracy
- ✅ Component count stabilizes (less variation)
- ✅ Cross-reference accuracy improves

---

### Phase 5: Final Synthesis 🔲
**Goal**: Generate comprehensive documentation

- [ ] Design synthesizer pattern
  - [ ] Create circuit-board-synthesizer/ pattern
  - [ ] Input: All aggregated + validated data
  - [ ] Output: Structured markdown document
  - [ ] Sections: Overview, Components, Layout, Technical Specs

- [ ] Build synthesis workflow
  - [ ] synthesis-generator.sh
  - [ ] Aggregate all JSON files
  - [ ] Prepare context for synthesizer
  - [ ] Generate final document

- [ ] Document structure
  ```markdown
  # Salto Encoder Circuit Board Analysis
  
  ## Overview
  [Summary of the board]
  
  ## Component Inventory
  ### Microcontrollers
  - STM32F103C8T6 (confirmed, 5 images)
  
  ### Passive Components
  - [List with confidence scores]
  
  ## Board Layout
  [Description of physical layout]
  
  ## Technical Specifications
  [Extracted specs]
  
  ## Metadata
  - Images processed: 17
  - Confidence: 0.92
  ```

**Deliverables**:
- circuit-board-synthesizer/ pattern
- synthesis-generator.sh
- SALTO_ENCODER_ANALYSIS.md (final output)

**Validation Criteria**:
- ✅ Document is comprehensive and readable
- ✅ All components accounted for
- ✅ Manual review confirms 90%+ accuracy

---

## 📁 Project Structure

```
~/.myscripts/
├── circuit-board-knowledge-extractor/
│   ├── README.md
│   ├── workflows/
│   │   ├── heic-to-jpeg-converter.sh
│   │   ├── circuit-board-extractor.sh (main orchestrator)
│   │   ├── component-aggregator.sh
│   │   ├── consensus-builder.sh
│   │   ├── re-analyze-with-consensus.sh
│   │   └── synthesis-generator.sh
│   ├── lib/
│   │   ├── extract-components.jq
│   │   ├── similarity-matcher.sh
│   │   └── utils.sh
│   ├── data/ (gitignored)
│   │   ├── source/ (HEIC files)
│   │   ├── converted/ (JPEG files)
│   │   ├── pass1/ (initial JSON)
│   │   ├── pass2/ (aggregated data)
│   │   ├── pass3/ (consensus)
│   │   ├── pass4/ (refined JSON)
│   │   └── pass5/ (final output)
│   ├── docs/
│   │   ├── ARCHITECTURE.md
│   │   ├── BASELINE_ANALYSIS.md
│   │   ├── IMPROVEMENT_METRICS.md
│   │   └── USAGE.md
│   └── test/
│       └── sample-images/
│
├── fabric-custom-patterns/ (add new patterns)
│   ├── component-consensus-builder/
│   │   └── system.md
│   ├── ocr-error-detector/
│   │   └── system.md
│   ├── technical-identifier-validator/
│   │   └── system.md
│   └── circuit-board-synthesizer/
│       └── system.md
```

---

## 🎯 Success Metrics

### Quantitative
- [ ] OCR accuracy improvement: >30% from Pass 1 to Pass 5
- [ ] Component identification: >95% of visible components
- [ ] False positive rate: <5%
- [ ] Processing time: <2 minutes per image (total pipeline)

### Qualitative
- [ ] Final document is human-readable and useful
- [ ] Can be used for circuit board documentation
- [ ] Consensus logic handles edge cases gracefully
- [ ] System is reusable for other circuit board sets

---

## 🔧 Technical Decisions

### Image Format
- **Decision**: Convert HEIC → JPEG before processing
- **Rationale**: Existing pipeline only handles JPG/PNG, Fabric models work well with JPEG
- **Tool**: ImageMagick `magick convert` or `heif-convert`

### Consensus Algorithm
- **Decision**: LLM-based consensus (Fabric pattern)
- **Rationale**: Better at understanding context vs. pure string matching
- **Fallback**: Frequency-based voting if LLM fails

### Data Storage
- **Decision**: JSON for intermediate data, Markdown for final output
- **Rationale**: JSON is machine-readable, Markdown is human-readable
- **Backup**: All intermediate data saved for debugging

### Model Selection
- **Vision tasks**: llama-4-maverick-17b (proven with fabric-image-analysis)
- **Text/consensus**: llama-3.3-70b (better reasoning)
- **Can override**: Via environment variables

---

## 🚨 Known Challenges & Mitigations

### Challenge 1: HEIC Compatibility
- **Issue**: Not all systems have HEIC support
- **Mitigation**: Document ImageMagick installation, provide conversion script

### Challenge 2: OCR Accuracy on Small Text
- **Issue**: Circuit board component labels are tiny
- **Mitigation**: Multi-scale OCR, multiple passes, manual validation checkpoints

### Challenge 3: Ambiguous Component Readings
- **Issue**: Some readings may be legitimately different components
- **Mitigation**: Confidence scoring, flag ambiguous cases for manual review

### Challenge 4: Processing Time
- **Issue**: 5 passes × 17 images × 20s/image = ~30 minutes
- **Mitigation**: Checkpoint system, parallel processing (future), skip-existing flags

---

## 📝 Development Notes

### Session 1 (2026-01-23): Planning
- Analyzed existing fabric-image-analysis system
- Identified gap: multi-image consensus needed
- Created masterplan with 5 phases
- Documented architecture and deliverables

### Next Session: Phase 1 Foundation
- Start with HEIC conversion
- Test on 3 sample images
- Establish baseline metrics

---

## 🔗 Related Documentation

- [Multi-Session Work Protocol](../../skills/multi-session-work.md)
- [Fabric Image Analysis README](../../fabric-image-analysis/README.md)
- [Fabric Custom Patterns](../../fabric-custom-patterns/README.md)
- [Circuit Board Extraction Resume Skill](../../../.config/opencode/skills/circuit-board-extraction-resume.md)

---

## ✅ Completion Checklist

### Phase 1: Foundation
- [x] HEIC converter working
- [x] Baseline analysis complete
- [x] Sample outputs validated

### Phase 2: Aggregation
- [x] Component extraction working
- [x] Similarity grouping functional
- [x] Database structure validated

### Phase 3: Consensus
- [ ] 3 new patterns created
- [ ] Consensus builder tested
- [ ] Accuracy >90% on samples

### Phase 4: Refinement
- [ ] Re-analysis workflow working
- [ ] Improvement metrics documented
- [ ] Edge cases handled

### Phase 5: Synthesis
- [ ] Final document generated
- [ ] Quality validated
- [ ] System documented

### Project Complete
- [ ] All 5 phases complete
- [ ] Success metrics achieved
- [ ] Documentation finalized
- [ ] System ready for other use cases

---

**Last Updated**: 2026-01-23  
**Next Review**: After Phase 1 completion
