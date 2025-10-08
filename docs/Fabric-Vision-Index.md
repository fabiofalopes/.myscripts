# Fabric Vision Models - Complete Documentation Index

**Investigation Date**: October 7, 2025  
**Status**: ✅ Complete & Ready  
**Fabric Version**: 1.4.318

---

## 🎯 Quick Answer

**Q: How do I use fabric with images?**

```bash
fabric -a <image_path_or_url> -p <pattern_name>
```

**Example:**
```bash
fabric -a device.jpg -p image-text-extraction
```

**Note**: There is NO built-in `analyze_image` pattern. The Perplexity search results were incorrect.

---

## 📚 Documentation Files

### 1. Complete Guide (READ THIS FIRST)
**File**: `Fabric-Vision-Models-Guide.md` (11 KB)

Comprehensive guide covering:
- Basic usage with the `--attachment` flag
- Supported image formats
- Vision-capable models
- Pattern usage examples
- Best practices
- Troubleshooting

**Read it**: `cat ~/.myscripts/docs/Fabric-Vision-Models-Guide.md`

---

### 2. Quick Reference Card
**File**: `Fabric-Vision-Quick-Reference.md` (3.5 KB)

One-page command reference with:
- Common commands
- Batch processing examples
- Troubleshooting table
- Tips and best practices

**Read it**: `cat ~/.myscripts/docs/Fabric-Vision-Quick-Reference.md`

---

### 3. Investigation Summary
**File**: `Fabric-Vision-Investigation-Summary.md` (7.5 KB)

Detailed findings from the investigation:
- Key findings and debunked myths
- Current setup status
- Recommended next steps
- Example workflows

**Read it**: `cat ~/.myscripts/docs/Fabric-Vision-Investigation-Summary.md`

---

### 4. This Index
**File**: `Fabric-Vision-Index.md` (this file)

Central hub linking all documentation and resources.

---

## 🛠️ Scripts & Tools

### 1. Test Suite
**File**: `test-fabric-vision.sh` (executable)

Comprehensive 8-step test that checks:
- Fabric installation
- Attachment flag support
- Available patterns
- Vision-capable vendors
- API key configuration
- Custom pattern availability

**Run it**: `~/.myscripts/test-fabric-vision.sh`

---

### 2. Interactive Examples
**File**: `fabric-vision-examples.sh` (executable)

Interactive script demonstrating 8 different usage patterns:
- Basic text extraction
- Expert OCR
- JSON output
- Streaming responses
- File output
- Clipboard copying
- Model selection
- Custom prompts

**Run it**: `~/.myscripts/fabric-vision-examples.sh <your-image.jpg>`

---

### 3. Summary Display
**File**: `fabric-vision-summary.sh` (executable)

Beautiful formatted summary of everything created and configured.

**Run it**: `~/.myscripts/fabric-vision-summary.sh`

---

## 🎨 Custom Vision Patterns

### Location
All patterns are in: `~/.myscripts/fabric-custom-patterns/`

Also documented in: `fabric-custom-patterns/README.md`

---

### Pattern 1: image-text-extraction
**Created**: Before this investigation  
**File**: `image-text-extraction/system.md`

**Purpose**: Extract all visible text exactly as it appears

**Best for**:
- Device labels
- Signs and printed text
- Room identification
- Technical documentation

**Usage**:
```bash
fabric -a photo.jpg -p image-text-extraction
```

**Output**: Clean Markdown with structured text

---

### Pattern 2: expert-ocr-engine
**Created**: Before this investigation  
**File**: `expert-ocr-engine/system.md`

**Purpose**: High-accuracy OCR transcription

**Best for**:
- Technical identifiers
- Serial numbers
- MAC addresses
- IP addresses
- FortiCloud IDs

**Usage**:
```bash
fabric -a device.jpg -p expert-ocr-engine
```

**Output**: Markdown with section headers

---

### Pattern 3: analyze-image-json
**Created**: Today (October 7, 2025)  
**File**: `analyze-image-json/system.md`

**Purpose**: Comprehensive image analysis with structured JSON output

**Best for**:
- Programmatic processing
- Asset management
- Data extraction pipelines
- Multi-field analysis

**Usage**:
```bash
fabric -a asset.jpg -p analyze-image-json
```

**Output**: Valid JSON with fields:
- `image_type`, `description`, `objects`
- `text_content` (extracted text + language)
- `technical_details` (IDs, MACs, serials, IPs)
- `layout`, `colors`, `quality`
- `context` (environment, purpose)
- `metadata` (confidence, notes)

**Example - Extract specific data**:
```bash
fabric -a device.jpg -p analyze-image-json | jq .technical_details.identifiers
```

---

## 🚀 Quick Start Guide

### Step 1: Verify Setup
```bash
~/.myscripts/test-fabric-vision.sh
```

### Step 2: Configure (if needed)
If you don't have a vision model API key:

```bash
# Configure API key
fabric --setup

# Set default vision model
fabric -d
# Select: gpt-4o (recommended) or gemini-1.5-pro
```

### Step 3: Test with an Image
```bash
# Simple text extraction
fabric -a your-image.jpg -p image-text-extraction

# JSON output
fabric -a your-image.jpg -p analyze-image-json

# High-accuracy OCR
fabric -a your-image.jpg -p expert-ocr-engine
```

---

## 📖 Common Usage Patterns

### Extract Text from Device Label
```bash
fabric -a network_device.jpg -p image-text-extraction
```

### Get JSON Data for Asset Management
```bash
fabric -a asset.jpg -p analyze-image-json -o asset_data.json
```

### Process Multiple Images (Batch)
```bash
for img in devices/*.jpg; do
    fabric -a "$img" -p analyze-image-json -o "json/$(basename "$img" .jpg).json"
done
```

### Extract Only Technical IDs
```bash
echo "Extract only: MAC address, serial number, model number" | \
    fabric -a device.jpg -m gpt-4o
```

### From URL
```bash
fabric -a "https://example.com/photo.jpg" -p expert-ocr-engine
```

### Stream Long Responses
```bash
fabric -a complex_image.jpg -p analyze-image-json --stream
```

### Copy to Clipboard
```bash
fabric -a label.jpg -p image-text-extraction --copy
```

---

## 🤖 Recommended Vision Models

| Model | Provider | Command Flag | Best For |
|-------|----------|--------------|----------|
| **gpt-4o** ⭐ | OpenAI | `-m gpt-4o` | OCR, technical text, accuracy |
| gpt-4o-mini | OpenAI | `-m gpt-4o-mini` | Speed, lower cost |
| gemini-1.5-pro | Google | `-m gemini-1.5-pro` | Long context, multi-image |
| gemini-2.0-flash | Google | `-m gemini-2.0-flash` | Experimental features |
| claude-3.5-sonnet | Anthropic | `-m claude-3.5-sonnet` | Best reasoning |

**Current default**: LiteLLM|Groq-Moonshot-Kimi-K2-0905-Instruct (text-only)  
**Recommended**: Switch to `gpt-4o` for vision tasks

---

## ✅ What's Working

- ✓ Fabric v1.4.318 installed
- ✓ `--attachment` flag available
- ✓ 3 custom vision patterns created
- ✓ Vision vendors configured (OpenAI, Gemini, Anthropic)
- ✓ Complete documentation
- ✓ Test scripts ready

---

## ⚠️ What Needs Setup

- ⚠ API key for vision model (OpenAI/Gemini/Anthropic)
- ⚠ Default model should be set to a vision model

**Fix with**:
```bash
fabric --setup  # Add API key
fabric -d       # Set default vision model
```

---

## 💡 Key Insights from Investigation

1. **No built-in `analyze_image` pattern exists** - Perplexity documentation was incorrect
2. **Any pattern works with images** - Use `fabric -a <image> -p <pattern>`
3. **You already had excellent OCR patterns** - `image-text-extraction` and `expert-ocr-engine`
4. **New JSON pattern adds structure** - `analyze-image-json` for programmatic use
5. **Just needs API key configuration** - Everything else is ready

---

## 🔍 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Model doesn't support images" | Use `-m gpt-4o` or another vision model |
| "Pattern not found" | Check: `fabric --listpatterns` |
| "API key error" | Run: `fabric --setup` |
| Image too large | Resize: `convert large.jpg -resize 2048x2048\> small.jpg` |
| Output too long | Use filters: `head`, `tail`, `grep`, or `jq` |

---

## 📂 File Locations

### Documentation
- `~/.myscripts/docs/Fabric-Vision-Models-Guide.md`
- `~/.myscripts/docs/Fabric-Vision-Quick-Reference.md`
- `~/.myscripts/docs/Fabric-Vision-Investigation-Summary.md`
- `~/.myscripts/docs/Fabric-Vision-Index.md` (this file)

### Scripts
- `~/.myscripts/test-fabric-vision.sh`
- `~/.myscripts/fabric-vision-examples.sh`
- `~/.myscripts/fabric-vision-summary.sh`

### Patterns
- `~/.myscripts/fabric-custom-patterns/image-text-extraction/`
- `~/.myscripts/fabric-custom-patterns/expert-ocr-engine/`
- `~/.myscripts/fabric-custom-patterns/analyze-image-json/`
- `~/.myscripts/fabric-custom-patterns/README.md` (updated)

### Fabric Config
- `~/.config/fabric/.env` (API keys)
- `~/.config/fabric/patterns/` (installed patterns)

---

## 🎓 Learning Path

### Beginner
1. Read: `Fabric-Vision-Quick-Reference.md`
2. Run: `test-fabric-vision.sh`
3. Try: `fabric -a test.jpg -p image-text-extraction`

### Intermediate
1. Read: `Fabric-Vision-Models-Guide.md`
2. Run: `fabric-vision-examples.sh <image>`
3. Try all three custom patterns with different images

### Advanced
1. Read: `Fabric-Vision-Investigation-Summary.md`
2. Create custom patterns for your workflows
3. Build automation scripts with batch processing

---

## 🔗 External Resources

- **Fabric GitHub**: https://github.com/danielmiessler/fabric
- **Fabric Documentation**: Check GitHub wiki
- **OpenAI Vision API**: https://platform.openai.com/docs/guides/vision
- **Your Investigation**: `Fabric-Vision-Investigation-Summary.md`

---

## 🎉 Conclusion

You have **everything you need** to use Fabric with vision models:

✅ **Documentation** - Complete guides and references  
✅ **Patterns** - Three custom vision patterns ready  
✅ **Scripts** - Test suite and interactive examples  
✅ **Knowledge** - Clear understanding of how it works  

**Just configure an API key and start processing images!**

```bash
# Quick start command
~/.myscripts/test-fabric-vision.sh
```

---

*Documentation created: October 7, 2025*  
*Last updated: October 7, 2025*  
*Version: 1.0*
