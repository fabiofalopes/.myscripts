# Fabric Custom Patterns

## Purpose

This directory contains **custom AI prompts (patterns) for the fabric framework**.

These patterns are designed to be **orchestrated by bash scripts** that pipe data through multiple AI agents to create complex workflows.

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

## Script Examples Using These Patterns

### txrefine
Two-stage transcription refinement:
```bash
voicenote | txrefine
# Stage 1: Raw → transcript-analyzer → Analysis
# Stage 2: (Raw + Analysis) → transcript-refiner → Refined output
```

---

**Remember**: Patterns are AI agents. Scripts are the orchestrators. Together they create powerful workflows.
