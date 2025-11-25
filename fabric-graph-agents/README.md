# Fabric Graph Agents

**Intelligent orchestration system for fabric patterns with dynamic agent selection and dimensional content processing.**

---

## What Is This?

Fabric Graph Agents is an infrastructure layer built on top of [fabric](https://github.com/danielmiessler/fabric) that provides:

1. **Dimensional Extraction** - Breaks messy, unstructured input into coherent topic clusters
2. **Intelligent Routing** - Analyzes content and selects appropriate processing agents
3. **Dynamic Workflows** - Chains fabric patterns based on content type, not hardcoded rules
4. **Agent Composition** - Reusable processing units that can be piped and combined
5. **Session Management** - Maintains context across multi-stage analysis

**Core Innovation**: Instead of dumping all content into one fabric pattern and hoping for good results, we extract semantic dimensions first, then intelligently route each dimension through appropriate processing pipelines.

---

## Quick Start

### Basic Dimension Extraction
```bash
# Extract dimensions from any text
cat your-rambling-thoughts.txt | fabric --pattern dimension_extractor_ultra

# Creates organized dimension files
# - technical-concerns.md
# - security-questions.md
# - philosophical-thoughts.md
```

### Using Agents
```bash
# Question narrowing
cat vague-question.txt | agents/question_narrowing.sh

# Threat intelligence
cat security-topic.txt | agents/threat_intelligence.sh

# Wisdom synthesis
cat research-notes.txt | agents/wisdom_synthesis.sh
```

### Full Workflow (Current - Hardcoded)
```bash
# Runs all agents regardless of content
./workflows/full-analysis.sh input.txt
```

### Future: Intelligent Routing
```bash
# Analyzes content, selects relevant agents only
./workflows/adaptive-analysis.sh input.txt
```

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────┐
│ INPUT: Any text (structured, rambling, mixed topics)    │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│ STAGE 1: Dimensional Extraction                         │
│ Pattern: dimension_extractor_ultra                      │
│ Output: N dimension files (coherent topic clusters)     │
└────────────────┬────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│ STAGE 2: Intelligent Router (TO BE BUILT)               │
│ - Analyzes dimension types/keywords                     │
│ - Detects content domain                                │
│ - Selects appropriate agents                            │
│ - Builds execution plan                                 │
└────────────────┬────────────────────────────────────────┘
                 ↓
         ┌───────┴───────┐
         ↓               ↓
┌─────────────────┐ ┌─────────────────┐
│ Domain-Specific │ │ Generic         │
│ Agents          │ │ Processing      │
│                 │ │                 │
│ - Security      │ │ - extract_wisdom│
│ - Research      │ │ - improve_prompt│
│ - Config        │ │ - Any fabric    │
└────────┬────────┘ └────────┬────────┘
         │                   │
         └───────┬───────────┘
                 ↓
┌─────────────────────────────────────────────────────────┐
│ STAGE 3: Synthesis & Output                             │
│ - Combines results                                      │
│ - Creates action plans                                  │
│ - Generates follow-ups                                  │
└─────────────────────────────────────────────────────────┘
```

### Core Components

#### 1. Custom Fabric Patterns
Location: `../fabric-custom-patterns/` (main patterns folder)

**Required patterns for fabric-graph-agents:**
- **dimension_extractor_ultra** - Extracts semantic dimensions from any input
- **validate_extraction** - Judges extraction quality
- **plan_pattern_graph** - Plans execution strategies

**Note**: Patterns are stored in the main `fabric-custom-patterns/` folder at the root of MyScripts, not within this directory. This keeps all custom patterns centralized and accessible to all workflows.

#### 2. Agents
Location: `agents/`

Each agent is:
- A custom fabric pattern in `../fabric-custom-patterns/<name>/system.md`
- A wrapper script in `agents/<name>.sh`
- Configurable via header variables (model, pattern, options)

**Current Agents:**
- `question_narrowing.sh` - Refines vague questions into specific ones
- `threat_intelligence.sh` - Generates research queries for security topics
- `config_validator.sh` - Validates configurations against security best practices
- `wisdom_synthesis.sh` - Extracts insights and creates action plans

#### 3. Core Libraries
Location: `lib/`

- **dimensional.sh** - Dimension extraction and management
- **graph.sh** - Graph execution engine (parallel/sequential)
- **quality.sh** - Output quality validation
- **fabric-wrapper.sh** - Handles fabric/fabric-ai aliasing
- **context_selector.sh** - Intelligent context selection
- **pattern_planner.sh** - Pattern graph planning

#### 4. Workflows
Location: `workflows/`

- **full-analysis.sh** - Complete analysis (hardcoded agents)
- **create-knowledge-base.sh** - Simple dimension extraction
- **adaptive-analysis.sh** - (TO BE BUILT) Intelligent routing

---

## How It Works

### Dimensional Extraction

**Problem**: Messy input with multiple topics mixed together

**Solution**: Extract semantic dimensions - coherent topic clusters

**Example Input:**
```
I'm setting up OpenWrt on my Ubiquiti router. I hacked the UART 
with a voltage divider. Now I'm wondering about packet injection 
capabilities. Also, can I connect my Raspberry Pi with Kali Linux? 
And what about MEO WiFi captive portals?
```

**Extracted Dimensions:**
```
dimensions/
├── hardware-specs.md          (technical)
├── uart-hack-solution.md      (technical)
├── packet-injection-questions.md (security)
├── raspberry-pi-setup.md      (technical)
└── captive-portal-bypass.md   (security)
```

**Each dimension:**
- Preserves original voice
- Contains one coherent topic
- Has metadata (type, weight, keywords)
- Can be processed independently

### Intelligent Routing (Vision)

**Current Problem**: Hardcoded workflows run all agents always

```bash
# This runs security analysis on ANY content
./full-analysis.sh random-thoughts.txt
# ❌ Wastes time on irrelevant analysis
```

**Solution**: Analyze dimensions, select relevant agents

```bash
# This analyzes content first, then routes intelligently
./adaptive-analysis.sh random-thoughts.txt
# ✅ Only runs relevant processing
```

**Routing Logic:**

```python
if dimensions contain security keywords:
    run: threat_intelligence, config_validator, security_analysis
elif dimensions contain research keywords:
    run: question_narrowing, search_queries
elif dimensions contain code:
    run: code_analysis, extract_patterns
else:
    run: extract_wisdom, improve_prompt
```

### Agent Composition

**Agents are composable:**

```bash
# Single agent
cat input.txt | question_narrowing.sh

# Chained agents
cat input.txt | question_narrowing.sh | threat_intelligence.sh

# With session context
fabric --session analysis --pattern dimension_extractor_ultra < input.txt
fabric --session analysis --pattern question_narrowing  # Continues context
```

---

## Configuration

### Model Selection

Edit agent script headers:

```bash
# agents/question_narrowing.sh
MODEL="openai/gpt-4"
PATTERN="question_narrowing"
SESSION="my-analysis"  # Optional
```

### Fabric Setup

Agents use `fabric-ai` or `fabric` automatically via wrapper:

```bash
# lib/fabric-wrapper.sh handles aliasing
# No configuration needed
```

### Custom Patterns

Add new patterns to the main patterns folder:

```bash
../fabric-custom-patterns/
└── my-new-pattern/
    └── system.md
```

Pattern structure:

```markdown
# IDENTITY
You are a <role>...

# GOAL
Your purpose is to...

# STEPS
- Step 1
- Step 2

# OUTPUT
Structured format...
```

---

## Creating New Agents

### 1. Create Pattern

```bash
mkdir -p ../fabric-custom-patterns/my-agent
cat > ../fabric-custom-patterns/my-agent/system.md << 'EOF'
# IDENTITY
You are an expert at <task>

# GOAL
Your purpose is to <goal>

# STEPS
- Analyze input
- Process content
- Generate output

# OUTPUT
Provide structured results
EOF
```

### 2. Create Wrapper Script

```bash
cat > agents/my-agent.sh << 'EOF'
#!/bin/bash
MODEL="openai/gpt-4"
PATTERN="my-agent"

fabric-ai --model "$MODEL" --pattern "$PATTERN" "$@"
EOF

chmod +x agents/my-agent.sh
```

### 3. Test

```bash
echo "test input" | agents/my-agent.sh
```

---

## Session Management

**Use sessions for multi-stage analysis:**

```bash
# Stage 1: Extract dimensions
fabric --session my-analysis --pattern dimension_extractor_ultra < input.txt

# Stage 2: Continue with context
fabric --session my-analysis --pattern question_narrowing

# Stage 3: Synthesize with full context
fabric --session my-analysis --pattern wisdom_synthesis
```

**Benefits:**
- Context persists across calls
- No need to re-send full input
- More coherent multi-stage analysis

---

## Debugging

### Cache Everything

All agent outputs are cached:

```
.cache/
├── dimension-extraction/
├── question-narrowing/
├── threat-intelligence/
└── synthesis/
```

**View intermediate steps:**

```bash
# See what each agent produced
cat .cache/question-narrowing/output.md
```

### Verbose Mode

```bash
# Enable verbose output
VERBOSE=1 ./workflows/full-analysis.sh input.txt
```

---

## Use Cases

### 1. Security Research
```bash
# Input: Vague security question
# Output: Specific questions + research queries + threat analysis
cat "How secure is my router?" | question_narrowing.sh | threat_intelligence.sh
```

### 2. Meeting Transcription Analysis
```bash
# Input: Raw meeting transcript
# Output: Organized topics + action items + follow-ups
./workflows/create-knowledge-base.sh meeting-transcript.txt
```

### 3. Research Notes Organization
```bash
# Input: Messy research notes
# Output: Organized dimensions + insights + recommendations
cat research-notes.md | wisdom_synthesis.sh
```

### 4. Configuration Validation
```bash
# Input: Config file
# Output: Security findings + risk analysis + remediation steps
config_validator.sh /etc/config/wireless
```

---

## Current Limitations

### 1. Hardcoded Workflows
**Problem**: `full-analysis.sh` runs all agents regardless of content

**Solution**: Build Intelligent Router (see DEVELOPMENT-SPEC.md)

### 2. No Dynamic Pattern Selection
**Problem**: Can't automatically select from fabric's pattern library

**Solution**: Integrate pattern discovery in router

### 3. No Agent Creator
**Problem**: Creating new agents is manual

**Solution**: Build agent-creator agent (future)

---

## Project Structure

```
fabric-graph-agents/
├── README.md                    # This file
├── DEVELOPMENT-SPEC.md          # What needs to be built
├── MIGRATION-NOTES.md           # Migration history
├── MODEL-SELECTION.md           # Model selection guide
│
├── agents/                      # Agent wrapper scripts
│   ├── question_narrowing.sh
│   ├── threat_intelligence.sh
│   ├── config_validator.sh
│   └── wisdom_synthesis.sh
│
├── lib/                         # Core libraries
│   ├── dimensional.sh
│   ├── graph.sh
│   ├── quality.sh
│   ├── fabric-wrapper.sh
│   └── utils/
│       ├── semantic.py
│       └── graph_planner.py
│
├── workflows/                   # Complete workflows
│   ├── full-analysis.sh
│   ├── create-knowledge-base.sh
│   └── adaptive-analysis.sh     # TO BE BUILT
│
└── docs/                        # Additional documentation
    ├── architecture.md
    ├── agent-creation.md
    └── examples/
```

---

## Dependencies

- **fabric** or **fabric-ai** - Core pattern engine
- **jq** - JSON processing
- **Python 3.8+** - For utility scripts
- **bash 4.0+** - For shell scripts

---

## Installation

```bash
# 1. Clone/copy to your scripts directory
cp -r fabric-graph-agents ~/MyScripts/

# 2. Add to PATH
echo 'export PATH="$PATH:$HOME/MyScripts/fabric-graph-agents/agents"' >> ~/.bashrc
source ~/.bashrc

# 3. Verify
question_narrowing.sh --help
```

---

## Contributing

### Adding New Agents
1. Create pattern in `../fabric-custom-patterns/`
2. Create wrapper in `agents/`
3. Test standalone
4. Document in README

### Improving Router
See `DEVELOPMENT-SPEC.md` for Intelligent Router requirements

### Reporting Issues
Include:
- Input that caused issue
- Expected vs actual output
- Agent/workflow used
- Fabric version

---

## Philosophy

**Fabric is the engine** - We build intelligent orchestration on top

**Agents are composable** - Pipe them, chain them, select them dynamically

**Configuration is simple** - Header variables, not complex CLI

**Everything is debuggable** - Cache all outputs, make workflows transparent

**Content-aware processing** - Don't force security analysis on random text

---

## License

[Your License Here]

---

## Credits

Built on [fabric](https://github.com/danielmiessler/fabric) by Daniel Miessler

---

**Status**: Core infrastructure complete, Intelligent Router in development

**Next**: See DEVELOPMENT-SPEC.md for roadmap
