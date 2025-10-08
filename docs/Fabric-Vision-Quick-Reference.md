# Fabric Vision - Quick Reference Card

## Basic Syntax
```bash
fabric -a <image> -p <pattern> [options]
```

## Your Custom Vision Patterns

| Pattern | Purpose | Use Case |
|---------|---------|----------|
| `image-text-extraction` | Extract all visible text | Device labels, signs, documents |
| `expert-ocr-engine` | High-accuracy OCR | Technical IDs, serial numbers |
| `analyze-image-json` | Structured JSON output | Programmatic analysis, data extraction |

## Common Commands

### Text Extraction
```bash
# Basic extraction
fabric -a image.jpg -p image-text-extraction

# From URL
fabric -a "https://example.com/photo.jpg" -p expert-ocr-engine

# Save to file
fabric -a image.jpg -p image-text-extraction -o output.md

# Copy to clipboard
fabric -a image.jpg -p expert-ocr-engine --copy
```

### JSON Output
```bash
# Get structured data
fabric -a device.jpg -p analyze-image-json

# Save JSON
fabric -a device.jpg -p analyze-image-json -o data.json

# With specific model
fabric -a image.jpg -p analyze-image-json -m gpt-4o
```

### Advanced Usage
```bash
# Stream response
fabric -a image.jpg -p image-text-extraction --stream

# Low temperature (more focused)
fabric -a image.jpg -p image-text-extraction -t 0.1

# Custom prompt with image
echo "Extract only MAC addresses" | fabric -a device.jpg

# Multiple images
fabric -a img1.jpg -a img2.jpg -p image-text-extraction
```

## Batch Processing
```bash
# Process all JPG images in a directory
for img in images/*.jpg; do
    fabric -a "$img" -p image-text-extraction -o "output/$(basename "$img" .jpg).md"
done

# Process with JSON output
for img in devices/*.jpg; do
    fabric -a "$img" -p analyze-image-json -o "json/$(basename "$img" .jpg).json"
done
```

## Vision-Capable Models

| Model | Provider | Command |
|-------|----------|---------|
| gpt-4o | OpenAI | `-m gpt-4o` |
| gpt-4o-mini | OpenAI | `-m gpt-4o-mini` |
| gpt-4-turbo | OpenAI | `-m gpt-4-turbo` |
| gemini-1.5-pro | Google | `-m gemini-1.5-pro` |
| gemini-2.0-flash | Google | `-m gemini-2.0-flash` |
| claude-3.5-sonnet | Anthropic | `-m claude-3.5-sonnet` |

## Setup Steps

1. **Configure API Key**
   ```bash
   fabric --setup
   ```

2. **Set Default Vision Model**
   ```bash
   fabric -d
   # Select a vision model from the list
   ```

3. **Test**
   ```bash
   fabric -a test.jpg -p image-text-extraction
   ```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Model doesn't support images" | Use `-m gpt-4o` or another vision model |
| "Pattern not found" | Check pattern name: `fabric --listpatterns` |
| "API key error" | Run `fabric --setup` and configure keys |
| Image too large | Resize: `convert big.jpg -resize 2048x2048\> small.jpg` |

## Tips

✓ **Use high-resolution images** for better OCR accuracy  
✓ **Start with `-t 0.1`** for factual text extraction  
✓ **Use `--stream`** for long analyses to see progress  
✓ **Save outputs** with `-o` for documentation  
✓ **Test different patterns** to find what works best  

## Files & Locations

- **Guide**: `~/.myscripts/docs/Fabric-Vision-Models-Guide.md`
- **Test Script**: `~/.myscripts/test-fabric-vision.sh`
- **Examples**: `~/.myscripts/fabric-vision-examples.sh`
- **Patterns**: `~/.myscripts/fabric-custom-patterns/`
- **Config**: `~/.config/fabric/.env`

## Quick Test

```bash
# Run comprehensive test
~/.myscripts/test-fabric-vision.sh

# Interactive examples
~/.myscripts/fabric-vision-examples.sh <your-image.jpg>
```

---

**Remember**: There is **NO** built-in `analyze_image` pattern. Use your custom patterns or create new ones!
