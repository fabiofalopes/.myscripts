# Fabric Image Analysis Pipeline

**AI-powered image metadata extraction using fabric patterns for technical hardware documentation.**

---

## What Is This?

An intelligent image processing pipeline that transforms photos into rich, structured metadata using AI. Built on [fabric](https://github.com/danielmiessler/fabric), it extracts:

- **Semantic descriptions** - What the image shows, context, scene understanding
- **Technical specifications** - Model numbers, serial numbers, hardware details
- **Text extraction** - Multi-scale OCR, transcription of all readable text
- **Structural analysis** - Objects, composition, layout, quality assessment
- **Smart naming** - Content-aware, slugified filenames
- **JSON output** - Searchable, queryable, structured metadata

**Use Case**: Document hardware (routers, circuit boards, equipment) by taking photos and automatically extracting all technical information.

---

## Quick Start

```bash
# Process all images in a directory
./workflows/image-metadata-pipeline.sh images/

# Process with context awareness (images inform each other)
ENABLE_CONTEXT=true ./workflows/image-metadata-pipeline.sh images/

# Process single image
./workflows/image-metadata-pipeline.sh images/router-photo.jpg

# Skip already processed images
SKIP_EXISTING=true ./workflows/image-metadata-pipeline.sh images/
```

---

## How It Works

### 6-Stage Sequential Pipeline

```
Image Input (JPG/PNG)
    ↓
[1] Filename Generation → "ubiquiti-air-router-circuit-board"
    ↓
[2] Text Extraction → Full description of image content
    ↓
[3] Structured Analysis → JSON with objects, technical details, layout
    ↓
[4] Expert OCR → Specialized text extraction
    ↓
[5] Multi-Scale OCR → Multi-resolution text capture
    ↓
[6] JSON Aggregation → Combine all data into unified structure
    ↓
Output: image.jpg.json
```

### Example Output

```json
{
  "original_filename": "IMG_5624.jpg",
  "generated_filename": "ubiquiti-air-router-hp-circuit-board",
  "description": "Close-up photo of a Ubiquiti AirRouter HP circuit board...",
  "analysis": {
    "image_type": "photo",
    "objects": ["circuit board", "ethernet ports", "LEDs", "capacitors"],
    "text_content": {
      "visible_text": ["Ubiquiti", "AirRouter", "Model: AR-HP"],
      "labels": ["LAN 1-4", "WAN", "POWER"]
    },
    "technical_details": {
      "identifiers": {
        "model_numbers": ["AR-HP", "AirRouter HP"],
        "serial_numbers": ["SN: 04FC66E12345"]
      },
      "specifications": ["5 Ethernet ports", "PoE powered"]
    },
    "layout": {
      "composition": "centered",
      "orientation": "landscape"
    },
    "quality_assessment": {
      "clarity": "high",
      "lighting": "good"
    }
  },
  "ocr": {
    "expert": "Detailed OCR text...",
    "multi_scale": "Multi-resolution OCR text..."
  },
  "metadata": {
    "processed_at": "2025-10-24T10:30:00Z",
    "pipeline_version": "1.0.0",
    "models_used": {
      "vision": "meta-llama/llama-4-maverick-17b-128e-instruct",
      "text": "llama-3.3-70b-versatile"
    }
  }
}
```

---

## Features

### Core Capabilities
- **Batch Processing** - Process entire directories automatically
- **Smart Validation** - Validates and repairs JSON at every stage
- **Error Handling** - Retry logic, fallbacks, comprehensive logging
- **Skip Processed** - Avoid reprocessing images that already have metadata
- **Context Awareness** - Optional mode where images inform each other
- **Configurable Models** - Choose vision and text models via environment variables

### Context-Aware Mode (Phase 2)
When enabled, the pipeline builds contextual understanding across images:
- Each image's analysis informs the next
- Identifies patterns and relationships
- Improves accuracy for similar images
- Maintains session context

```bash
ENABLE_CONTEXT=true ./workflows/image-metadata-pipeline.sh images/
```

---

## Installation

### Requirements
- **fabric-ai** v1.4.316+ - Install from [fabric](https://github.com/danielmiessler/fabric)
- **jq** - JSON processor (`brew install jq`)
- **Groq API** - For llama-4-maverick model access
- **bash 4.0+** - Modern bash shell

### Setup

1. **Install fabric-ai**
   ```bash
   # Follow fabric installation guide
   # Configure API keys: fabric-ai --setup
   ```

2. **Install custom patterns**
   ```bash
   # Copy patterns to fabric directory
   cp -r fabric-custom-patterns/* ~/.config/fabric/patterns/
   ```

3. **Configure environment**
   ```bash
   # Fix fabric timeout (if needed)
   echo "OLLAMA_HTTP_TIMEOUT=14m" >> ~/.config/fabric/.env
   ```

4. **Test installation**
   ```bash
   # Verify fabric works
   echo "test" | fabric-ai -p name-file-gen
   
   # List available patterns
   fabric-ai --listpatterns | grep analyze
   ```

---

## Usage

### Basic Usage

```bash
# Process directory
./workflows/image-metadata-pipeline.sh images/

# Process single image
./workflows/image-metadata-pipeline.sh images/photo.jpg

# Verbose mode
VERBOSE=true ./workflows/image-metadata-pipeline.sh images/
```

### Advanced Options

```bash
# Skip already processed images
SKIP_EXISTING=true ./workflows/image-metadata-pipeline.sh images/

# Use different vision model
VISION_MODEL="meta-llama/llama-4-scout-17b-16e-instruct" \
  ./workflows/image-metadata-pipeline.sh images/

# Context-aware processing
ENABLE_CONTEXT=true ./workflows/image-metadata-pipeline.sh images/

# Maximum retries for failed stages
MAX_RETRIES=3 ./workflows/image-metadata-pipeline.sh images/
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `VISION_MODEL` | `llama-4-maverick-17b` | Vision model for image analysis |
| `TEXT_MODEL` | `llama-3.3-70b` | Text model for JSON processing |
| `SKIP_EXISTING` | `false` | Skip images with existing JSON |
| `VERBOSE` | `false` | Show debug output |
| `MAX_RETRIES` | `2` | Retry attempts for failed stages |
| `ENABLE_CONTEXT` | `false` | Enable context-aware mode |

---

## Custom Patterns

The pipeline uses specialized fabric patterns optimized for technical image analysis:

### Core Patterns
- **name-file-gen** - Generate content-aware slugified filenames
- **image-text-extraction** - Extract semantic descriptions
- **analyze-image-json** - Structured analysis with objects, technical details
- **expert-ocr-engine** - Specialized OCR for technical text
- **multi-scale-ocr** - Multi-resolution text extraction
- **json-parser** - Aggregate and validate JSON output

### Context-Aware Patterns (Phase 2)
- **analyze-image-json-with-context** - Analysis with prior image context
- **expert-ocr-with-context** - OCR with contextual understanding
- **multi-scale-ocr-with-context** - Context-aware multi-scale OCR

---

## Output Structure

Each processed image generates a `.json` file with this structure:

```json
{
  "original_filename": "string",
  "generated_filename": "string (slug)",
  "description": "string (full text description)",
  "analysis": {
    "image_type": "photo|diagram|screenshot|document",
    "objects": ["array of identified objects"],
    "text_content": {
      "visible_text": ["all readable text"],
      "labels": ["device labels, warnings"],
      "serial_numbers": ["serial numbers found"]
    },
    "technical_details": {
      "identifiers": {
        "model_numbers": ["model numbers"],
        "serial_numbers": ["serial numbers"],
        "part_numbers": ["part numbers"]
      },
      "specifications": ["technical specs"]
    },
    "layout": {
      "composition": "string",
      "orientation": "landscape|portrait"
    },
    "colors": {
      "dominant": ["color list"],
      "palette": ["color palette"]
    },
    "quality_assessment": {
      "clarity": "high|medium|low",
      "lighting": "good|adequate|poor"
    }
  },
  "ocr": {
    "expert": "string (specialized OCR)",
    "multi_scale": "string (multi-resolution OCR)"
  },
  "metadata": {
    "processed_at": "ISO 8601 timestamp",
    "pipeline_version": "string",
    "models_used": {
      "vision": "string",
      "text": "string"
    }
  }
}
```

---

## Architecture

### Sequential Processing
Each stage validates its input and output, with retry logic and fallbacks:

1. **Validation** - Check image format, readability, skip if already processed
2. **Filename Generation** - AI-generated slug, validated against pattern
3. **Text Extraction** - Full description, minimum length check
4. **Structured Analysis** - JSON output, validated and repaired if needed
5. **Expert OCR** - Specialized text extraction
6. **Multi-Scale OCR** - Multi-resolution text capture
7. **Aggregation** - Combine all data, final JSON validation

### Error Handling
- **Transient errors** (API timeout) → Retry with backoff
- **Validation failures** → Attempt repair, fallback to empty/default
- **Permanent errors** → Log and skip image
- **All errors** → Written to `pipeline-errors.log`

### Model Selection
- **Vision tasks** (stages 2-5) → llama-4-maverick-17b (image input support)
- **Text tasks** (stages 1, 6) → llama-3.3-70b (better JSON generation)

---

## Troubleshooting

### No output files created
```bash
# Check error log
cat pipeline-errors.log

# Verify fabric configuration
fabric-ai --setup

# Test pattern manually
fabric-ai -a image.jpg -p analyze-image-json
```

### Invalid JSON errors
```bash
# Check pattern output directly
fabric-ai -a image.jpg -p analyze-image-json | jq .

# Verify jq is installed
which jq
```

### HTTP timeout warnings
```bash
# Fix fabric configuration
echo "OLLAMA_HTTP_TIMEOUT=14m" >> ~/.config/fabric/.env
```

### 413 Request Entity Too Large
- Don't use fabric sessions with vision models
- Context mode uses manual injection (no sessions)
- Reduce image size if needed

---

## Performance

- **Processing Time**: ~20-25 seconds per image
- **Context Overhead**: Minimal (~1-2 seconds)
- **Memory Usage**: Low
- **Scalability**: Tested with 20+ images

---

## Integration

### With Documentation Systems
```bash
# Generate technical docs from metadata
cat *.json | jq -s '.' | fabric-ai -p create_technical_docs

# Create inventory from images
cat *.json | jq -s '[.[] | {model: .analysis.technical_details.identifiers.model_numbers[0], serial: .analysis.technical_details.identifiers.serial_numbers[0]}]'
```

### With Search Systems
```bash
# Index metadata for search
for json in *.json; do
  jq -c '{filename: .original_filename, content: .description, objects: .analysis.objects}' "$json"
done | # pipe to search indexer
```

---

## Project Structure

```
fabric-image-analysis/
├── README.md                           # This file
├── workflows/
│   └── image-metadata-pipeline.sh      # Main processing script
├── fabric-custom-patterns/             # Custom fabric patterns
│   ├── analyze-image-json-with-context/
│   ├── expert-ocr-with-context/
│   └── multi-scale-ocr-with-context/
├── docs/                               # Additional documentation
│   ├── ARCHITECTURE.md
│   ├── PHASE-2-FEATURES.md
│   └── COST-OPTIMIZATION.md
└── images/                             # Your images (not included)
```

---

## Future Enhancements (Phase 2)

- **External Knowledge Base** - Validate against documentation
- **Cross-Image Validation** - Verify consistency across images
- **Cost Optimization** - Smart model selection based on image complexity
- **High-Accuracy Mode** - Multiple model consensus for critical images
- **Parallel Processing** - Process multiple images simultaneously

---

## License

[Your License Here]

---

## Credits

Built on [fabric](https://github.com/danielmiessler/fabric) by Daniel Miessler

---

**Status**: Production-ready (Phase 1 complete, Phase 2 in development)
