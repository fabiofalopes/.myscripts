#!/bin/bash

# Fabric Vision Models Test Script
# Tests fabric's vision capabilities and your custom patterns

set -e

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

echo -e "${COLOR_BLUE}╔════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║  Fabric Vision Models - Test Suite        ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}╔════════════════════════════════════════════╗${COLOR_RESET}"
echo ""

# Test 1: Check Fabric Installation
echo -e "${COLOR_YELLOW}[1/8] Checking Fabric installation...${COLOR_RESET}"
if command -v fabric &> /dev/null; then
    FABRIC_VERSION=$(fabric --version 2>/dev/null || echo "unknown")
    echo -e "${COLOR_GREEN}✓ Fabric is installed (version: $FABRIC_VERSION)${COLOR_RESET}"
else
    echo -e "${COLOR_RED}✗ Fabric is not installed${COLOR_RESET}"
    exit 1
fi
echo ""

# Test 2: Check Attachment Flag
echo -e "${COLOR_YELLOW}[2/8] Verifying --attachment flag support...${COLOR_RESET}"
if fabric --help | grep -q "attachment"; then
    echo -e "${COLOR_GREEN}✓ --attachment flag is available${COLOR_RESET}"
    fabric --help | grep -A 1 "attachment"
else
    echo -e "${COLOR_RED}✗ --attachment flag not found${COLOR_RESET}"
fi
echo ""

# Test 3: List Vision Patterns
echo -e "${COLOR_YELLOW}[3/8] Checking for vision/image patterns...${COLOR_RESET}"
echo -e "${COLOR_BLUE}Custom patterns found:${COLOR_RESET}"
fabric --listpatterns | grep -i "image\|ocr\|vision" || echo "  No vision patterns found in built-in patterns"
echo ""

# Test 4: Check Available Vendors
echo -e "${COLOR_YELLOW}[4/8] Checking vision-capable vendors...${COLOR_RESET}"
echo -e "${COLOR_BLUE}Vision-capable vendors:${COLOR_RESET}"
fabric --listvendors | grep -E "(OpenAI|Gemini|Anthropic|Claude)" | while read vendor; do
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} $vendor"
done
echo ""

# Test 5: Check Current Model
echo -e "${COLOR_YELLOW}[5/8] Checking current default model...${COLOR_RESET}"
CURRENT_MODEL=$(fabric --listmodels | grep '^\s*\*' | sed 's/^\s*\*\s*\[\d*\]\s*//' || echo "No default model set")
echo -e "  Current model: ${COLOR_BLUE}$CURRENT_MODEL${COLOR_RESET}"
echo ""

# Test 6: Check API Keys
echo -e "${COLOR_YELLOW}[6/8] Checking configured API keys...${COLOR_RESET}"
FABRIC_ENV="$HOME/.config/fabric/.env"
if [ -f "$FABRIC_ENV" ]; then
    if grep -q "OPENAI_API_KEY" "$FABRIC_ENV" 2>/dev/null; then
        echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} OpenAI API key configured"
    else
        echo -e "  ${COLOR_RED}✗${COLOR_RESET} OpenAI API key not found"
    fi
    
    if grep -q "GEMINI_API_KEY\|GOOGLE_API_KEY" "$FABRIC_ENV" 2>/dev/null; then
        echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} Gemini/Google API key configured"
    else
        echo -e "  ${COLOR_RED}✗${COLOR_RESET} Gemini/Google API key not found"
    fi
    
    if grep -q "ANTHROPIC_API_KEY" "$FABRIC_ENV" 2>/dev/null; then
        echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} Anthropic API key configured"
    else
        echo -e "  ${COLOR_RED}✗${COLOR_RESET} Anthropic API key not found"
    fi
else
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} No .env file found at $FABRIC_ENV"
fi
echo ""

# Test 7: Check Custom Patterns
echo -e "${COLOR_YELLOW}[7/8] Verifying custom vision patterns...${COLOR_RESET}"
CUSTOM_PATTERNS_DIR="$HOME/.myscripts/fabric-custom-patterns"

if [ -d "$CUSTOM_PATTERNS_DIR/image-text-extraction" ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} image-text-extraction pattern found"
else
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} image-text-extraction pattern not found"
fi

if [ -d "$CUSTOM_PATTERNS_DIR/expert-ocr-engine" ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} expert-ocr-engine pattern found"
else
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} expert-ocr-engine pattern not found"
fi

if [ -d "$CUSTOM_PATTERNS_DIR/analyze-image-json" ]; then
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} analyze-image-json pattern found"
else
    echo -e "  ${COLOR_YELLOW}⚠${COLOR_RESET} analyze-image-json pattern not found (newly created)"
fi
echo ""

# Test 8: Vision Test Options
echo -e "${COLOR_YELLOW}[8/8] Vision functionality test options...${COLOR_RESET}"
echo ""
echo -e "${COLOR_BLUE}To test with an actual image, run one of these commands:${COLOR_RESET}"
echo ""
echo -e "  ${COLOR_GREEN}# Test with local image:${COLOR_RESET}"
echo -e "  fabric -a /path/to/your/image.jpg -p image-text-extraction"
echo ""
echo -e "  ${COLOR_GREEN}# Test with URL:${COLOR_RESET}"
echo -e "  fabric -a 'https://example.com/image.jpg' -p expert-ocr-engine"
echo ""
echo -e "  ${COLOR_GREEN}# Test with JSON output:${COLOR_RESET}"
echo -e "  fabric -a /path/to/image.jpg -p analyze-image-json -m gpt-4o"
echo ""
echo -e "  ${COLOR_GREEN}# Test with specific model:${COLOR_RESET}"
echo -e "  echo 'Describe this image' | fabric -a image.jpg -m gpt-4o"
echo ""

# Summary
echo -e "${COLOR_BLUE}╔════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║  Test Summary                              ║${COLOR_RESET}"
echo -e "${COLOR_BLUE}╚════════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# Check if vision is ready
VISION_READY=true

if ! fabric --help | grep -q "attachment"; then
    VISION_READY=false
fi

if [ ! -f "$FABRIC_ENV" ]; then
    VISION_READY=false
fi

if [ "$VISION_READY" = true ]; then
    echo -e "${COLOR_GREEN}✓ Fabric vision support is configured${COLOR_RESET}"
    echo -e "${COLOR_GREEN}✓ Ready to process images with --attachment flag${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Next steps:${COLOR_RESET}"
    echo "  1. Ensure you have a vision-capable model API key"
    echo "  2. Set a vision model as default: fabric -d"
    echo "  3. Test with a real image using one of the commands above"
else
    echo -e "${COLOR_RED}⚠ Fabric vision support needs configuration${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_YELLOW}Setup steps:${COLOR_RESET}"
    echo "  1. Run: fabric --setup"
    echo "  2. Configure OpenAI or Gemini API key"
    echo "  3. Set a vision-capable model as default"
    echo "  4. Test with: fabric -a image.jpg -p image-text-extraction"
fi

echo ""
echo -e "${COLOR_BLUE}Documentation: ~/.myscripts/docs/Fabric-Vision-Models-Guide.md${COLOR_RESET}"
echo ""
