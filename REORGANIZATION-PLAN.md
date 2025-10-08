# Fabric Directory Reorganization Plan

**Date**: October 7, 2025  
**Goal**: Properly organize all fabric-related content within .myscripts

---

## Current Problem

Fabric-related files are scattered throughout `.myscripts/`:
- ❌ Scripts mixed with general scripts in root
- ❌ Patterns in separate `fabric-custom-patterns/` directory
- ❌ Docs mixed with other docs in `docs/`
- ❌ Hard to find fabric-specific content
- ❌ Clutters the main scripts directory

---

## Proposed Structure

```
.myscripts/
├── fabric/                          # NEW: All fabric content here
│   ├── patterns/                    # Custom patterns
│   │   ├── image-text-extraction/
│   │   ├── expert-ocr-engine/
│   │   ├── analyze-image-json/
│   │   ├── ultra-ocr-engine/
│   │   ├── multi-scale-ocr/
│   │   ├── deep_search_optimizer/
│   │   ├── search_query_generator/
│   │   ├── search_refiner/
│   │   ├── transcript-analyzer/
│   │   ├── transcript-refiner/
│   │   └── workflow-architect/
│   │
│   ├── scripts/                     # Fabric-specific scripts
│   │   ├── ocr-ing.sh
│   │   ├── fabric-vision-examples.sh
│   │   ├── test-fabric-vision.sh
│   │   ├── test-ocr-patterns.sh
│   │   └── ocr-quick-start.sh
│   │
│   ├── docs/                        # Fabric-specific documentation
│   │   ├── README.md                # Main fabric docs index
│   │   ├── Vision-Models-Guide.md
│   │   ├── Vision-Quick-Reference.md
│   │   ├── Vision-Investigation-Summary.md
│   │   ├── OCR-Resolution-Challenge-Analysis.md
│   │   ├── OCR-Solutions-Summary.md
│   │   └── Documentation-Strategy-Framework.md
│   │
│   └── README.md                    # Fabric project overview
│
├── [other scripts remain in root]
│   ├── clip.sh
│   ├── concat-any
│   ├── drives.sh
│   ├── flac2mp3.sh
│   ├── log_temps.sh
│   └── ...
│
├── docs/                            # General docs (non-fabric)
│   ├── Query-Optimizer-Project-Plan.md
│   ├── Structured Outputs Guide.md
│   └── ...
│
└── README.md                        # Main .myscripts README
```

---

## Migration Steps

### Step 1: Create Directory Structure
```bash
mkdir -p fabric/patterns
mkdir -p fabric/scripts
mkdir -p fabric/docs
```

### Step 2: Move Patterns
```bash
mv fabric-custom-patterns/* fabric/patterns/
rmdir fabric-custom-patterns
```

### Step 3: Move Scripts
```bash
mv fabric-vision-examples.sh fabric/scripts/
mv fabric-vision-summary.sh fabric/scripts/
mv test-fabric-vision.sh fabric/scripts/
mv test-ocr-patterns.sh fabric/scripts/
mv ocr-quick-start.sh fabric/scripts/
mv ocr-ing.sh fabric/scripts/
```

### Step 4: Move Documentation
```bash
mv docs/Fabric-Vision-*.md fabric/docs/
mv docs/OCR-*.md fabric/docs/
mv docs/Documentation-Strategy-Framework.md fabric/docs/
```

### Step 5: Update Fabric Config
```bash
# Link patterns directory to fabric config
ln -s ~/.myscripts/fabric/patterns ~/.config/fabric/patterns-custom
```

### Step 6: Create README files
- `fabric/README.md` - Main fabric project overview
- `fabric/docs/README.md` - Documentation index
- `fabric/patterns/README.md` - Pattern catalog (move existing)

---

## Configuration Updates Needed

### Fabric Pattern Path
Fabric needs to find custom patterns. Add to `~/.config/fabric/.env`:
```bash
# Custom patterns location
FABRIC_PATTERNS_USER_DIR=~/.myscripts/fabric/patterns
```

Or create symlink:
```bash
ln -s ~/.myscripts/fabric/patterns ~/.config/fabric/patterns/custom
```

### Script Path Updates
Update scripts that reference patterns:
- Change relative paths to use new structure
- Update documentation links

---

## Benefits

✅ **Clear Organization**: All fabric content in one place  
✅ **Easy Discovery**: `cd fabric/` to see everything  
✅ **Logical Grouping**: patterns / scripts / docs clearly separated  
✅ **Scalable**: Easy to add more patterns/scripts/docs  
✅ **Clean Root**: Main scripts directory not cluttered  
✅ **Maintainable**: Clear what belongs to fabric project  

---

## File Count

**Moving to fabric/**:
- 11 pattern directories → `fabric/patterns/`
- 6 scripts → `fabric/scripts/`
- 7 documentation files → `fabric/docs/`
- **Total**: 24 items organized

**Staying in root**: All non-fabric scripts remain accessible

---

## After Reorganization

### To run fabric scripts:
```bash
# From anywhere
~/.myscripts/fabric/scripts/test-ocr-patterns.sh image.jpg

# Or add to PATH
export PATH="$PATH:$HOME/.myscripts/fabric/scripts"
test-ocr-patterns.sh image.jpg
```

### To view fabric docs:
```bash
cat ~/.myscripts/fabric/docs/README.md
ls ~/.myscripts/fabric/docs/
```

### To work with patterns:
```bash
cd ~/.myscripts/fabric/patterns
ls
fabric -a image.jpg -p ultra-ocr-engine
```

---

## Testing After Migration

1. Verify patterns still work:
   ```bash
   fabric --listpatterns | grep ultra-ocr-engine
   ```

2. Test scripts:
   ```bash
   fabric/scripts/test-ocr-patterns.sh test-image.jpg
   ```

3. Check documentation links work

---

## Rollback Plan (if needed)

If issues arise, reverse migration:
```bash
mv fabric/patterns/* ./fabric-custom-patterns/
mv fabric/scripts/*.sh ./
mv fabric/docs/*.md ./docs/
rm -rf fabric/
```

---

## Implementation Script

See: `reorganize-fabric.sh` (will create next)

---

**Ready to execute?** This will create a clean, professional structure for the fabric project within your scripts directory.
