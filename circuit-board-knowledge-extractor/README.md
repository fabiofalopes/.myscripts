# Circuit Board Knowledge Extractor

**AI-powered multi-pass consensus OCR system for circuit board documentation**

---

## 🎯 What Is This?

An intelligent image analysis system that processes folders of circuit board photos to extract accurate technical documentation. Unlike single-pass OCR, this system:

- Processes **multiple images** of the same circuit board
- **Aggregates readings** across all images
- **Builds AI consensus** on component names
- **Iteratively refines** accuracy through 5 passes
- Generates **comprehensive documentation**

**Use Case**: Document circuit boards by taking photos from multiple angles and automatically extracting all technical information with high accuracy.

---

## ⚡ Quick Start

```bash
# Phase 1 (Current): Foundation & Validation
# Convert HEIC images and establish baseline

cd ~/.myscripts/circuit-board-knowledge-extractor
./workflows/heic-to-jpeg-converter.sh ~/Desktop/Salto\ encoder/

# Test on samples
./workflows/circuit-board-extractor.sh data/converted/
```

**Status**: 🏗️ Planning complete, Phase 1 in progress

---

## 📊 How It Works

### 5-Pass Architecture

```
Pass 1: Individual Extraction
  └─ Run OCR on each image independently
  └─ Output: Per-image JSON files

Pass 2: Component Aggregation
  └─ Extract all components from JSON
  └─ Group similar readings (fuzzy matching)
  └─ Output: component-database.json

Pass 3: Consensus Building
  └─ AI analyzes component variants
  └─ Determines canonical names
  └─ Output: canonical-components.json

Pass 4: Cross-Validation
  └─ Re-analyze images with consensus knowledge
  └─ Refine uncertain readings
  └─ Output: Refined JSON files

Pass 5: Final Synthesis
  └─ Generate comprehensive documentation
  └─ Output: BOARD_ANALYSIS.md
```

### Example Workflow

**Input**: 17 photos of a Salto encoder board (different angles, zoom levels)

**Processing**:
- Pass 1 finds: `["STM32F103", "STM32F1O3", "STM32F103C", "STM32F103C8T6"]`
- Pass 2 groups similar readings: `{variants: 4, frequency: [5,1,3,8]}`
- Pass 3 determines canonical: `"STM32F103C8T6"` (confidence: 0.92)
- Pass 4 re-checks images with this knowledge
- Pass 5 generates final documentation

**Output**: 
```markdown
# Salto Encoder Analysis

## Component Inventory
- STM32F103C8T6 (ARM Cortex-M3 microcontroller)
  - Confidence: 0.92
  - Found in: 8 of 17 images
  - Location: Center of board
...
```

---

## 🏗️ Architecture

### Reuses Existing Infrastructure
- **fabric-image-analysis**: 6-stage sequential pipeline (Pass 1)
- **Fabric custom patterns**: OCR and analysis patterns
- **Context-aware mode**: Manual context injection

### New Components (Building)
- **HEIC converter**: Batch image format conversion
- **Component aggregator**: Extract and group components (jq-based)
- **Consensus builder**: 4 new Fabric patterns for AI consensus
- **Synthesis generator**: Final documentation creator

---

## 📁 Project Structure

```
circuit-board-knowledge-extractor/
├── README.md                    # This file
├── workflows/                   # Processing scripts
│   ├── heic-to-jpeg-converter.sh
│   ├── circuit-board-extractor.sh (main orchestrator)
│   ├── component-aggregator.sh
│   ├── consensus-builder.sh
│   ├── re-analyze-with-consensus.sh
│   └── synthesis-generator.sh
├── lib/                         # Utilities
│   ├── extract-components.jq
│   ├── similarity-matcher.sh
│   └── utils.sh
├── data/                        # Processing data (gitignored)
│   ├── source/                  # Original HEIC files
│   ├── converted/               # JPEG files
│   ├── pass1/                   # Initial JSON
│   ├── pass2/                   # Aggregated data
│   ├── pass3/                   # Consensus
│   ├── pass4/                   # Refined JSON
│   └── pass5/                   # Final output
├── docs/                        # Documentation
│   ├── ARCHITECTURE.md
│   ├── USAGE.md
│   ├── BASELINE_ANALYSIS.md
│   └── IMPROVEMENT_METRICS.md
└── test/                        # Test images
    └── samples/
```

---

## 📋 Development Phases

### ✅ Phase 0: Planning (Complete)
- Vision and architecture defined
- Masterplan with detailed tasks
- Technical analysis of existing systems

### 🔲 Phase 1: Foundation & Validation (Current)
**Goal**: Convert images and establish baseline

- [ ] HEIC to JPEG converter
- [ ] Test on 3 sample images
- [ ] Baseline OCR accuracy metrics
- [ ] Error pattern documentation

### 🔲 Phase 2: Component Aggregation
**Goal**: Extract and group components across images

- [ ] Component extraction (jq script)
- [ ] Similarity grouping (fuzzy matching)
- [ ] Component database generation

### 🔲 Phase 3: Consensus Building
**Goal**: Create AI patterns for consensus

- [ ] `component-consensus-builder` pattern
- [ ] `ocr-error-detector` pattern
- [ ] `technical-identifier-validator` pattern
- [ ] Consensus orchestrator script

### 🔲 Phase 4: Cross-Validation
**Goal**: Re-analyze with consensus knowledge

- [ ] Enhanced context-aware patterns
- [ ] Re-analysis workflow
- [ ] Improvement metrics

### 🔲 Phase 5: Final Synthesis
**Goal**: Generate comprehensive documentation

- [ ] `circuit-board-synthesizer` pattern
- [ ] Synthesis generator script
- [ ] Final documentation template

---

## 🎯 Success Metrics

### Quantitative
- **OCR Accuracy**: 60% (baseline) → 90%+ (target)
- **Component Coverage**: 95%+ of visible components
- **False Positive Rate**: <3%
- **Processing Time**: <2 minutes per image (total pipeline)

### Qualitative
- Human-readable, trustworthy documentation
- Complete audit trail (source tracking)
- Confidence scoring for all readings
- Reusable for other circuit boards

---

## 📚 Documentation

### Planning Documents
Located in `~/.myscripts/docs/plans/`:
- **CIRCUIT_BOARD_VISION.md**: High-level architecture and philosophy
- **CIRCUIT_BOARD_KNOWLEDGE_EXTRACTOR_MASTERPLAN.md**: Detailed phase plan
- **TECHNICAL_ANALYSIS.md**: Existing system analysis
- **SESSION_1_SUMMARY.md**: Session notes
- **QUICK_REFERENCE.md**: Quick reference card

### Resume Skill
Located in `~/.config/opencode/skills/`:
- **circuit-board-extraction-resume.md**: Multi-session resume guide

---

## 🔧 Requirements

### Tools
- **fabric-ai** v1.4.316+ - AI processing engine
- **jq** - JSON processor
- **ImageMagick** or **heif-convert** - HEIC conversion
- **bash** 4.0+ - Shell scripting

### APIs
- **Groq API** - For llama-4-maverick vision model
- Configured via `~/.config/fabric/.env`

---

## 🚀 Usage (When Complete)

```bash
# Full pipeline (all 5 passes)
./workflows/circuit-board-extractor.sh ~/path/to/circuit-photos/

# Individual passes
./workflows/heic-to-jpeg-converter.sh source/
./workflows/component-aggregator.sh pass1/*.json
./workflows/consensus-builder.sh component-database.json
./workflows/synthesis-generator.sh pass4/*.json

# Options
VERBOSE=true ./workflows/circuit-board-extractor.sh photos/
SKIP_EXISTING=true ./workflows/circuit-board-extractor.sh photos/
```

---

## 🎓 Learning & Reusability

This system demonstrates:
- Multi-image consensus building
- Progressive AI refinement
- Complex Fabric workflow orchestration
- OCR error handling strategies

**Applicable to**:
- Receipt batches (multiple receipts of same type)
- Document sets (multiple scans)
- Product photography (different angles)
- Historical documents (multiple photos)
- Quality control (defect detection)

---

## 🐛 Troubleshooting

### HEIC Conversion Fails
```bash
# Install ImageMagick
brew install imagemagick

# Test
magick convert test.HEIC test.jpg
```

### Pipeline Fails on Images
```bash
# Check format
file image.jpg  # Should be JPEG

# Verify fabric-ai works
echo "test" | fabric-ai -p expert-ocr-engine
```

### Poor OCR Quality
- Check image clarity (not blurry)
- Ensure good lighting
- Try different angles/zoom levels
- Use VERBOSE=true for debugging

### JSON Validation Errors
```bash
# Validate manually
cat output.json | jq .

# Check error log
cat pipeline-errors.log
```

---

## 🤝 Contributing

This is a personal project but demonstrates patterns useful for:
- Fabric community (new pattern types)
- Multi-image AI workflows
- OCR consensus techniques

---

## 📝 Development Notes

### Current Phase: Phase 1
**Next Steps**:
1. Create HEIC converter script
2. Convert 3 sample images
3. Test existing pipeline
4. Establish baseline metrics

### Multi-Session Development
This project uses the multi-session protocol:
- Each session updates the masterplan
- Progress tracked via checkboxes
- Documentation = source of truth
- Resume skill guides continuation

**To Resume Work**:
```
Load skill: circuit-board-extraction-resume.md
```

---

## 🔗 Related Projects

- **fabric-image-analysis**: Base pipeline for Pass 1
- **fabric-custom-patterns**: Pattern library
- **Fabric**: https://github.com/danielmiessler/fabric

---

## 📄 License

[Your License Here]

---

## 🎯 Project Status

**Created**: 2026-01-23  
**Status**: Phase 1 - Foundation & Validation  
**Completion**: Planning 100%, Implementation 0%

**Next Milestone**: Phase 1 complete (HEIC conversion + baseline)

---

**Built with**: Fabric AI, Groq, LLaMA, jq, ImageMagick  
**Designed for**: Multi-session AI-assisted development
