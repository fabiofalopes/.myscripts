#!/bin/bash

# OCR Pattern Comparison Testing Script
# Tests different fabric OCR patterns on the same image

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                                                                ║${RESET}"
echo -e "${BLUE}║         Fabric OCR Patterns - Comparison Test Suite           ║${RESET}"
echo -e "${BLUE}║                                                                ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check arguments
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 <image_path> [model]${RESET}"
    echo ""
    echo "This script tests all OCR patterns on the same image for comparison."
    echo ""
    echo "Arguments:"
    echo "  image_path  - Path to image file or URL"
    echo "  model       - (Optional) Specific model to use (e.g., gpt-4o)"
    echo ""
    echo "Example:"
    echo "  $0 document.jpg"
    echo "  $0 document.jpg gpt-4o"
    echo ""
    exit 1
fi

IMAGE="$1"
MODEL="${2:-}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="ocr_comparison_${TIMESTAMP}"

# Verify image exists (if local file)
if [[ ! "$IMAGE" =~ ^https?:// ]] && [ ! -f "$IMAGE" ]; then
    echo -e "${RED}Error: Image file not found: $IMAGE${RESET}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}Test Configuration:${RESET}"
echo -e "  Image: ${GREEN}$IMAGE${RESET}"
if [ -n "$MODEL" ]; then
    echo -e "  Model: ${GREEN}$MODEL${RESET}"
    MODEL_FLAG="-m $MODEL"
else
    echo -e "  Model: ${YELLOW}Default${RESET}"
    MODEL_FLAG=""
fi
echo -e "  Output: ${GREEN}$OUTPUT_DIR/${RESET}"
echo ""

# Define patterns to test
PATTERNS=(
    "image-text-extraction:Basic text extraction"
    "expert-ocr-engine:High-accuracy OCR"
    "analyze-image-json:JSON structured output"
    "ultra-ocr-engine:Maximum-effort OCR"
    "multi-scale-ocr:Multi-scale hierarchical"
)

# Test each pattern
for pattern_info in "${PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$pattern_info"
    
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}Testing Pattern: ${GREEN}$pattern${RESET}"
    echo -e "${CYAN}Description: ${RESET}$description"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    
    # Check if pattern exists
    if ! fabric --listpatterns | grep -q "^${pattern}$"; then
        echo -e "${YELLOW}⚠ Pattern '$pattern' not found. Skipping...${RESET}"
        echo ""
        continue
    fi
    
    OUTPUT_FILE="${OUTPUT_DIR}/${pattern}_output.md"
    TIME_FILE="${OUTPUT_DIR}/${pattern}_timing.txt"
    
    echo -e "${BLUE}Running OCR...${RESET}"
    START_TIME=$(date +%s)
    
    # Run fabric OCR
    if fabric -a "$IMAGE" -p "$pattern" $MODEL_FLAG > "$OUTPUT_FILE" 2>&1; then
        END_TIME=$(date +%s)
        ELAPSED=$((END_TIME - START_TIME))
        echo "$ELAPSED" > "$TIME_FILE"
        
        # Get output stats
        CHAR_COUNT=$(wc -m < "$OUTPUT_FILE")
        WORD_COUNT=$(wc -w < "$OUTPUT_FILE")
        LINE_COUNT=$(wc -l < "$OUTPUT_FILE")
        
        echo -e "${GREEN}✓ Success${RESET}"
        echo -e "  Time: ${ELAPSED}s"
        echo -e "  Output: ${CHAR_COUNT} chars, ${WORD_COUNT} words, ${LINE_COUNT} lines"
        echo -e "  File: $OUTPUT_FILE"
        
        # Show preview
        echo ""
        echo -e "${CYAN}Preview (first 10 lines):${RESET}"
        echo -e "${YELLOW}────────────────────────────────────────────────────────────${RESET}"
        head -10 "$OUTPUT_FILE"
        echo -e "${YELLOW}────────────────────────────────────────────────────────────${RESET}"
    else
        END_TIME=$(date +%s)
        ELAPSED=$((END_TIME - START_TIME))
        
        echo -e "${RED}✗ Failed${RESET}"
        echo -e "  Time: ${ELAPSED}s"
        echo -e "  Check output file for error details: $OUTPUT_FILE"
    fi
    
    echo ""
    echo -e "${BLUE}Press Enter to continue to next pattern...${RESET}"
    read -r
    echo ""
done

# Generate comparison report
REPORT_FILE="${OUTPUT_DIR}/comparison_report.md"

echo -e "${CYAN}Generating comparison report...${RESET}"

cat > "$REPORT_FILE" << EOF
# OCR Pattern Comparison Report

**Date**: $(date)
**Image**: $IMAGE
**Model**: ${MODEL:-Default}

---

## Performance Summary

| Pattern | Time (s) | Characters | Words | Lines | Status |
|---------|----------|------------|-------|-------|--------|
EOF

for pattern_info in "${PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$pattern_info"
    
    OUTPUT_FILE="${OUTPUT_DIR}/${pattern}_output.md"
    TIME_FILE="${OUTPUT_DIR}/${pattern}_timing.txt"
    
    if [ -f "$TIME_FILE" ]; then
        TIME=$(cat "$TIME_FILE")
        CHARS=$(wc -m < "$OUTPUT_FILE")
        WORDS=$(wc -w < "$OUTPUT_FILE")
        LINES=$(wc -l < "$OUTPUT_FILE")
        STATUS="✓ Success"
    else
        TIME="-"
        CHARS="-"
        WORDS="-"
        LINES="-"
        STATUS="✗ Failed"
    fi
    
    echo "| $pattern | $TIME | $CHARS | $WORDS | $LINES | $STATUS |" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

---

## Pattern Descriptions

EOF

for pattern_info in "${PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$pattern_info"
    echo "### $pattern" >> "$REPORT_FILE"
    echo "$description" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
done

cat >> "$REPORT_FILE" << EOF

---

## Output Files

All outputs saved to: \`$OUTPUT_DIR/\`

- Individual pattern outputs: \`<pattern>_output.md\`
- Timing data: \`<pattern>_timing.txt\`
- This report: \`comparison_report.md\`

---

## Analysis Guidelines

### Evaluate each output for:

1. **Completeness**: Did it extract all visible text?
2. **Accuracy**: Is the extracted text correct?
3. **Structure**: Is the output well-organized?
4. **Confidence**: Does it flag uncertain extractions?
5. **Speed**: How long did it take?
6. **Usability**: Is the output format useful for your needs?

### Recommended Pattern Selection:

- **High-quality images**: Use \`image-text-extraction\` or \`expert-ocr-engine\`
- **Low-quality/degraded**: Use \`ultra-ocr-engine\`
- **Full-page low-res**: Use \`multi-scale-ocr\`
- **Programmatic use**: Use \`analyze-image-json\`

---

## Next Steps

1. Review all output files in \`$OUTPUT_DIR/\`
2. Compare accuracy against known/expected text
3. Note which pattern performed best for your use case
4. Consider creating benchmark dataset for systematic testing

EOF

echo -e "${GREEN}✓ Comparison report generated: $REPORT_FILE${RESET}"
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BLUE}║                    Test Complete!                              ║${RESET}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}Results Summary:${RESET}"
echo ""

# Count successes
SUCCESS_COUNT=0
TOTAL_COUNT=${#PATTERNS[@]}

for pattern_info in "${PATTERNS[@]}"; do
    IFS=':' read -r pattern description <<< "$pattern_info"
    TIME_FILE="${OUTPUT_DIR}/${pattern}_timing.txt"
    
    if [ -f "$TIME_FILE" ]; then
        TIME=$(cat "$TIME_FILE")
        echo -e "  ${GREEN}✓${RESET} $pattern (${TIME}s)"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${RED}✗${RESET} $pattern"
    fi
done

echo ""
echo -e "${CYAN}Success Rate: ${GREEN}$SUCCESS_COUNT${RESET}/${TOTAL_COUNT}"
echo ""
echo -e "${YELLOW}All outputs saved to:${RESET} ${GREEN}$OUTPUT_DIR/${RESET}"
echo -e "${YELLOW}Comparison report:${RESET} ${GREEN}$REPORT_FILE${RESET}"
echo ""
echo -e "${CYAN}View report:${RESET}"
echo -e "  cat $REPORT_FILE"
echo ""
echo -e "${CYAN}View specific output:${RESET}"
echo -e "  cat $OUTPUT_DIR/<pattern>_output.md"
echo ""

# Offer to open report
echo -e "${BLUE}Open comparison report now? (y/n)${RESET}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    if command -v less &> /dev/null; then
        less "$REPORT_FILE"
    else
        cat "$REPORT_FILE"
    fi
fi

echo ""
echo -e "${GREEN}Done!${RESET}"
