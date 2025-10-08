#!/bin/bash

# Fabric Vision Usage Examples
# Demonstrates different ways to use fabric with images

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════${RESET}"
echo -e "${BLUE}  Fabric Vision Models - Usage Examples${RESET}"
echo -e "${BLUE}════════════════════════════════════════════════════${RESET}"
echo ""

# Check if image path is provided
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 <image_path_or_url>${RESET}"
    echo ""
    echo "Examples:"
    echo "  $0 /path/to/image.jpg"
    echo "  $0 https://example.com/image.png"
    echo ""
    echo "This script will demonstrate various fabric vision commands"
    exit 1
fi

IMAGE="$1"

# Verify the image exists (if it's a local file)
if [[ ! "$IMAGE" =~ ^https?:// ]] && [ ! -f "$IMAGE" ]; then
    echo -e "${YELLOW}Warning: Local file not found: $IMAGE${RESET}"
    echo "Continuing anyway (might be a URL)..."
    echo ""
fi

echo -e "${BLUE}Target image: ${RESET}$IMAGE"
echo ""

# Example 1: Simple text extraction
echo -e "${GREEN}[Example 1] Simple Text Extraction${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p image-text-extraction"
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p image-text-extraction
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 2: Expert OCR
echo -e "${GREEN}[Example 2] Expert OCR Engine${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p expert-ocr-engine"
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p expert-ocr-engine
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 3: JSON output
echo -e "${GREEN}[Example 3] Structured JSON Analysis${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p analyze-image-json"
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p analyze-image-json
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 4: With streaming
echo -e "${GREEN}[Example 4] Streaming Response${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p image-text-extraction --stream"
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p image-text-extraction --stream
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 5: Save to file
OUTPUT_FILE="/tmp/fabric_vision_output_$(date +%s).md"
echo -e "${GREEN}[Example 5] Save Output to File${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p image-text-extraction -o \"$OUTPUT_FILE\""
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p image-text-extraction -o "$OUTPUT_FILE"
echo ""
echo -e "${BLUE}Output saved to: $OUTPUT_FILE${RESET}"
cat "$OUTPUT_FILE"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 6: Copy to clipboard
echo -e "${GREEN}[Example 6] Copy to Clipboard${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p image-text-extraction --copy"
echo ""
read -p "Press Enter to run... "
fabric -a "$IMAGE" -p image-text-extraction --copy
echo ""
echo -e "${BLUE}Output copied to clipboard!${RESET}"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 7: With specific model (if you have OpenAI configured)
echo -e "${GREEN}[Example 7] Using Specific Vision Model${RESET}"
echo -e "${YELLOW}Command:${RESET} fabric -a \"$IMAGE\" -p image-text-extraction -m gpt-4o"
echo ""
echo -e "${YELLOW}Note: This requires OpenAI API key configured${RESET}"
read -p "Press Enter to try (or Ctrl+C to skip)... "
fabric -a "$IMAGE" -p image-text-extraction -m gpt-4o 2>/dev/null || echo -e "${YELLOW}Skipped (model not available)${RESET}"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Example 8: Custom prompt with image
echo -e "${GREEN}[Example 8] Custom Prompt with Image${RESET}"
echo -e "${YELLOW}Command:${RESET} echo 'List all technical identifiers in this image' | fabric -a \"$IMAGE\""
echo ""
read -p "Press Enter to run... "
echo 'List all technical identifiers in this image' | fabric -a "$IMAGE"
echo ""
echo "─────────────────────────────────────────────────────"
echo ""

# Summary
echo -e "${BLUE}════════════════════════════════════════════════════${RESET}"
echo -e "${BLUE}  Examples Complete!${RESET}"
echo -e "${BLUE}════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${GREEN}Key Takeaways:${RESET}"
echo "  • Use -a or --attachment to send images to fabric"
echo "  • Combine with any pattern (your custom or built-in)"
echo "  • Add --stream for real-time responses"
echo "  • Use -o to save output to files"
echo "  • Use --copy to copy to clipboard"
echo "  • Specify model with -m for vision-capable models"
echo ""
echo -e "${YELLOW}Your Custom Vision Patterns:${RESET}"
echo "  • image-text-extraction  - Extract all visible text"
echo "  • expert-ocr-engine      - High-accuracy OCR"
echo "  • analyze-image-json     - Structured JSON output"
echo ""
