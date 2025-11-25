# Model Selection Guide

All fabric-graph-agents workflows and agents support custom model selection via the `FABRIC_MODEL` environment variable.

## Quick Start

### Default Model
```bash
# Uses fabric's default model
create-knowledge-base.sh input.txt
```

### Specify Model
```bash
# Use GPT-4o
FABRIC_MODEL=openai/gpt-4o create-knowledge-base.sh input.txt

# Use Claude 3.5 Sonnet
FABRIC_MODEL=anthropic/claude-3.5-sonnet create-knowledge-base.sh input.txt

# Use O1 Preview
FABRIC_MODEL=openai/o1-preview create-knowledge-base.sh input.txt
```

### Set for Session
```bash
# Set once, use multiple times
export FABRIC_MODEL=openai/gpt-4o

create-knowledge-base.sh input1.txt
create-knowledge-base.sh input2.txt
question_narrowing.sh "How secure am I?"
```

## Supported Workflows

### create-knowledge-base.sh
```bash
FABRIC_MODEL=openai/gpt-4o create-knowledge-base.sh my-notes.txt
```

### Agents
All agents support model selection:

```bash
# Question Narrowing
FABRIC_MODEL=openai/gpt-4o question_narrowing.sh "vague question"

# Threat Intelligence
FABRIC_MODEL=anthropic/claude-3.5-sonnet threat_intelligence.sh "security topic"

# Config Validator
FABRIC_MODEL=openai/gpt-4o config_validator.sh config-file.txt

# Wisdom Synthesis
FABRIC_MODEL=openai/gpt-4o wisdom_synthesis.sh notes.txt
```

## Common Models

### OpenAI
- `openai/gpt-4o` - Latest GPT-4 Optimized
- `openai/gpt-4-turbo` - GPT-4 Turbo
- `openai/gpt-4` - GPT-4
- `openai/gpt-3.5-turbo` - GPT-3.5 Turbo
- `openai/o1-preview` - O1 Preview (reasoning model)
- `openai/o1-mini` - O1 Mini

### Anthropic
- `anthropic/claude-3.5-sonnet` - Claude 3.5 Sonnet (recommended)
- `anthropic/claude-3-opus` - Claude 3 Opus
- `anthropic/claude-3-sonnet` - Claude 3 Sonnet
- `anthropic/claude-3-haiku` - Claude 3 Haiku

### Google
- `google/gemini-pro` - Gemini Pro
- `google/gemini-1.5-pro` - Gemini 1.5 Pro

### Local Models (via Ollama)
- `ollama/llama3` - Llama 3
- `ollama/mistral` - Mistral
- `ollama/codellama` - Code Llama

## Tips

### Cost Optimization
```bash
# Use cheaper models for simple tasks
FABRIC_MODEL=openai/gpt-3.5-turbo create-knowledge-base.sh simple-notes.txt

# Use powerful models for complex analysis
FABRIC_MODEL=openai/o1-preview create-knowledge-base.sh complex-research.txt
```

### Quality vs Speed
```bash
# Fast but good quality
FABRIC_MODEL=anthropic/claude-3-haiku create-knowledge-base.sh input.txt

# Best quality, slower
FABRIC_MODEL=anthropic/claude-3.5-sonnet create-knowledge-base.sh input.txt
```

### Local Development
```bash
# Use local models for privacy/offline work
FABRIC_MODEL=ollama/llama3 create-knowledge-base.sh sensitive-data.txt
```

## Troubleshooting

### Model Not Found
```bash
# Check available models
fabric --listmodels

# Or check fabric configuration
cat ~/.config/fabric/.env
```

### Authentication Issues
```bash
# Verify API keys are set
echo $OPENAI_API_KEY
echo $ANTHROPIC_API_KEY

# Or check fabric's config
fabric --setup
```

### Model Not Responding
```bash
# Test model directly
echo "test" | fabric --model openai/gpt-4o --pattern extract_wisdom

# Check fabric logs
fabric --debug
```

## Implementation Details

All workflows use the `fabric_call()` function from `lib/fabric-wrapper.sh`:

```bash
# Automatically adds --model flag if FABRIC_MODEL is set
fabric_call -p pattern_name < input.txt
```

This ensures consistent model selection across all components.
