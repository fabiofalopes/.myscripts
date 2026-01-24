# Circuit Board Knowledge Extractor - Quick Reference

**Project**: Multi-pass OCR system for circuit board documentation  
**Status**: Planning complete, Phase 1 ready  
**Created**: 2026-01-23

---

## 📁 Key Files

### Read First
```bash
# Vision & architecture
~/.myscripts/docs/plans/CIRCUIT_BOARD_VISION.md

# Detailed development plan
~/.myscripts/docs/plans/CIRCUIT_BOARD_KNOWLEDGE_EXTRACTOR_MASTERPLAN.md

# Technical analysis
~/.myscripts/docs/plans/TECHNICAL_ANALYSIS.md

# Resume skill
~/.config/opencode/skills/circuit-board-extraction-resume.md
```

### Target Data
```bash
# 17 HEIC images to process
~/Desktop/drive-download-20260123T185902Z-3-001/Salto\ ncoder/
```

### Existing Infrastructure (Reuse)
```bash
# Pass 1 pipeline (reuse as-is)
~/.myscripts/fabric-image-analysis/workflows/image-metadata-pipeline.sh

# OCR patterns
~/.myscripts/fabric-custom-patterns/expert-ocr-engine/
~/.myscripts/fabric-custom-patterns/analyze-image-json/
```

---

## 🏗️ Architecture (5 Passes)

```
Pass 1: Individual Extraction → Per-image JSON
Pass 2: Aggregation → Component database
Pass 3: Consensus → Canonical component map
Pass 4: Cross-Validation → Refined JSON
Pass 5: Synthesis → Final markdown doc
```

---

## 🚀 Next Session Start

### Load Skill
```
Load skill: circuit-board-extraction-resume.md
```

### Start Phase 1
```
I'm ready to start Phase 1 of the Circuit Board Knowledge Extractor.

Tasks:
1. Create project structure
2. Write heic-to-jpeg-converter.sh
3. Convert 3 sample images
4. Test existing pipeline
5. Document baseline metrics

Let's begin with the HEIC converter script.
```

---

## 📋 Phase 1 Checklist

- [ ] heic-to-jpeg-converter.sh created
- [ ] 3 sample images converted (IMG_5935, 5937, 5946)
- [ ] Pipeline tested on samples
- [ ] JSON outputs validated
- [ ] Baseline OCR accuracy measured
- [ ] Error patterns documented
- [ ] BASELINE_ANALYSIS.md created

---

## 🎯 Success Criteria

- 90%+ OCR accuracy (vs. 60% baseline)
- 95%+ component coverage
- <3% false positive rate
- Human-readable final documentation

---

## 🔧 Required Tools

- [x] fabric-ai (v1.4.316+)
- [x] jq
- [x] bash 4.0+
- [ ] ImageMagick or heif-convert (for HEIC)

---

## 📊 Project Phases

1. **Foundation** (1-2 sessions) - HEIC conversion, baseline testing
2. **Aggregation** (1 session) - Component extraction and grouping
3. **Consensus** (2 sessions) - 4 new Fabric patterns
4. **Refinement** (1 session) - Re-analysis with consensus
5. **Synthesis** (1 session) - Final documentation generation

**Total**: 6-8 sessions

---

## 💡 Key Insights

- Reuse 90% of existing `fabric-image-analysis` code
- HEIC conversion is critical first step
- Multi-pass approach improves accuracy by 30%+
- Consensus building is the core innovation

---

## 🐛 Common Issues

**HEIC not converting**: Install ImageMagick `brew install imagemagick`  
**Pipeline fails**: Check format (must be .jpg/.jpeg/.png)  
**Poor OCR**: Try multi-scale-ocr pattern  
**JSON invalid**: Check with `cat file.json | jq .`

---

**Quick Ref Created**: 2026-01-23  
**See**: Full masterplan for detailed tasks and deliverables
