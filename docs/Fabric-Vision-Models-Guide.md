# Fabric Vision Models - Complete Guide

## Overview

Fabric supports vision models through the `--attachment` (or `-a`) parameter, which allows you to send images to vision-capable AI models for analysis, OCR, and extraction tasks.

## Key Findings

### ❌ No Built-in "analyze_image" Pattern
**Important**: Despite what some documentation suggests, there is **NO** built-in `analyze_image` pattern in the standard Fabric distribution. You need to:
- Use existing patterns that work with text (they'll process the image description)
- Create custom patterns specifically for vision tasks
- Use your existing custom patterns: `image-text-extraction` and `expert-ocr-engine`

### ✅ What Actually Works

Fabric's vision support works by:
1. Using the `--attachment` flag to send images to the model
2. The model processes the image based on the pattern's system prompt
3. Any pattern can theoretically work with images if the model supports vision

---

## Basic Usage

### Syntax
```bash
fabric --attachment <path_or_url> --pattern <pattern_name> [options]
# or short form:
fabric -a <path_or_url> -p <pattern_name>
```

### Examples

#### 1. Using Your Custom OCR Pattern
```bash
# Extract text from a local image
fabric -a /path/to/image.jpg -p image-text-extraction

# Extract text from a URL
fabric -a "https://example.com/document.jpg" -p expert-ocr-engine
```

#### 2. Using Built-in Patterns (Generic Analysis)
```bash
# Analyze with analyze_claims pattern
fabric -a photo.png -p analyze_claims

# Extract wisdom from an image
fabric -a screenshot.jpg -p extract_wisdom

# Summarize visual content
fabric -a chart.png -p summarize
```

#### 3. Multiple Images (if model supports)
```bash
fabric -a image1.jpg -a image2.jpg -p image-text-extraction
```

---

## Vision-Capable Models

### Current Setup Analysis
Your fabric configuration shows **LiteLLM** models but NO native OpenAI/Gemini/Anthropic vision models listed.

**Available vendors with vision capabilities:**
- ✅ **OpenAI** (GPT-4o, GPT-4-vision, GPT-4-turbo)
- ✅ **Gemini** (Gemini 1.5 Pro, Gemini 2.0 Flash)
- ✅ **Anthropic** (Claude 3.5 Sonnet, Claude 3 Opus)
- ⚠️ **LiteLLM** (acts as proxy - depends on backend model)

### Checking Your Vision Model Access

```bash
# Check if you have OpenAI configured
fabric --listvendors

# Try to see OpenAI models (requires API key)
cat ~/.config/fabric/.env | grep OPENAI_API_KEY
```

### Recommended Vision Models

| Model | Provider | Best For | Cost |
|-------|----------|----------|------|
| **gpt-4o** | OpenAI | General vision tasks, OCR, accuracy | $$ |
| **gpt-4o-mini** | OpenAI | Fast, cheaper vision tasks | $ |
| **gemini-1.5-pro** | Google | Long context, multi-image | $$ |
| **gemini-2.0-flash** | Google | Fast, experimental features | $ |
| **claude-3.5-sonnet** | Anthropic | Best reasoning with images | $$$ |

---

## Setting Up Vision Models

### 1. Configure OpenAI (Recommended for OCR)

```bash
# Run fabric setup
fabric --setup

# Or manually add to ~/.config/fabric/.env
echo "DEFAULT_VENDOR=OpenAI" >> ~/.config/fabric/.env
echo "OPENAI_API_KEY=your-api-key-here" >> ~/.config/fabric/.env
```

### 2. Set Default Vision Model

```bash
# Change default model interactively
fabric -d

# Or manually set in .env
echo "DEFAULT_MODEL=gpt-4o" >> ~/.config/fabric/.env
```

### 3. Test Vision Setup

```bash
# Create a test (assuming you have an image)
echo "Describe what you see in this image" | fabric -a test_image.jpg -m gpt-4o
```

---

## Your Custom Vision Patterns

### Pattern 1: `image-text-extraction`
**Purpose**: Extract all visible text exactly as it appears  
**Location**: `/home/fabio/.myscripts/fabric-custom-patterns/image-text-extraction/system.md`

**Usage**:
```bash
fabric -a device_photo.jpg -p image-text-extraction
```

**Best for**:
- Device labels (MAC addresses, serial numbers)
- Technical documentation
- Signs and printed text
- Configuration screens

### Pattern 2: `expert-ocr-engine`
**Purpose**: Expert-level OCR transcription  
**Location**: `/home/fabio/.myscripts/fabric-custom-patterns/expert-ocr-engine/system.md`

**Usage**:
```bash
fabric -a document.png -p expert-ocr-engine
```

**Best for**:
- High-accuracy text extraction
- Technical identifiers
- Structured data extraction

---

## Creating a Vision Pattern for Structured JSON Output

Based on your requirement for JSON output, here's how to create an `analyze-image-json` pattern:

### Pattern Structure

```bash
mkdir -p ~/.config/fabric/patterns/analyze-image-json
```

Create `~/.config/fabric/patterns/analyze-image-json/system.md`:

```markdown
# IDENTITY and PURPOSE

You are an expert image analysis system that returns structured JSON output describing images in detail.

# STEPS

1. Analyze the provided image thoroughly
2. Identify all key elements, objects, text, and context
3. Extract any visible text using OCR
4. Categorize the image type
5. Return a structured JSON response

# OUTPUT FORMAT

Return ONLY valid JSON with this structure:

{
  "image_type": "photo|screenshot|document|diagram|chart|other",
  "description": "Brief overall description",
  "objects": ["list", "of", "identified", "objects"],
  "text_content": {
    "has_text": true|false,
    "extracted_text": "All visible text",
    "language": "detected language"
  },
  "technical_details": {
    "identifiers": ["MAC addresses", "serial numbers", "IPs"],
    "labels": ["any labels or tags"],
    "metadata": "other technical info"
  },
  "colors": ["dominant", "colors"],
  "confidence": 0.0-1.0,
  "notes": "Any additional observations"
}

# OUTPUT INSTRUCTIONS

- Output ONLY the JSON, no markdown code blocks
- Ensure valid JSON syntax
- Be precise and comprehensive
- If unsure about any field, use null or "unknown"
```

### Usage:

```bash
fabric -a image.jpg -p analyze-image-json
```

---

## Advanced Usage

### Stream Response
```bash
fabric -a image.jpg -p image-text-extraction --stream
```

### Copy to Clipboard
```bash
fabric -a photo.png -p expert-ocr-engine --copy
```

### Save to File
```bash
fabric -a document.jpg -p image-text-extraction -o extracted_text.md
```

### Custom Temperature
```bash
fabric -a image.jpg -p image-text-extraction -t 0.1
```

### Specify Model Explicitly
```bash
fabric -a image.jpg -p image-text-extraction -m gpt-4o
```

### Chain with Other Commands
```bash
# OCR then analyze
fabric -a invoice.jpg -p expert-ocr-engine | fabric -p analyze_bill
```

---

## Testing Vision Functionality

### Quick Test Script

```bash
#!/bin/bash
# Test fabric vision capabilities

echo "Testing Fabric Vision Models..."

# Test 1: Check if attachment flag works
echo -e "\n1. Testing attachment flag syntax..."
fabric --help | grep -A 1 "attachment"

# Test 2: List your custom vision patterns
echo -e "\n2. Your custom vision patterns:"
fabric --listpatterns | grep -i "ocr\|image"

# Test 3: Check available vendors
echo -e "\n3. Available vendors:"
fabric --listvendors | grep -E "(OpenAI|Gemini|Anthropic)"

# Test 4: Try with a test image (if available)
if [ -f "test_image.jpg" ]; then
    echo -e "\n4. Testing with test_image.jpg..."
    fabric -a test_image.jpg -p image-text-extraction
else
    echo -e "\n4. No test image found. Create one or provide path."
fi
```

---

## Common Issues & Solutions

### Issue 1: "Model doesn't support images"
**Solution**: You're using a text-only model. Switch to a vision model:
```bash
fabric -a image.jpg -p image-text-extraction -m gpt-4o
```

### Issue 2: "No pattern named analyze_image"
**Solution**: This pattern doesn't exist. Use your custom patterns or built-in ones:
```bash
fabric -a image.jpg -p image-text-extraction
```

### Issue 3: API Key Not Set
**Solution**: Configure your vision model provider:
```bash
fabric --setup
```

### Issue 4: Image Too Large
**Solution**: Vision models have size limits (usually 20MB). Resize your image:
```bash
convert large_image.jpg -resize 2048x2048\> smaller_image.jpg
fabric -a smaller_image.jpg -p image-text-extraction
```

---

## Best Practices

### 1. **Image Quality**
- Use high-resolution images for OCR tasks
- Ensure text is clearly readable
- Avoid rotated or distorted images

### 2. **Cost Management**
- Vision API calls are more expensive than text-only
- Use appropriate detail levels (if model supports)
- Consider using `gpt-4o-mini` for simple tasks

### 3. **Pattern Selection**
| Task | Recommended Pattern |
|------|-------------------|
| OCR extraction | `expert-ocr-engine` or `image-text-extraction` |
| General analysis | `extract_wisdom` |
| Fact-checking | `analyze_claims` |
| Document analysis | Create custom JSON pattern |
| Technical diagrams | Create `analyze-diagram` pattern |

### 4. **Batch Processing**
```bash
# Process multiple images
for img in images/*.jpg; do
    echo "Processing $img..."
    fabric -a "$img" -p image-text-extraction -o "output/$(basename $img .jpg).md"
done
```

---

## Next Steps

### 1. ✅ Verify Vision Model Access
```bash
# Check if you have API keys configured
cat ~/.config/fabric/.env | grep -E "(OPENAI|GEMINI|ANTHROPIC)"
```

### 2. ✅ Create the JSON Pattern
Follow the pattern structure above to create `analyze-image-json`

### 3. ✅ Test with Real Images
```bash
# Test your existing patterns
fabric -a real_image.jpg -p image-text-extraction
fabric -a real_image.jpg -p expert-ocr-engine
```

### 4. ✅ Create More Specialized Patterns
Ideas:
- `analyze-diagram`: For technical diagrams
- `extract-table-data`: For table extraction to CSV/JSON
- `compare-images`: For comparing multiple images
- `describe-for-accessibility`: For alt-text generation

---

## Conclusion

**What Fabric DOES have:**
- ✅ `--attachment` flag for sending images
- ✅ Support for vision-capable models (when configured)
- ✅ Your custom OCR patterns

**What Fabric DOESN'T have:**
- ❌ Built-in `analyze_image` pattern
- ❌ Pre-configured vision models (requires setup)

**Action Items:**
1. Configure a vision-capable model (OpenAI GPT-4o recommended)
2. Test your existing patterns with real images
3. Create the JSON output pattern if needed
4. Build specialized patterns for your workflows

---

## Resources

- Fabric GitHub: https://github.com/danielmiessler/fabric
- Your patterns: `/home/fabio/.myscripts/fabric-custom-patterns/`
- Fabric config: `~/.config/fabric/`
