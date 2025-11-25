# Image Metadata Pipeline - Quick Start

## Installation

Patterns are already installed in:
```
/Users/fabiofalopes/Documents/projetos/hub/.myscripts/fabric-custom-patterns/
```

## Basic Usage

### Process a directory (no context)
```bash
./image-metadata-pipeline.sh images/
```

### Process with context awareness
```bash
ENABLE_CONTEXT=true ./image-metadata-pipeline.sh images/
```

### Process with verbose output
```bash
ENABLE_CONTEXT=true VERBOSE=true ./image-metadata-pipeline.sh images/
```

### Process a single image
```bash
ENABLE_CONTEXT=true ./image-metadata-pipeline.sh images/IMG_5624.jpg
```

## Output

Each image produces a `.json` file with:
- Generated filename (slug)
- Description
- Structured analysis (objects, technical details, layout, colors, quality)
- OCR results (expert and multi-scale)
- Processing metadata

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ENABLE_CONTEXT` | `false` | Enable context-aware processing |
| `VERBOSE` | `false` | Show debug output |
| `SKIP_EXISTING` | `false` | Skip images that already have JSON |
| `VISION_MODEL` | `llama-4-maverick` | Vision model to use |
| `KEEP_SESSION` | `false` | Keep session after processing |

## Examples

### Batch process with context
```bash
ENABLE_CONTEXT=true ./image-metadata-pipeline.sh test-output/phase2-test/
```

### Skip already processed images
```bash
SKIP_EXISTING=true ./image-metadata-pipeline.sh images/
```

### Use different model
```bash
VISION_MODEL="meta-llama/llama-4-scout-17b-16e-instruct" ./image-metadata-pipeline.sh images/
```

## Output Structure

```json
{
  "original_filename": "IMG_5624.jpg",
  "generated_filename": "ubiquiti-air-router-hp-circuit-board",
  "description": "...",
  "analysis": {
    "image_type": "photo",
    "objects": [...],
    "text_content": {...},
    "technical_details": {
      "identifiers": {
        "model_numbers": [...],
        "serial_numbers": [...],
        ...
      }
    },
    ...
  },
  "ocr": {
    "expert": "...",
    "multi_scale": "..."
  },
  "metadata": {
    "processed_at": "2025-10-24T...",
    "pipeline_version": "1.0.0",
    "models_used": {...}
  }
}
```

## Troubleshooting

### No output files created
- Check `pipeline-errors.log`
- Verify fabric-ai is configured: `fabric-ai --setup`
- Test pattern: `fabric-ai --listpatterns | grep analyze`

### 413 errors
- Don't use sessions with vision models
- Context mode uses manual injection (no sessions)

### Invalid JSON
- Check pattern output: `fabric-ai -a image.jpg -p analyze-image-json`
- Verify jq is installed: `brew install jq`

## Performance

- **Processing Time**: ~20-25s per image
- **Context Overhead**: Minimal (~1-2s)
- **Memory Usage**: Low
- **Scalability**: Tested up to 10 images

## Custom Patterns

Located in: `/Users/fabiofalopes/Documents/projetos/hub/.myscripts/fabric-custom-patterns/`

- `analyze-image-json-with-context` - Main analysis
- `expert-ocr-with-context` - Specialized OCR
- `multi-scale-ocr-with-context` - Multi-resolution OCR

## Support

See documentation:
- `PHASE-2-COMPLETE.md` - Full implementation details
- `PHASE-2-RESULTS-SUMMARY.md` - Test results
- `PHASE-2-HANDOFF.md` - Original plan
- `RESEARCH-RESULTS.md` - Research findings
