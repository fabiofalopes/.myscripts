# Migration Notes: Fabric Image Analysis Pipeline

**Date**: October 30, 2025  
**From**: `ubiquity-air-router-images/` (development folder)  
**To**: `MyScripts/fabric-image-analysis/` (production location)

---

## Migration Overview

This project was developed within the Ubiquiti router documentation folder but is a **standalone, reusable image processing utility**. It's ready to be migrated to your permanent scripts repository.

---

## What's Being Migrated

### ✅ Production-Ready Components

#### 1. Main Workflow Script
**File**: `image-metadata-pipeline.sh`  
**Status**: Fully functional, tested with 20+ images  
**Features**:
- 6-stage sequential processing pipeline
- Validation and error handling at every stage
- Batch processing with progress tracking
- Context-aware mode (Phase 2)
- Comprehensive logging

**Destination**: `MyScripts/fabric-image-analysis/workflows/`

#### 2. Custom Fabric Patterns
**Location**: `custom-patterns/`  
**Patterns**:
- `analyze-image-json-with-context/` - Main analysis with context
- `expert-ocr-with-context/` - Specialized OCR
- `multi-scale-ocr-with-context/` - Multi-resolution OCR

**Note**: These patterns reference the standard fabric patterns but add context awareness.

**Destination**: 
- Copy to `MyScripts/fabric-image-analysis/fabric-custom-patterns/`
- Also install to `~/.config/fabric/patterns/` for fabric-ai to find them

#### 3. Documentation
**Files to migrate**:
- `README.md` - Project overview (rewritten for migration)
- `QUICK-START.md` - Usage guide
- `ARCHITECTURE.md` - System design
- `PHASE-2-COMPLETE.md` - Phase 2 implementation details
- `PHASE-2-RESULTS-SUMMARY.md` - Test results
- `COST-OPTIMIZATION.md` - Model selection strategy

**Destination**: `MyScripts/fabric-image-analysis/docs/`

---

## What's NOT Being Migrated

### 🗑️ Development Artifacts (Leave Behind)

These files were useful during development but aren't needed in production:

- `DEVELOPMENT-PHASES.md` - Historical planning
- `PHASE-2-KICKSTART-PROMPT.md` - Development prompts
- `PHASE-2-RESEARCH.md` - Research notes
- `PHASE-2-STATUS.md` - Development status tracking
- `PHASE-2-VISION.md` - Initial vision document
- `PHASE-2-HANDOFF.md` - Handoff notes
- `PHASE-2-FINDINGS.md` - Research findings
- `PIPELINE-DESIGN.md` - Superseded by ARCHITECTURE.md
- `IMPLEMENTATION.md` - Build guide (no longer needed)
- `REQUIREMENTS.md` - Merged into README
- `UTILITIES.md` - Separate utilities (not part of core)
- `fabric-ai-cheatsheet.md` - General reference
- `FABRIC-REFERENCE.md` - General reference
- `PROJECT-STATUS.md` - Development tracking
- `DOC-INDEX.md` - Development index
- `system-devops-ocr-llm-pipeline-idea.md` - Initial brainstorming

### 📁 Test Data (Leave Behind)
- `images/` - Test images specific to Ubiquiti project
- `test-output/` - Test results
- `*.jpg.json` - Generated test metadata
- `pipeline-errors.log` - Test error logs

**Why leave behind?** These are specific to the Ubiquiti router project. The migrated version should start fresh with its own test data.

---

## Migration Steps

### 1. Create Target Structure

```bash
cd ~/Documents/projetos/hub/.myscripts/
mkdir -p fabric-image-analysis/{workflows,fabric-custom-patterns,docs}
```

### 2. Copy Production Files

```bash
# Main script
cp ubiquity-air-router-images/image-metadata-pipeline.sh \
   fabric-image-analysis/workflows/

# Custom patterns
cp -r ubiquity-air-router-images/custom-patterns/* \
   fabric-image-analysis/fabric-custom-patterns/

# Documentation
cp ubiquity-air-router-images/MIGRATION-PACKAGE/README.md \
   fabric-image-analysis/
cp ubiquity-air-router-images/QUICK-START.md \
   fabric-image-analysis/docs/
cp ubiquity-air-router-images/ARCHITECTURE.md \
   fabric-image-analysis/docs/
cp ubiquity-air-router-images/PHASE-2-COMPLETE.md \
   fabric-image-analysis/docs/
cp ubiquity-air-router-images/PHASE-2-RESULTS-SUMMARY.md \
   fabric-image-analysis/docs/
cp ubiquity-air-router-images/COST-OPTIMIZATION.md \
   fabric-image-analysis/docs/
```

### 3. Install Custom Patterns to Fabric

```bash
# Install patterns so fabric-ai can find them
cp -r fabric-image-analysis/fabric-custom-patterns/* \
   ~/.config/fabric/patterns/

# Verify installation
fabric-ai --listpatterns | grep -E "(analyze-image-json-with-context|expert-ocr-with-context|multi-scale-ocr-with-context)"
```

### 4. Make Script Executable

```bash
chmod +x fabric-image-analysis/workflows/image-metadata-pipeline.sh
```

### 5. Test in New Location

```bash
# Create test directory
mkdir -p fabric-image-analysis/test-images

# Copy a test image
cp ubiquity-air-router-images/images/IMG_5624.jpg \
   fabric-image-analysis/test-images/

# Run pipeline
cd fabric-image-analysis
./workflows/image-metadata-pipeline.sh test-images/

# Verify output
cat test-images/IMG_5624.jpg.json | jq .
```

### 6. Clean Up Development Folder

```bash
# Archive development artifacts
cd ubiquity-air-router-images
mkdir -p ARCHIVE
mv DEVELOPMENT-PHASES.md PHASE-2-*.md PIPELINE-DESIGN.md \
   IMPLEMENTATION.md REQUIREMENTS.md UTILITIES.md \
   fabric-ai-cheatsheet.md FABRIC-REFERENCE.md \
   PROJECT-STATUS.md DOC-INDEX.md \
   system-devops-ocr-llm-pipeline-idea.md \
   ARCHIVE/

# Keep only project-specific files
# - images/ (Ubiquiti router photos)
# - test-output/ (test results)
# - README.md (project-specific readme)
```

---

## Post-Migration Configuration

### Update Script Paths (if needed)

The script uses relative paths and should work as-is, but verify:

```bash
# Check pattern references in script
grep -n "PATTERN_" workflows/image-metadata-pipeline.sh

# Patterns should be referenced by name only (fabric-ai finds them)
# Example: fabric-ai -p analyze-image-json-with-context
```

### Add to PATH (optional)

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/Documents/projetos/hub/.myscripts/fabric-image-analysis/workflows:$PATH"

# Now you can run from anywhere
image-metadata-pipeline.sh ~/Pictures/hardware-photos/
```

---

## Pattern Location Strategy

### Current Setup (Correct)

The script references patterns **by name only**, and fabric-ai finds them in:
```
~/.config/fabric/patterns/
```

This is the correct approach because:
- ✅ Patterns are globally available
- ✅ No hardcoded paths in scripts
- ✅ Works from any directory
- ✅ Standard fabric pattern location

### What We Fixed

**Before** (in old experimental scripts):
```bash
# ❌ Wrong: Referenced local directory
CUSTOM_PATTERNS_DIR="$SCRIPT_DIR/custom-patterns"
fabric-ai -p "$CUSTOM_PATTERNS_DIR/analyze-image-json-with-context"
```

**After** (current production script):
```bash
# ✅ Correct: Reference by name, fabric finds it
fabric-ai -p analyze-image-json-with-context
```

---

## Verification Checklist

After migration, verify:

- [ ] Script runs from new location
- [ ] Custom patterns are found by fabric-ai
- [ ] Test image processes successfully
- [ ] JSON output is valid and complete
- [ ] Error logging works
- [ ] Context-aware mode works (if enabled)
- [ ] Documentation is accessible
- [ ] No hardcoded paths in scripts

---

## Known Issues & Solutions

### Issue 1: Pattern Not Found
**Symptom**: `fabric-ai: pattern 'analyze-image-json-with-context' not found`

**Solution**:
```bash
# Install patterns to fabric directory
cp -r fabric-custom-patterns/* ~/.config/fabric/patterns/

# Verify
fabric-ai --listpatterns | grep analyze-image-json-with-context
```

### Issue 2: HTTP Timeout Warnings
**Symptom**: `Invalid HTTP timeout format ("14"), using default (20m)`

**Solution**:
```bash
# Fix fabric configuration
echo "OLLAMA_HTTP_TIMEOUT=14m" >> ~/.config/fabric/.env
```

### Issue 3: 413 Request Entity Too Large
**Symptom**: Error when using context mode

**Solution**: The script already handles this correctly by using manual context injection instead of fabric sessions. No action needed.

---

## Rollback Plan

If migration causes issues:

```bash
# 1. Keep original folder intact until migration is verified
# 2. If issues occur, use original location:
cd ~/path/to/ubiquity-air-router-images
./image-metadata-pipeline.sh images/

# 3. Debug new location without affecting original
```

---

## Future Maintenance

### Updating Patterns

When modifying patterns:

```bash
# 1. Edit in project folder
vim fabric-image-analysis/fabric-custom-patterns/analyze-image-json-with-context/system.md

# 2. Reinstall to fabric
cp -r fabric-image-analysis/fabric-custom-patterns/* \
   ~/.config/fabric/patterns/

# 3. Test
fabric-ai -a test.jpg -p analyze-image-json-with-context
```

### Updating Script

```bash
# Edit script
vim fabric-image-analysis/workflows/image-metadata-pipeline.sh

# Test with single image first
./workflows/image-metadata-pipeline.sh test-images/test.jpg

# Then test batch
./workflows/image-metadata-pipeline.sh test-images/
```

---

## Success Criteria

Migration is successful when:

1. ✅ Script runs from new location without errors
2. ✅ All custom patterns are found by fabric-ai
3. ✅ Test image processes and generates valid JSON
4. ✅ Documentation is clear and accessible
5. ✅ No references to old development folder
6. ✅ Context-aware mode works (if enabled)
7. ✅ Error handling and logging work correctly

---

## Notes for Future Use

### This is a Reusable Utility

The migrated pipeline is **not specific to Ubiquiti routers**. It can process any images:

- Hardware documentation photos
- Circuit board analysis
- Equipment inventory
- Technical diagrams
- Product photography
- Any images needing AI-powered metadata extraction

### Customization Points

To adapt for different use cases:

1. **Patterns** - Modify prompts in `fabric-custom-patterns/` for domain-specific analysis
2. **Models** - Change `VISION_MODEL` and `TEXT_MODEL` environment variables
3. **Output Format** - Modify JSON structure in `aggregate_json()` function
4. **Validation** - Adjust validation rules for your data requirements

---

## Contact & Support

For issues or questions:
- Check `docs/QUICK-START.md` for common solutions
- Review `docs/ARCHITECTURE.md` for system understanding
- Check `pipeline-errors.log` for error details
- Test patterns individually with `fabric-ai -a image.jpg -p pattern-name`

---

**Migration Status**: Ready to execute  
**Confidence Level**: High (script is tested and working)  
**Risk Level**: Low (original folder remains intact)
