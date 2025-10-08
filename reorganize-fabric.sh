#!/bin/bash

# Fabric Directory Reorganization Script
# Moves all fabric-related content into organized fabric/ directory

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                                                                ║${RESET}"
echo -e "${BLUE}║        Fabric Directory Reorganization Script                  ║${RESET}"
echo -e "${BLUE}║                                                                ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}This script will reorganize fabric-related content:${RESET}"
echo ""
echo "  • Move fabric-custom-patterns/ → fabric/patterns/"
echo "  • Move fabric scripts → fabric/scripts/"
echo "  • Move fabric docs → fabric/docs/"
echo "  • Create proper README files"
echo ""
echo -e "${YELLOW}Current directory: ${SCRIPT_DIR}${RESET}"
echo ""

# Safety check
if [ ! -d "$SCRIPT_DIR/fabric-custom-patterns" ]; then
    echo -e "${RED}Error: fabric-custom-patterns directory not found${RESET}"
    echo "Are you running this from .myscripts directory?"
    exit 1
fi

# Confirm
echo -e "${YELLOW}This will modify your directory structure.${RESET}"
echo -e "${YELLOW}A backup will be created: fabric-backup-$(date +%Y%m%d_%H%M%S).tar.gz${RESET}"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${CYAN}Creating backup...${RESET}"

# Create backup
BACKUP_FILE="fabric-backup-$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$BACKUP_FILE" \
    fabric-custom-patterns/ \
    fabric-*.sh \
    test-fabric-vision.sh \
    test-ocr-patterns.sh \
    ocr-quick-start.sh \
    ocr-ing.sh \
    docs/Fabric-*.md \
    docs/OCR-*.md \
    docs/Documentation-Strategy-Framework.md \
    2>/dev/null || true

echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${RESET}"
echo ""

# Step 1: Create directory structure
echo -e "${CYAN}[1/6] Creating directory structure...${RESET}"
mkdir -p fabric/patterns
mkdir -p fabric/scripts
mkdir -p fabric/docs
echo -e "${GREEN}✓ Directories created${RESET}"
echo ""

# Step 2: Move patterns
echo -e "${CYAN}[2/6] Moving patterns...${RESET}"
if [ -d "fabric-custom-patterns" ]; then
    mv fabric-custom-patterns/* fabric/patterns/ 2>/dev/null || true
    rmdir fabric-custom-patterns 2>/dev/null || rm -rf fabric-custom-patterns
    echo -e "${GREEN}✓ Patterns moved to fabric/patterns/${RESET}"
else
    echo -e "${YELLOW}⚠ fabric-custom-patterns not found${RESET}"
fi
echo ""

# Step 3: Move scripts
echo -e "${CYAN}[3/6] Moving scripts...${RESET}"

SCRIPTS=(
    "fabric-vision-examples.sh"
    "fabric-vision-summary.sh"
    "test-fabric-vision.sh"
    "test-ocr-patterns.sh"
    "ocr-quick-start.sh"
    "ocr-ing.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        mv "$script" fabric/scripts/
        echo -e "  ${GREEN}✓${RESET} Moved $script"
    else
        echo -e "  ${YELLOW}⚠${RESET} $script not found"
    fi
done
echo ""

# Step 4: Move documentation
echo -e "${CYAN}[4/6] Moving documentation...${RESET}"

DOCS=(
    "docs/Fabric-Vision-Index.md"
    "docs/Fabric-Vision-Investigation-Summary.md"
    "docs/Fabric-Vision-Models-Guide.md"
    "docs/Fabric-Vision-Quick-Reference.md"
    "docs/OCR-Resolution-Challenge-Analysis.md"
    "docs/OCR-Solutions-Summary.md"
    "docs/Documentation-Strategy-Framework.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        mv "$doc" fabric/docs/
        echo -e "  ${GREEN}✓${RESET} Moved $(basename $doc)"
    else
        echo -e "  ${YELLOW}⚠${RESET} $doc not found"
    fi
done
echo ""

# Step 5: Create README files
echo -e "${CYAN}[5/6] Creating README files...${RESET}"

# Main fabric README
cat > fabric/README.md << 'EOF'
# Fabric Project

**Purpose**: AI-powered text processing and analysis using the fabric framework

This directory contains all fabric-related content: custom patterns, utility scripts, and comprehensive documentation.

---

## Directory Structure

```
fabric/
├── patterns/          # Custom AI patterns for fabric
├── scripts/           # Fabric utility scripts
├── docs/              # Comprehensive documentation
└── README.md          # This file
```

---

## Quick Start

### Using Patterns

```bash
# List available custom patterns
fabric --listpatterns

# Use a vision pattern
fabric -a image.jpg -p ultra-ocr-engine

# Use a search pattern
echo "quantum computing" | fabric -p deep_search_optimizer
```

### Testing OCR Patterns

```bash
# Quick start guide
./scripts/ocr-quick-start.sh

# Test all OCR patterns on an image
./scripts/test-ocr-patterns.sh your-image.jpg

# Vision examples
./scripts/fabric-vision-examples.sh your-image.jpg
```

---

## Pattern Categories

### Vision & OCR
- `image-text-extraction` - Basic text extraction
- `expert-ocr-engine` - High-accuracy OCR
- `analyze-image-json` - Structured JSON output
- `ultra-ocr-engine` - Maximum-effort for degraded images
- `multi-scale-ocr` - Hierarchical multi-scale extraction

### Search Optimization
- `deep_search_optimizer` - AI search prompt optimization
- `search_query_generator` - Extract search queries from content
- `search_refiner` - Improve search queries

### Workflow
- `transcript-analyzer` - Analyze transcription errors
- `transcript-refiner` - Refine transcriptions
- `workflow-architect` - Design multi-agent workflows

---

## Documentation

- **Vision Models Guide**: `docs/Fabric-Vision-Models-Guide.md`
- **OCR Solutions**: `docs/OCR-Solutions-Summary.md`
- **Quick Reference**: `docs/Fabric-Vision-Quick-Reference.md`
- **Full Index**: `docs/README.md`

---

## Configuration

Patterns are automatically available to fabric from this location.

If needed, add to `~/.config/fabric/.env`:
```bash
FABRIC_PATTERNS_USER_DIR=~/.myscripts/fabric/patterns
```

---

## Scripts

All scripts are in `scripts/` directory:

```bash
# Add to PATH for easy access
export PATH="$PATH:$HOME/.myscripts/fabric/scripts"

# Or run directly
~/.myscripts/fabric/scripts/test-ocr-patterns.sh image.jpg
```

---

## Development

- Pattern templates: `patterns/*/system.md`
- Script development: `scripts/`
- Documentation: `docs/`

For development guidelines, see `docs/Documentation-Strategy-Framework.md`

---

**Version**: 1.0  
**Date**: October 7, 2025  
**Status**: Production Ready
EOF

echo -e "  ${GREEN}✓${RESET} Created fabric/README.md"

# Docs index README
cat > fabric/docs/README.md << 'EOF'
# Fabric Documentation Index

Complete documentation for the fabric project.

---

## Getting Started

### Quick Reference
- **[Quick Start](../scripts/ocr-quick-start.sh)** - Get started in 3 steps
- **[Vision Quick Reference](Fabric-Vision-Quick-Reference.md)** - One-page command reference

### Guides
- **[Vision Models Guide](Fabric-Vision-Models-Guide.md)** - Complete guide to using vision models
- **[OCR Solutions Summary](OCR-Solutions-Summary.md)** - OCR pattern overview and usage

---

## Technical Documentation

### Problem Analysis
- **[OCR Resolution Challenge](OCR-Resolution-Challenge-Analysis.md)** - Technical deep dive
- **[Vision Investigation Summary](Fabric-Vision-Investigation-Summary.md)** - Research findings

### Development
- **[Documentation Strategy](Documentation-Strategy-Framework.md)** - Documentation best practices

---

## Pattern Documentation

See `../patterns/README.md` for complete pattern catalog.

---

## Quick Access

```bash
# View quick reference
cat Fabric-Vision-Quick-Reference.md

# View full guide
cat Fabric-Vision-Models-Guide.md

# View OCR solutions
cat OCR-Solutions-Summary.md
```

---

**Last Updated**: October 7, 2025
EOF

echo -e "  ${GREEN}✓${RESET} Created fabric/docs/README.md"

# Move patterns README if it exists
if [ -f "fabric/patterns/README.md" ]; then
    echo -e "  ${GREEN}✓${RESET} Patterns README already exists"
else
    echo -e "  ${YELLOW}⚠${RESET} Patterns README not found (may need to create)"
fi

echo ""

# Step 6: Create convenience symlinks
echo -e "${CYAN}[6/6] Creating convenience links...${RESET}"

# Create check-docs.sh if it was moved
if [ -f "check-docs.sh" ]; then
    echo -e "  ${GREEN}✓${RESET} check-docs.sh remains in root"
fi

echo -e "${GREEN}✓ Reorganization complete!${RESET}"
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                     REORGANIZATION COMPLETE                    ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}New structure:${RESET}"
echo ""
echo "  fabric/"
echo "  ├── patterns/        ($(ls -1 fabric/patterns 2>/dev/null | wc -l) patterns)"
echo "  ├── scripts/         ($(ls -1 fabric/scripts 2>/dev/null | wc -l) scripts)"
echo "  ├── docs/            ($(ls -1 fabric/docs 2>/dev/null | wc -l) documents)"
echo "  └── README.md"
echo ""

echo -e "${CYAN}Backup saved to:${RESET} ${GREEN}$BACKUP_FILE${RESET}"
echo ""

echo -e "${CYAN}Next steps:${RESET}"
echo ""
echo "  1. Test patterns work:"
echo "     fabric --listpatterns | grep ultra-ocr"
echo ""
echo "  2. Test scripts:"
echo "     ./fabric/scripts/test-ocr-patterns.sh test-image.jpg"
echo ""
echo "  3. View documentation:"
echo "     cat fabric/README.md"
echo ""
echo "  4. Add to PATH (optional):"
echo "     export PATH=\"\$PATH:\$HOME/.myscripts/fabric/scripts\""
echo ""

echo -e "${GREEN}✓ All fabric content is now organized in the fabric/ directory!${RESET}"
echo ""
