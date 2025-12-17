# Fabric Custom Patterns

## Purpose

This directory contains **custom AI prompts (patterns) for the fabric framework**.

These patterns are designed to be **orchestrated by bash scripts** that pipe data through multiple AI agents to create complex workflows.

## Vision & OCR Patterns

### image-text-extraction
**Purpose**: Extract all visible text from images exactly as it appears, with focus on technical identifiers.

**Use when**: You need to extract text from device labels, signs, technical documentation, or any image with text.

**Input**: Image (via `fabric -a <image>`)

**Output**: Clean Markdown with structured text extraction

**Best for**:
- Device labels (MAC addresses, serial numbers, model numbers)
- Room identification tags
- Technical documentation
- Signs and printed materials
- Configuration screens

**Example**:
```bash
fabric -a device_photo.jpg -p image-text-extraction
fabric -a "https://example.com/label.jpg" -p image-text-extraction -o output.md
```

---

### expert-ocr-engine
**Purpose**: High-accuracy OCR transcription with focus on technical identifiers and structured output.

**Use when**: You need precise text extraction with minimal errors, especially for technical content.

**Input**: Image (via `fabric -a <image>`)

**Output**: Markdown with section headers and grouped related text

**Best for**:
- Serial numbers and technical IDs
- Engraved or printed labels
- MAC addresses, IP addresses
- FortiCloud IDs and device identifiers
- Any technical text requiring high accuracy

**Example**:
```bash
fabric -a network_device.jpg -p expert-ocr-engine
fabric -a document.png -p expert-ocr-engine --copy
```

---

### analyze-image-json
**Purpose**: Comprehensive image analysis with structured JSON output including OCR, object detection, and metadata.

**Use when**: You need programmatic access to image analysis data or want structured output for further processing.

**Input**: Image (via `fabric -a <image>`)

**Output**: Valid JSON with multiple fields:
- `image_type`: Category of the image
- `description`: Overall description
- `objects`: List of identified objects
- `text_content`: Extracted text with language detection
- `technical_details`: MAC addresses, serial numbers, IPs, etc.
- `layout`: Composition and orientation info
- `colors`: Dominant and accent colors
- `quality`: Resolution, clarity, lighting assessment
- `context`: Environment and purpose categorization
- `metadata`: Confidence score, notes, detected features

**Best for**:
- Asset management and inventory systems
- Automated documentation workflows
- Data extraction pipelines
- Programmatic image processing
- Multi-field analysis requirements

**Example**:
```bash
fabric -a asset.jpg -p analyze-image-json
fabric -a device.jpg -p analyze-image-json -o data.json
fabric -a photo.jpg -p analyze-image-json | jq .technical_details
```

---

### ultra-ocr-engine
**Purpose**: Maximum-effort OCR extraction with aggressive prompt engineering for degraded, low-resolution, or challenging images.

**Use when**: Standard OCR patterns fail on low-quality images, compressed documents, or when you need to extract text from difficult visual conditions.

**Input**: Image (via `fabric -a <image>`)

**Output**: Structured Markdown with:
- Full transcription with preserved structure
- Technical identifiers categorized
- Low-confidence annotations with uncertainty flags
- Structural metadata
- Confidence ratings for uncertain text

**Best for**:
- Low-resolution full-page documents
- Compressed or degraded images
- Faded or poor-contrast text
- Small/micro-text extraction
- Images with noise or artifacts
- Maximum text recovery scenarios

**Special features**:
- Multi-stage processing (visual analysis → extraction → reconstruction → confidence weighting)
- Aggressive contextual inference
- Pattern completion for partial characters
- Explicit low-resolution mode
- Sub-pixel inference techniques
- Transparent uncertainty flagging

**Example**:
```bash
fabric -a low_res_document.jpg -p ultra-ocr-engine
fabric -a degraded_photo.png -p ultra-ocr-engine --stream
fabric -a compressed_scan.jpg -p ultra-ocr-engine -o output.md
```

**Technical note**: Designed to address the "low-res full page problem" where vision models fail to extract text from full pages but succeed on cropped regions.

---

### multi-scale-ocr
**Purpose**: Hierarchical multi-scale text extraction using systematic zoom-level processing to overcome resolution limitations.

**Use when**: Processing full-page low-resolution documents where standard patterns miss text, especially structured documents with varying text sizes.

**Input**: Image (via `fabric -a <image>`)

**Output**: Comprehensive structured report with:
- Document overview and quality assessment
- Multi-scale extraction results (MACRO/MESO/MICRO/SUB-PIXEL levels)
- Integrated full transcription
- Extraction quality report with coverage and confidence metrics
- Problem area identification
- Re-capture recommendations

**Best for**:
- Full-page low-resolution documents
- Documents with mixed text sizes (headers, body, footnotes)
- Structured documents (forms, technical manuals)
- Multi-region documents requiring systematic processing
- Quality assessment and gap analysis

**Processing levels**:
1. **MACRO**: Overall structure, titles, headers, large text
2. **MESO**: Body paragraphs, lists, tables, medium text
3. **MICRO**: Fine details, codes, serial numbers, small print
4. **SUB-PIXEL**: Inference zone for barely visible text

**Special features**:
- Hierarchical context propagation (large text informs small text interpretation)
- Format-aware pattern matching (MAC addresses, IPs, dates, etc.)
- Linguistic probability for unclear characters
- Spatial reasoning based on document layout
- Virtual sectioning for full pages
- Multi-hypothesis generation for ambiguous text

**Example**:
```bash
fabric -a full_page_lowres.jpg -p multi-scale-ocr
fabric -a technical_manual.png -p multi-scale-ocr -o analysis.md
fabric -a form_scan.jpg -p multi-scale-ocr --stream
```

**Technical note**: Specifically designed to solve the resolution-dependent OCR failure problem by processing the image at multiple conceptual "zoom levels" simultaneously.

---

## OCR Pattern Comparison

| Pattern | Best For | Resolution Handling | Output Format | Speed |
|---------|----------|---------------------|---------------|-------|
| **image-text-extraction** | Clean images, simple extraction | Good → Medium | Clean Markdown | Fast |
| **expert-ocr-engine** | Technical IDs, high accuracy needed | Good → Medium | Structured Markdown | Fast |
| **analyze-image-json** | Programmatic use, multi-field data | Good → Medium | JSON | Medium |
| **ultra-ocr-engine** | Degraded/low-res, maximum effort | Medium → Poor | Detailed Markdown + Confidence | Slow |
| **multi-scale-ocr** | Full page low-res, structured docs | Medium → Poor | Comprehensive Report | Slow |

**Recommendation**:
- Start with `image-text-extraction` or `expert-ocr-engine` for normal images
- Use `ultra-ocr-engine` when they fail or for known poor-quality images
- Use `multi-scale-ocr` for full-page low-resolution documents
- Use `analyze-image-json` when you need structured programmatic output

---

## Search Optimization Patterns

### deep_search_optimizer
**Purpose**: Transform any input into highly effective deep search prompts optimized for AI search engines (Perplexity, ChatGPT search, Claude search).

**Use when**: You have a question, problem, or topic and need to generate the optimal search prompt to find comprehensive, factual information.

**Input**: Any text (questions, problems, transcriptions, vague ideas)

**Output**: Multiple optimized search prompts with alternatives, metadata, and optimization notes

**Example**:
```bash
echo "quantum computing" | fabric -p deep_search_optimizer
```

---

### search_query_generator
**Purpose**: Extract multiple focused search queries from content (articles, transcriptions, notes, discussions).

**Use when**: You have a document or conversation and want to identify all the key points that should be researched or verified.

**Input**: Any text content (articles, meeting notes, research ideas)

**Output**: Multiple targeted search queries with prioritization and metadata

**Example**:
```bash
cat meeting-notes.txt | fabric -p search_query_generator
```

---

### search_refiner
**Purpose**: Fix and improve poorly formulated search queries.

**Use when**: You have a search query that's too vague, generic, or poorly structured and needs optimization.

**Input**: One or more rough search queries

**Output**: Refined queries with problem identification and improvement explanations

**Example**:
```bash
echo "tell me about AI" | fabric -p search_refiner
```

---

## Development Model

### Pattern ↔ Script Development Cycle

```
┌─────────────────────────────────────────────────┐
│  PATTERN DEVELOPMENT (here)                     │
│  - Design AI prompts (system.md)                │
│  - Define input/output formats                  │
│  - Specify analysis/transformation logic        │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  SCRIPT DEVELOPMENT (.myscripts)                │
│  - Chain patterns together                      │
│  - Handle input/output piping                   │
│  - Create user-facing workflows                 │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│  TEST & ITERATE (both locations)                │
│  - Run script → observe pattern outputs         │
│  - Refine prompts → test script again           │
│  - Co-development in same workspace             │
└─────────────────────────────────────────────────┘
```

### Symlink Architecture

This directory is symlinked from `~/.myscripts/fabric-patterns`:

```bash
# Original (this location - tracked in Obsidian)
~/Documents/Obsidian_Vault_01/Vault_01/fabric-custom-patterns/

# Symlink (for script development)
~/.myscripts/fabric-patterns/  →  (same files)
```

**Why?** So we can develop scripts and patterns in the same workspace:
```bash
cd ~/.myscripts
vim fabric-patterns/my-pattern/system.md   # Edit pattern
vim my-script                               # Edit script
echo "test" | ./my-script                   # Test workflow
```

## Pattern Structure

Each pattern is a directory with:
- `system.md` - The AI prompt/instructions
- (optional) `user.md` - Example user inputs

Patterns are invoked via fabric:
```bash
echo "input" | fabric -p pattern-name
```

## Current Patterns

### workflow-architect
**Purpose**: Help design and architect multi-stage AI agent workflows

**Input**: Description of desired workflow or problem to solve

**Output**: Complete workflow design including:
- Pipeline stage breakdown
- Pattern specifications for each agent
- Bash script structure
- System prompt templates
- Testing strategy
- Implementation guidance

**Used by**: Developers creating new fabric pattern workflows

**Usage**:
```bash
echo "I want to create a workflow that..." | fabric -p workflow-architect
cat workflow-idea.txt | fabric -p workflow-architect
```

### transcript-analyzer
**Purpose**: Analyze raw transcriptions for errors and issues

**Input**: Raw transcription text (from voice-to-text tools)

**Output**: Structured analysis report identifying:
- Typos and spelling errors
- Repeated words
- Filler words ("um", "like", "and stuff")
- Technical terms needing formatting
- Punctuation and structure issues

**Used by**: `txrefine` script (stage 1)

### transcript-refiner
**Purpose**: Refine transcription based on analysis

**Input**: 
- Raw transcription text
- Analysis report (from transcript-analyzer)

**Output**: Refined transcription with:
- Corrected spelling/typos
- Removed filler words
- Properly formatted technical terms
- Improved punctuation
- Better structure (paragraphs, lists)
- **Original meaning preserved**

**Used by**: `txrefine` script (stage 2)

## Pattern Development Guidelines

When creating new patterns for script orchestration:

1. **Define Clear Inputs/Outputs**: Scripts need to know what format to expect
2. **Make Patterns Composable**: Design to work in chains/pipelines
3. **Keep Single Responsibility**: One pattern = one transformation/analysis
4. **Document Expected Format**: Especially for multi-stage workflows
5. **Test with Real Data**: Use actual script outputs as test inputs

## Example: Creating a New Workflow

```bash
# 1. Create pattern directories
mkdir -p ~/.myscripts/fabric-patterns/my-analyzer
mkdir -p ~/.myscripts/fabric-patterns/my-processor

# 2. Write prompts
vim ~/.myscripts/fabric-patterns/my-analyzer/system.md
vim ~/.myscripts/fabric-patterns/my-processor/system.md

# 3. Create orchestration script
vim ~/.myscripts/my-workflow

# 4. Test the pipeline
echo "test input" | ~/.myscripts/my-workflow
```

## Obsidian Note Enhancement Patterns

### obsidian_note_title
**Purpose**: Generate natural, human-readable titles for Obsidian notes

**Input**: Raw note content

**Output**: Single title string (50-80 characters, properly capitalized)

**Example**:
```bash
cat note.md | fabric -p obsidian_note_title
```

---

### obsidian_frontmatter_gen
**Purpose**: Generate complete YAML frontmatter metadata for Obsidian notes

**Input**: Raw note content

**Output**: Complete YAML frontmatter block with:
- title
- aliases (alternative names for linking)
- tags (2-5 relevant categories)
- created (date in YYYY-MM-DD)
- type (idea, reference, project, meeting, journal, article, snippet, log)
- status (draft, active, review, archived, permanent)
- summary (one-line description)

**Example**:
```bash
cat note.md | fabric -p obsidian_frontmatter_gen
```

---

### obsidian_note_polish
**Purpose**: Combined pattern - generates both title and frontmatter in one pass

**Input**: Raw note content

**Output**: Formatted output with both title and complete frontmatter block

**Example**:
```bash
cat note.md | fabric -p obsidian_note_polish
```

---

## Script Examples Using These Patterns

### txrefine
Two-stage transcription refinement:
```bash
voicenote | txrefine
# Stage 1: Raw → transcript-analyzer → Analysis
# Stage 2: (Raw + Analysis) → transcript-refiner → Refined output
```

### obsidian-polish
Obsidian note enhancement workflow:
```bash
pbpaste | obsidian-polish           # Combined mode (default)
cat note.md | obsidian-polish -t    # Title only
cat note.md | obsidian-polish -f    # Frontmatter only
```

**See [OBSIDIAN-WORKFLOW.md](./OBSIDIAN-WORKFLOW.md) for complete documentation.**

---

**Remember**: Patterns are AI agents. Scripts are the orchestrators. Together they create powerful workflows.
