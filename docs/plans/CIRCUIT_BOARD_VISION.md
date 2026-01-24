# Circuit Board Knowledge Extraction - Project Vision

**Created**: 2026-01-23  
**Status**: Active Development  
**Type**: Multi-Session Project

---

## 🎯 The Big Picture

### What Are We Building?

An intelligent **multi-pass consensus-based OCR system** specifically designed for circuit board documentation. Think of it as an AI archaeologist that looks at multiple photos of the same artifact (circuit board) and pieces together the most accurate understanding of what's actually there.

### Why Does This Matter?

**The Problem**: When you use AI vision models to read text on circuit boards:
- Small component labels are hard to read
- OCR makes mistakes (O→0, I→1, 8→B)
- The same component gets read differently in different photos
- Manual verification is tedious and error-prone

**The Solution**: 
Instead of trusting a single reading, we:
1. Process multiple photos of the same board
2. Extract all possible readings of each component
3. Use AI to build consensus on the "true" reading
4. Generate a comprehensive, accurate documentation

### Real-World Use Case

**Target**: Salto Encoder circuit board
- 17 photos from different angles
- Hundreds of tiny component labels
- Goal: Create complete component inventory and technical documentation

---

## 🏗️ Architecture Philosophy

### Core Concept: Multi-Pass Refinement

```
Pass 1: Individual Truth
   ↓ (each image analyzed independently)
Pass 2: Collective Patterns  
   ↓ (aggregate all readings, find patterns)
Pass 3: Consensus Reality
   ↓ (AI determines most likely true readings)
Pass 4: Informed Re-analysis
   ↓ (re-check images with consensus knowledge)
Pass 5: Final Synthesis
   ↓ (comprehensive documentation)
```

### Design Principles

1. **Progressive Refinement**: Each pass improves accuracy
2. **Evidence-Based**: Multiple readings = higher confidence
3. **Transparent**: All intermediate data saved for review
4. **Modular**: Each pass is independent, reusable
5. **Extensible**: Easy to add new analysis types

---

## 🔄 How It Works (High Level)

### Pass 1: Individual Extraction
```
For each image:
  - Run existing fabric-image-analysis pipeline
  - Extract all visible text (OCR)
  - Identify components, labels, specifications
  - Save to JSON file
```

**Output**: 17 JSON files with raw extractions

### Pass 2: Aggregation
```
Across all images:
  - Extract all component mentions
  - Group similar readings (fuzzy matching)
  - Calculate frequencies
  - Build component database
```

**Output**: `component-database.json` with variant groups

Example:
```json
{
  "groups": [
    {
      "variants": ["STM32F103", "STM32F1O3", "STM32F103C"],
      "frequency": [5, 1, 3],
      "confidence": 0.75
    }
  ]
}
```

### Pass 3: Consensus Building
```
For each component group:
  - Send variants to AI (Fabric pattern)
  - AI analyzes context and patterns
  - Determines most likely canonical name
  - Flags uncertain cases
```

**Output**: `canonical-components.json`

Example:
```json
{
  "canonical": "STM32F103C8T6",
  "variants_resolved": ["STM32F103", "STM32F1O3", "STM32F103C"],
  "confidence": 0.92,
  "reasoning": "STM32F103 is consistent pattern, '1O3' is OCR error (O→0)"
}
```

### Pass 4: Cross-Validation
```
Re-analyze images with consensus knowledge:
  - "You previously identified STM32F103, canonical is STM32F103C8T6"
  - AI refines analysis with this context
  - Improves accuracy on uncertain readings
```

**Output**: Refined JSON files

### Pass 5: Synthesis
```
Generate final documentation:
  - Comprehensive component inventory
  - Board layout description
  - Technical specifications
  - Confidence metrics
  - Source references
```

**Output**: `SALTO_ENCODER_ANALYSIS.md`

---

## 🎨 Key Innovations

### 1. **Consensus Patterns** (New)
Custom Fabric patterns that understand OCR errors:
- `component-consensus-builder`: Determines canonical names
- `ocr-error-detector`: Flags likely OCR mistakes
- `technical-identifier-validator`: Validates against known patterns

### 2. **Multi-Pass Context**
Unlike single-pass OCR:
- Pass 1: No assumptions
- Pass 4: "Here's what we learned, look again"

### 3. **Evidence Tracking**
Every claim is backed by:
- Which images it appeared in
- How many times
- Confidence score
- Alternative readings

### 4. **Human-in-the-Loop Ready**
System flags uncertain cases:
- Low confidence readings
- Ambiguous groupings
- Conflicting evidence

---

## 💡 Example Workflow

### Input
```
~/Desktop/Salto encoder/
  ├── IMG_5935.HEIC (close-up of microcontroller)
  ├── IMG_5936.HEIC (wide shot of board)
  ├── IMG_5937.HEIC (capacitor labels)
  └── ... (14 more images)
```

### Execution
```bash
cd ~/.myscripts/circuit-board-knowledge-extractor
./workflows/circuit-board-extractor.sh ~/Desktop/Salto\ encoder/
```

### Process (Automated)
```
[1/5] Converting HEIC → JPEG... ✓
[2/5] Individual extraction (Pass 1)...
  Processing IMG_5935.jpg... ✓ (found 23 components)
  Processing IMG_5936.jpg... ✓ (found 18 components)
  ... (15 more)
[3/5] Aggregating components (Pass 2)... ✓ (87 unique groups)
[4/5] Building consensus (Pass 3)... ✓ (82 canonical, 5 flagged)
[5/5] Re-analyzing with consensus (Pass 4)... ✓
[6/5] Generating synthesis... ✓

Output: data/pass5/SALTO_ENCODER_ANALYSIS.md
```

### Output Document
```markdown
# Salto Encoder Circuit Board Analysis

## Overview
STM32-based encoder board with power management and sensor interfaces.

## Component Inventory

### Microcontrollers
- **STM32F103C8T6** (ARM Cortex-M3)
  - Confidence: 0.95
  - Found in: 5 images
  - Location: Center of board

### Power Components
- **LM1117-3.3** (Voltage Regulator)
  - Confidence: 0.88
  - Found in: 3 images
  
... (continued)

## Metadata
- Images analyzed: 17
- Components identified: 82
- Average confidence: 0.89
- Processing time: 28 minutes
```

---

## 🚀 Future Enhancements

### Phase 6: Interactive Refinement
- Web UI for reviewing flagged components
- Manual correction interface
- Re-run with corrections

### Phase 7: Knowledge Base
- Build database of known components
- Auto-validate against datasheets
- Suggest specifications

### Phase 8: Multi-Board Analysis
- Compare multiple circuit boards
- Identify common components
- Generate BOM (Bill of Materials)

### Phase 9: Schematic Generation
- Use layout analysis + component data
- Generate preliminary schematic
- Export to CAD formats

---

## 🔗 Relationship to Existing Work

### Builds On
- **fabric-image-analysis**: Reuses entire pipeline as Pass 1
- **Fabric custom patterns**: Extends with 4 new consensus patterns
- **Context-aware mode**: Leverages for Pass 4 re-analysis

### Extends
- Multi-image processing (vs. single image)
- Consensus building (vs. single reading)
- Iterative refinement (vs. one-shot)

### Complements
- Can be used for other multi-image scenarios:
  - Receipt batches (mentioned by user)
  - Document sets
  - Product photos
  - Archaeological artifacts

---

## 📊 Expected Outcomes

### Quantitative Improvements
- **OCR Accuracy**: 60% (single pass) → 90% (consensus)
- **Component Coverage**: 70% → 95%
- **False Positives**: 15% → 3%

### Qualitative Benefits
- Trustworthy documentation
- Audit trail (which image said what)
- Confidence scoring
- Reusable for other boards

---

## 🎓 Learning & Reusability

This system teaches us:
1. How to build consensus from multiple AI readings
2. Patterns for multi-pass refinement
3. Techniques for handling OCR errors
4. Architecture for complex Fabric workflows

Reusable for:
- Medical imaging (multiple scans)
- Historical document analysis
- Inventory management (multiple photos per item)
- Quality control (defect detection across images)

---

## 📝 Development Philosophy

### Multi-Session Mindset
- **This is too big for one session**
- Each phase is a checkpoint
- Documentation = progress tracking
- Files are the source of truth

### Iterative Development
- Start small (3 images)
- Validate each phase
- Scale gradually
- Learn and adapt

### Quality Over Speed
- Measure accuracy at each phase
- Manual validation checkpoints
- Don't skip testing
- Document what works and what doesn't

---

## 🎯 Success Definition

**This project succeeds when:**

1. ✅ We can point it at a folder of circuit board photos
2. ✅ It automatically generates accurate documentation
3. ✅ Accuracy is measurably better than single-pass OCR
4. ✅ The system is reusable for other boards
5. ✅ A human can review and trust the output

**Bonus Success:**
- System becomes a template for other multi-image AI workflows
- Patterns are contributed back to Fabric community
- Documentation helps others solve similar problems

---

**Vision Established**: 2026-01-23  
**Next**: Begin Phase 1 - Foundation & Validation
