#!/bin/bash

# Documentation Checklist Tool
# Helps assess if documentation is balanced and complete

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║   Documentation Quality Checklist               ║${RESET}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Directory not found: $PROJECT_DIR${RESET}"
    exit 1
fi

echo -e "${CYAN}Analyzing: ${GREEN}$PROJECT_DIR${RESET}"
echo ""

# Initialize scores
TIER1_SCORE=0
TIER2_SCORE=0
TIER3_SCORE=0
TOOLS_SCORE=0

# Tier 1: Essential Documentation
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}TIER 1: ESSENTIAL (Must Have)${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check for README
if [ -f "$PROJECT_DIR/README.md" ] || [ -f "$PROJECT_DIR/readme.md" ]; then
    README_SIZE=$(find "$PROJECT_DIR" -maxdepth 1 -iname "readme.md" -exec wc -c {} \; | awk '{print $1}')
    if [ "$README_SIZE" -gt 500 ] && [ "$README_SIZE" -lt 5000 ]; then
        echo -e "${GREEN}✓${RESET} README exists (${README_SIZE} bytes) - Good size"
        ((TIER1_SCORE+=2))
    elif [ "$README_SIZE" -gt 5000 ]; then
        echo -e "${YELLOW}⚠${RESET} README exists (${README_SIZE} bytes) - May be too detailed"
        ((TIER1_SCORE+=1))
    else
        echo -e "${YELLOW}⚠${RESET} README exists (${README_SIZE} bytes) - May be too brief"
        ((TIER1_SCORE+=1))
    fi
else
    echo -e "${RED}✗${RESET} No README found"
fi

# Check for quick start
if find "$PROJECT_DIR" -iname "*quick*start*" -o -iname "*getting*started*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Quick start guide exists"
    ((TIER1_SCORE+=2))
else
    echo -e "${YELLOW}⚠${RESET} No quick start guide found"
fi

# Check for examples
if grep -rli "example\|usage" "$PROJECT_DIR"/*.md 2>/dev/null | head -1 | grep -q .; then
    echo -e "${GREEN}✓${RESET} Examples found in documentation"
    ((TIER1_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No clear examples found"
fi

echo -e "${CYAN}Tier 1 Score: $TIER1_SCORE/5${RESET}"
echo ""

# Tier 2: Tactical Documentation
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}TIER 2: TACTICAL (Should Have)${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check for usage guide
if find "$PROJECT_DIR" -iname "*usage*" -o -iname "*guide*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Usage guide exists"
    ((TIER2_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No usage guide found"
fi

# Check for troubleshooting
if grep -rli "troubleshoot\|problem\|error\|issue" "$PROJECT_DIR"/*.md 2>/dev/null | head -1 | grep -q .; then
    echo -e "${GREEN}✓${RESET} Troubleshooting section exists"
    ((TIER2_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No troubleshooting section found"
fi

# Check for comparison/decision table
if grep -rli "comparison\||.*|.*|" "$PROJECT_DIR"/*.md 2>/dev/null | head -1 | grep -q .; then
    echo -e "${GREEN}✓${RESET} Comparison/decision table found"
    ((TIER2_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No comparison tables found"
fi

# Check for API/interface docs
if find "$PROJECT_DIR" -iname "*api*" -o -iname "*interface*" -o -iname "*reference*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} API/reference documentation exists"
    ((TIER2_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No API/reference docs found"
fi

echo -e "${CYAN}Tier 2 Score: $TIER2_SCORE/4${RESET}"
echo ""

# Tier 3: Strategic Documentation
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}TIER 3: STRATEGIC (Nice to Have)${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check for architecture docs
if find "$PROJECT_DIR" -iname "*architecture*" -o -iname "*design*" -o -iname "*technical*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Architecture/design docs exist"
    ((TIER3_SCORE+=1))
else
    echo -e "${BLUE}○${RESET} No architecture docs (optional)"
fi

# Check for analysis/investigation docs
if find "$PROJECT_DIR" -iname "*analysis*" -o -iname "*investigation*" -o -iname "*research*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Analysis/investigation docs exist"
    ((TIER3_SCORE+=1))
else
    echo -e "${BLUE}○${RESET} No analysis docs (optional)"
fi

# Check for roadmap
if grep -rli "roadmap\|future\|todo" "$PROJECT_DIR"/*.md 2>/dev/null | head -1 | grep -q .; then
    echo -e "${GREEN}✓${RESET} Roadmap/future plans documented"
    ((TIER3_SCORE+=1))
else
    echo -e "${BLUE}○${RESET} No roadmap (optional)"
fi

echo -e "${CYAN}Tier 3 Score: $TIER3_SCORE/3 (optional)${RESET}"
echo ""

# Testing/Tools
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}TESTING & TOOLS${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Check for test scripts
if find "$PROJECT_DIR" -name "test*.sh" -o -name "*test.sh" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Test scripts exist"
    ((TOOLS_SCORE+=2))
else
    echo -e "${YELLOW}⚠${RESET} No test scripts found"
fi

# Check for example data
if find "$PROJECT_DIR" -type d -iname "*example*" -o -iname "*sample*" -o -iname "*test*" | grep -q .; then
    echo -e "${GREEN}✓${RESET} Example/sample data exists"
    ((TOOLS_SCORE+=1))
else
    echo -e "${YELLOW}⚠${RESET} No example data found"
fi

echo -e "${CYAN}Tools Score: $TOOLS_SCORE/3${RESET}"
echo ""

# Documentation Quality Metrics
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}DOCUMENTATION QUALITY METRICS${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# Count total documentation
DOC_COUNT=$(find "$PROJECT_DIR" -name "*.md" -type f 2>/dev/null | wc -l)
DOC_SIZE=$(find "$PROJECT_DIR" -name "*.md" -type f -exec cat {} \; 2>/dev/null | wc -c)
CODE_COUNT=$(find "$PROJECT_DIR" \( -name "*.py" -o -name "*.sh" -o -name "*.js" \) -type f 2>/dev/null | wc -l)
CODE_SIZE=$(find "$PROJECT_DIR" \( -name "*.py" -o -name "*.sh" -o -name "*.js" \) -type f -exec cat {} \; 2>/dev/null | wc -c)

echo -e "Documentation files: ${CYAN}$DOC_COUNT${RESET}"
echo -e "Documentation size: ${CYAN}$(numfmt --to=iec-i --suffix=B $DOC_SIZE 2>/dev/null || echo ${DOC_SIZE}B)${RESET}"
echo -e "Code files: ${CYAN}$CODE_COUNT${RESET}"
echo -e "Code size: ${CYAN}$(numfmt --to=iec-i --suffix=B $CODE_SIZE 2>/dev/null || echo ${CODE_SIZE}B)${RESET}"

if [ "$CODE_SIZE" -gt 0 ]; then
    DOC_CODE_RATIO=$((DOC_SIZE * 100 / CODE_SIZE))
    echo -e "Doc/Code ratio: ${CYAN}${DOC_CODE_RATIO}%${RESET}"
    
    if [ "$DOC_CODE_RATIO" -lt 50 ]; then
        echo -e "  ${YELLOW}⚠${RESET} May be under-documented"
    elif [ "$DOC_CODE_RATIO" -gt 500 ]; then
        echo -e "  ${YELLOW}⚠${RESET} May be over-documented"
    else
        echo -e "  ${GREEN}✓${RESET} Reasonable ratio"
    fi
fi

echo ""

# Overall Assessment
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║   OVERALL ASSESSMENT                             ║${RESET}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${RESET}"
echo ""

TOTAL_REQUIRED=$((TIER1_SCORE + TIER2_SCORE + TOOLS_SCORE))
MAX_REQUIRED=12

PERCENTAGE=$((TOTAL_REQUIRED * 100 / MAX_REQUIRED))

echo -e "Required Documentation Score: ${CYAN}${TOTAL_REQUIRED}/${MAX_REQUIRED}${RESET} (${PERCENTAGE}%)"
echo -e "Optional Documentation Score: ${CYAN}${TIER3_SCORE}/3${RESET}"
echo ""

if [ "$TOTAL_REQUIRED" -ge 10 ]; then
    echo -e "${GREEN}✓ EXCELLENT${RESET} - Well documented!"
    echo "  Project has comprehensive, well-balanced documentation."
elif [ "$TOTAL_REQUIRED" -ge 7 ]; then
    echo -e "${GREEN}✓ GOOD${RESET} - Adequate documentation"
    echo "  Project is usable, minor improvements possible."
elif [ "$TOTAL_REQUIRED" -ge 5 ]; then
    echo -e "${YELLOW}⚠ FAIR${RESET} - Needs improvement"
    echo "  Project is minimally documented, add more guides."
else
    echo -e "${RED}✗ POOR${RESET} - Insufficient documentation"
    echo "  Project needs significant documentation work."
fi

echo ""

# Recommendations
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${YELLOW}RECOMMENDATIONS${RESET}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

if [ "$TIER1_SCORE" -lt 4 ]; then
    echo -e "${RED}HIGH PRIORITY:${RESET}"
    echo "  • Create/improve quick start guide"
    echo "  • Add usage examples to README"
    echo "  • Ensure README is 1-2 pages"
fi

if [ "$TIER2_SCORE" -lt 3 ]; then
    echo -e "${YELLOW}MEDIUM PRIORITY:${RESET}"
    echo "  • Add usage guide with detailed examples"
    echo "  • Create troubleshooting section"
    echo "  • Add comparison tables for options"
fi

if [ "$TOOLS_SCORE" -lt 2 ]; then
    echo -e "${YELLOW}MEDIUM PRIORITY:${RESET}"
    echo "  • Create test/demo scripts"
    echo "  • Add example data or test cases"
fi

if [ "$TIER3_SCORE" -eq 0 ] && [ "$TOTAL_REQUIRED" -ge 8 ]; then
    echo -e "${GREEN}LOW PRIORITY:${RESET}"
    echo "  • Consider adding architecture docs (if complex)"
    echo "  • Document technical decisions (if needed)"
fi

if [ "$DOC_CODE_RATIO" -gt 500 ]; then
    echo -e "${YELLOW}OPTIMIZATION:${RESET}"
    echo "  • Documentation may be excessive"
    echo "  • Consider consolidating or archiving some docs"
    echo "  • Focus on examples over explanations"
fi

echo ""
echo -e "${CYAN}For documentation best practices, see:${RESET}"
echo -e "  ~/.myscripts/docs/Documentation-Strategy-Framework.md"
echo ""
