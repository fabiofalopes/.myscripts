# HEIC2JPG Quick Reference

**Script**: `heic2jpg.sh`
**Status**: 🟡 In Development
**Pattern**: Based on `flac2mp3.sh`

---

## Quick Commands

### Development
```bash
# Resume work on this project
Load skill: heic2jpg-resume

# Check current status
grep "^- \[ \]" ~/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md | head -1

# Read masterplan
cat ~/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md
```

### Testing (once implemented)
```bash
# Basic usage
heic2jpg.sh ~/Pictures/iPhone_Photos

# With quality setting
heic2jpg.sh ~/Pictures/iPhone_Photos 95

# Test with sample
mkdir -p ~/test-heic2jpg/images
heic2jpg.sh ~/test-heic2jpg/images
```

---

## File Locations

| File | Path | Purpose |
|------|------|---------|
| **Masterplan** | `~/.myscripts/docs/plans/HEIC2JPG_MASTERPLAN.md` | Complete project spec |
| **Resume Skill** | `~/.myscripts/skills/heic2jpg-resume.md` | Session resumption guide |
| **Script** | `~/.myscripts/heic2jpg.sh` | Main script (to be created) |
| **Reference** | `~/.myscripts/flac2mp3.sh` | Pattern to follow |
| **Quick Ref** | `~/.myscripts/docs/heic2jpg-quickref.md` | This file |

---

## Implementation Phases

| Phase | Tasks | Status |
|-------|-------|--------|
| **1. Core Development** | 1.1 - 1.10 | ⬜ Not started |
| **2. Documentation** | 2.1 - 2.5 | ⬜ Not started |
| **3. Testing** | 3.1 - 3.10 | ⬜ Not started |
| **4. Polish** | 4.1 - 4.5 | ⬜ Not started |

---

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Conversion Tool** | ImageMagick + fallback | Most common, widely available |
| **Feature Set** | Enhanced | Full functionality |
| **Quality** | 90% default, configurable | Balance size/quality |
| **Metadata** | Preserve EXIF | Keep photo info |
| **Error Handling** | Robust | Skip bad files, log, continue |

---

## Dependencies

### Installation Commands

**Debian/Ubuntu**:
```bash
sudo apt install imagemagick libheif-dev libheif-examples
```

**macOS**:
```bash
brew install imagemagick libheif
```

### Verification
```bash
# Check ImageMagick
convert -version
convert -list format | grep HEIC

# Check heif-convert
heif-convert --version
```

---

## Usage Examples (Future)

```bash
# Convert all HEIC files in a directory
heic2jpg.sh ~/Pictures/iPhone_Photos

# Specify quality (1-100)
heic2jpg.sh ~/Pictures/iPhone_Photos 85

# Output goes to:
# ~/Pictures/iPhone_Photos/jpg_output/

# Error log (if errors):
# ~/Pictures/iPhone_Photos/jpg_output/conversion_errors.log
```

---

## Next Steps

**To start implementation**:
1. Load skill: `heic2jpg-resume`
2. Read masterplan
3. Begin Phase 1.1
4. Follow the plan

**To resume later**:
1. Load skill: `heic2jpg-resume`
2. Check current status
3. Continue from next unchecked task

---

**Created**: 2026-01-23
**Last Updated**: 2026-01-23
