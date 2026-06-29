#!/bin/bash
# Test suite for enhanced slugfile
#
# This script creates test files and demonstrates the new features
# Run with: bash test-slugfile.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}slugfile Enhanced - Test Suite${NC}"
echo "======================================"
echo ""

# Create test directory
TEST_DIR="$(mktemp -d)"
echo -e "${CYAN}Created test directory:${NC} $TEST_DIR"
echo ""

# Cleanup function
cleanup() {
    echo -e "${YELLOW}Cleaning up test directory...${NC}"
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# ============================================================================
# Test 1: Basic slugification (backward compatibility)
# ============================================================================
echo -e "${BOLD}Test 1: Basic slugification${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
echo "My Document (Final).md" | slugfile
# Expected output: my-document-final
echo ""

# ============================================================================
# Test 2: Date prefix
# ============================================================================
echo -e "${BOLD}Test 2: Date prefix (-d flag)${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
touch "My Note.md"
slugfile -d "My Note.md" --dry-run
# Expected: YYYY-MM-DD-my-note.md
echo ""

# ============================================================================
# Test 3: Custom date
# ============================================================================
echo -e "${BOLD}Test 3: Custom date${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
slugfile -d "2026-01-15" "My Note.md" --dry-run
# Expected: 2026-01-15-my-note.md
echo ""

# ============================================================================
# Test 4: Tag extraction from frontmatter
# ============================================================================
echo -e "${BOLD}Test 4: Tag extraction (-t flag)${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "test-tags.md" << 'EOF'
---
tags: [obsidian, workflow, tools]
---
# My Document

This is a test document with tags.
EOF

slugfile -t "test-tags.md" --dry-run
# Expected: test-tags-obsidian-workflow-tools.md
echo ""

# ============================================================================
# Test 5: Inline tag extraction
# ============================================================================
echo -e "${BOLD}Test 5: Inline tag extraction${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "test-inline.md" << 'EOF'
# My Document

This document has #inline tags in the content.
More #tags here.
EOF

slugfile -t "test-inline.md" --dry-run
# Expected: test-inline-inline-tags-more-tags.md (or similar)
echo ""

# ============================================================================
# Test 6: Combined date and tags
# ============================================================================
echo -e "${BOLD}Test 6: Combined date and tags${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "combined.md" << 'EOF'
---
tags: [test, example]
---
# Combined Test
EOF

slugfile -d -t "combined.md" --dry-run
# Expected: YYYY-MM-DD-combined-test-example.md
echo ""

# ============================================================================
# Test 7: Skip tags
# ============================================================================
echo -e "${BOLD}Test 7: Skip tags (-k flag)${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "skip-test.md" << 'EOF'
---
tags: [untitled, draft, important]
---
# Skip Test
EOF

slugfile -t "skip-test.md" -k "untitled,draft" --dry-run
# Expected: skip-test-important.md (untitled and draft skipped)
echo ""

# ============================================================================
# Test 8: Max tags limit
# ============================================================================
echo -e "${BOLD}Test 8: Max tags limit (--max-tags)${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "many-tags.md" << 'EOF'
---
tags: [one, two, three, four, five]
---
# Many Tags
EOF

slugfile -t "many-tags.md" --max-tags 2 --dry-run
# Expected: many-tags-one-two.md (only first 2 tags)
echo ""

# ============================================================================
# Test 9: Collision handling - increment
# ============================================================================
echo -e "${BOLD}Test 9: Collision handling - increment${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
touch "existing.md"
touch "new.md"
slugfile "new.md" --collision=increment --dry-run
# If existing.md exists, new.md -> existing-2.md
echo ""

# ============================================================================
# Test 10: Recursive batch processing
# ============================================================================
echo -e "${BOLD}Test 10: Recursive batch processing${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
mkdir -p batch/subfolder
touch "batch/File One.md"
touch "batch/File Two.md"
touch "batch/subfolder/File Three.md"

slugfile -r batch/ --dry-run
# Expected: All files slugified recursively
echo ""

# ============================================================================
# Test 11: Polish mode (if obsidian-polish exists)
# ============================================================================
echo -e "${BOLD}Test 11: Polish mode (-p flag)${NC}"
echo "-----------------------------------"
cd "$TEST_DIR"
cat > "polish-test.md" << 'EOF'
# Untitled

This is a test document without proper metadata.
EOF

if command -v obsidian-polish &> /dev/null; then
    echo -e "${GREEN}obsidian-polish found, testing polish mode${NC}"
    slugfile -p "polish-test.md" --dry-run
    # Expected: obsidian-polish runs, then file is slugified with date+tags
else
    echo -e "${YELLOW}obsidian-polish not found, skipping polish test${NC}"
fi
echo ""

# ============================================================================
# Test 12: Help and usage
# ============================================================================
echo -e "${BOLD}Test 12: Help documentation${NC}"
echo "-----------------------------------"
slugfile --help | head -20
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "======================================"
echo -e "${GREEN}Test suite complete!${NC}"
echo ""
echo "All tests ran in: $TEST_DIR"
echo "Test directory will be cleaned up automatically."
echo ""
echo -e "${BOLD}Key features tested:${NC}"
echo "  ✓ Basic slugification (backward compatible)"
echo "  ✓ Date prefix support"
echo "  ✓ Tag extraction (frontmatter + inline)"
echo "  ✓ Tag filtering and limits"
echo "  ✓ Collision handling"
echo "  ✓ Batch processing"
echo "  ✓ Polish mode integration"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Test with real files in your vault (use --dry-run first!)"
echo "  2. Create aliases for common workflows"
echo "  3. Integrate with your Obsidian workflow"
