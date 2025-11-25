# Architecture: Fabric Graph Agents

**Purpose**: Complete architectural specification for the Fabric Graph Agents system

---

## System Overview

Fabric Graph Agents is an **intelligent orchestration layer** built on top of fabric that transforms how we process unstructured content.

### Core Problem

**Traditional approach**:
```
Messy Input → Single Fabric Pattern → Hope for good output
```

**Problems**:
- Mixed topics get confused
- Single pattern can't handle multiple concerns
- No way to route different content types appropriately
- Wastes tokens on irrelevant processing

**Our approach**:
```
Messy Input → Dimensional Extraction → Intelligent Routing → Specialized Agents → Synthesis
```

**Benefits**:
- Each topic processed independently
- Content-aware agent selection
- Efficient token usage
- Composable workflows

---

## Architecture Layers

### Layer 1: Input Processing

**Component**: Dimensional Extractor

**Purpose**: Transform chaos into organized dimensions

**Input**: Any text (transcripts, notes, rambling, mixed topics)

**Process**:
1. Analyze semantic structure
2. Identify topic boundaries
3. Extract coherent dimensions
4. Add metadata (type, weight, keywords)

**Output**: N dimension files, each containing one coherent topic

**Technology**:
- Custom fabric pattern: `dimension_extractor_ultra`
- Library: `lib/dimensional.sh`
- Validation: `validate_extraction` pattern

**Example**:
```
Input: 10,000 words about routers, security, philosophy, hardware

Output:
├── hardware-specifications.md (technical, high weight)
├── security-concerns.md (security, high weight)
├── philosophical-thoughts.md (affective, low weight)
└── implementation-questions.md (cognitive, medium weight)
```

---

### Layer 2: Intelligence & Routing

**Component**: Intelligent Router (TO BE BUILT)

**Purpose**: Analyze dimensions and select appropriate processing

**Input**: Directory of dimension files with metadata

**Process**:
1. **Domain Classification**
   - Read all dimensions
   - Extract keywords
   - Analyze types (technical, affective, cognitive)
   - Classify content domain (security, research, technical, general, random)
   - Calculate confidence score

2. **Agent Selection**
   - Match domain to agent rules
   - Consider dimension types
   - Build execution plan
   - Include fallback options

3. **Execution Planning**
   - Determine agent order (sequential vs parallel)
   - Allocate resources
   - Set up session context

**Output**: Execution plan with selected agents

**Technology**:
- Python classifier: `lib/utils/domain_classifier.py` (TO BE BUILT)
- Python selector: `lib/utils/agent_selector.py` (TO BE BUILT)
- Orchestrator: `workflows/adaptive-analysis.sh` (TO BE BUILT)

**Example**:
```json
{
  "domain": "security",
  "confidence": 0.92,
  "agents": [
    "question_narrowing",
    "threat_intelligence",
    "config_validator"
  ],
  "execution_order": "sequential",
  "reasoning": "High security keyword density + technical dimensions"
}
```

---

### Layer 3: Agent Execution

**Component**: Specialized Agents

**Purpose**: Process dimensions with domain expertise

**Current Agents**:

#### question_narrowing
- **Purpose**: Refine vague questions into specific ones
- **Input**: Dimension with questions/uncertainties
- **Output**: Specific, answerable questions
- **Use case**: Research, learning, exploration

#### threat_intelligence
- **Purpose**: Generate security research queries
- **Input**: Security-related dimension
- **Output**: Structured research queries for threat intelligence
- **Use case**: Security analysis, threat research

#### config_validator
- **Purpose**: Validate configurations against best practices
- **Input**: Configuration files/settings
- **Output**: Security findings, risks, recommendations
- **Use case**: Security hardening, compliance

#### wisdom_synthesis
- **Purpose**: Extract insights and create action plans
- **Input**: Any dimension or analysis results
- **Output**: Key insights, action items, recommendations
- **Use case**: Final synthesis, decision support

**Agent Architecture**:
```
Agent = Custom Fabric Pattern + Wrapper Script

fabric-custom-patterns/
└── agent_name/
    └── system.md          # Pattern definition

agents/
└── agent_name.sh          # Wrapper with config
```

**Agent Interface**:
```bash
# Standard input/output
cat dimension.md | agent_name.sh > output.md

# With session context
agent_name.sh --session my-analysis dimension.md

# With custom model
MODEL="openai/gpt-4" agent_name.sh dimension.md
```

---

### Layer 4: Synthesis & Output

**Component**: Result Aggregator

**Purpose**: Combine agent outputs into coherent final report

**Process**:
1. Collect all agent outputs
2. Identify key themes
3. Remove redundancy
4. Create structured report
5. Generate action items

**Technology**:
- Agent: `wisdom_synthesis.sh`
- Library: `lib/quality.sh` (validation)

**Output Format**:
```markdown
# Analysis Report

## Executive Summary
[High-level overview]

## Key Findings
[Organized by dimension]

## Recommendations
[Actionable items]

## Next Steps
[Prioritized actions]

## Appendix
[Detailed analysis per dimension]
```

---

## Data Flow

### Complete Workflow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. INPUT                                                     │
│    - Raw text file                                          │
│    - Transcript                                             │
│    - Notes                                                  │
│    - Any unstructured content                               │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. DIMENSIONAL EXTRACTION                                    │
│    Pattern: dimension_extractor_ultra                       │
│    Library: lib/dimensional.sh                              │
│                                                             │
│    Process:                                                 │
│    - Analyze semantic structure                             │
│    - Identify topic boundaries                              │
│    - Extract dimensions                                     │
│    - Add metadata                                           │
│    - Validate quality                                       │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. DIMENSION FILES                                           │
│    dimensions/                                              │
│    ├── dimension-1.md (type: technical, weight: high)       │
│    ├── dimension-2.md (type: security, weight: high)        │
│    ├── dimension-3.md (type: cognitive, weight: medium)     │
│    └── metadata.json                                        │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. INTELLIGENT ROUTER (TO BE BUILT)                         │
│    Classifier: lib/utils/domain_classifier.py               │
│    Selector: lib/utils/agent_selector.py                    │
│                                                             │
│    Process:                                                 │
│    - Read dimensions + metadata                             │
│    - Extract keywords                                       │
│    - Classify domain                                        │
│    - Select agents                                          │
│    - Build execution plan                                   │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. EXECUTION PLAN                                            │
│    {                                                        │
│      "domain": "security",                                  │
│      "agents": ["question_narrowing", "threat_intel"],      │
│      "execution_order": "sequential"                        │
│    }                                                        │
└────────────────┬────────────────────────────────────────────┘
                 ↓
         ┌───────┴───────┐
         ↓               ↓
┌──────────────────┐ ┌──────────────────┐
│ 6a. AGENT 1      │ │ 6b. AGENT 2      │
│ question_        │ │ threat_          │
│ narrowing        │ │ intelligence     │
│                  │ │                  │
│ Input: dim 1-3   │ │ Input: dim 2     │
│ Output: refined  │ │ Output: queries  │
└────────┬─────────┘ └────────┬─────────┘
         │                    │
         └────────┬───────────┘
                  ↓
┌─────────────────────────────────────────────────────────────┐
│ 7. AGENT OUTPUTS                                             │
│    results/                                                 │
│    ├── question_narrowing.md                                │
│    ├── threat_intelligence.md                               │
│    └── config_validator.md                                  │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 8. SYNTHESIS                                                 │
│    Agent: wisdom_synthesis                                  │
│                                                             │
│    Process:                                                 │
│    - Aggregate results                                      │
│    - Identify themes                                        │
│    - Remove redundancy                                      │
│    - Create action plan                                     │
└────────────────┬────────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────────────────────┐
│ 9. FINAL REPORT                                              │
│    - Executive summary                                      │
│    - Key findings                                           │
│    - Recommendations                                        │
│    - Action items                                           │
│    - Detailed analysis                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Component Interactions

### Dimensional Extraction Flow

```
Input Text
    ↓
[dimensional.sh]
    ↓
fabric --pattern dimension_extractor_ultra
    ↓
Raw JSON output
    ↓
[dimensional.sh: parse_dimensions()]
    ↓
Individual .md files + metadata.json
    ↓
[quality.sh: validate_extraction()]
    ↓
Quality score (0-100)
    ↓
If score < 70: retry with improved prompt
If score >= 70: proceed
```

### Intelligent Routing Flow (Future)

```
Dimension Directory
    ↓
[domain_classifier.py]
    ↓
Read all .md files + metadata.json
    ↓
Extract keywords + analyze types
    ↓
Calculate domain scores
    ↓
Domain classification + confidence
    ↓
[agent_selector.py]
    ↓
Match domain to agent rules
    ↓
Filter by dimension count/types
    ↓
Build execution plan
    ↓
[adaptive-analysis.sh]
    ↓
Execute selected agents
    ↓
Collect results
    ↓
Synthesize final report
```

### Agent Execution Flow

```
Dimension File
    ↓
[agent_name.sh]
    ↓
Load configuration (MODEL, PATTERN, SESSION)
    ↓
[fabric-wrapper.sh]
    ↓
Detect fabric vs fabric-ai
    ↓
fabric --model $MODEL --pattern $PATTERN [--session $SESSION]
    ↓
Agent output
    ↓
[quality.sh: validate_output()] (optional)
    ↓
Validated output
```

---

## Technology Stack

### Core Technologies

**Fabric**:
- Pattern engine
- Model abstraction
- Session management
- Primary processing engine

**Bash**:
- Orchestration scripts
- Agent wrappers
- Library functions
- Workflow automation

**Python**:
- Semantic analysis
- Domain classification
- Agent selection
- Graph planning

**JSON**:
- Metadata format
- Configuration files
- Execution plans
- Intermediate data

### External Dependencies

**Required**:
- `fabric` or `fabric-ai` - Pattern engine
- `jq` - JSON processing
- `python3` - Utility scripts
- `bash 4.0+` - Shell scripts

**Optional**:
- `graphviz` - Graph visualization
- `mermaid-cli` - Diagram generation

---

## File System Structure

```
fabric-graph-agents/
│
├── README.md                    # User documentation
├── DEVELOPMENT-SPEC.md          # Development roadmap
├── MIGRATION-NOTES.md           # Migration history
├── MIGRATE.sh                   # Migration script
│
├── docs/                        # Detailed specifications
│   ├── ARCHITECTURE.md          # This file
│   ├── INTELLIGENT-ROUTER-SPEC.md
│   ├── AGENT-CREATOR-SPEC.md
│   └── SESSION-MANAGEMENT-SPEC.md
│
├── fabric-custom-patterns/      # Custom fabric patterns
│   ├── dimension_extractor_ultra/
│   │   └── system.md
│   ├── validate_extraction/
│   │   └── system.md
│   └── plan_pattern_graph/
│       └── system.md
│
├── agents/                      # Agent wrapper scripts
│   ├── question_narrowing.sh
│   ├── threat_intelligence.sh
│   ├── config_validator.sh
│   └── wisdom_synthesis.sh
│
├── lib/                         # Core libraries
│   ├── dimensional.sh           # Dimension extraction
│   ├── graph.sh                 # Graph execution
│   ├── quality.sh               # Quality validation
│   ├── context_selector.sh      # Context selection
│   ├── pattern_planner.sh       # Pattern planning
│   ├── visualize_graph.sh       # Graph visualization
│   ├── graph_to_mermaid.py      # Mermaid generation
│   └── utils/                   # Python utilities
│       ├── semantic.py          # Semantic analysis
│       ├── graph_planner.py     # Graph planning
│       ├── domain_classifier.py # TO BE BUILT
│       └── agent_selector.py    # TO BE BUILT
│
├── workflows/                   # Complete workflows
│   ├── create-knowledge-base.sh # Simple extraction
│   ├── full-analysis.sh         # Hardcoded workflow
│   └── adaptive-analysis.sh     # TO BE BUILT
│
└── .cache/                      # Debug outputs
    ├── dimensions/
    ├── agent-outputs/
    └── execution-logs/
```

---

## Design Principles

### 1. Separation of Concerns

**Content ≠ Infrastructure**

- Generated content stays in project directories
- Reusable infrastructure lives in `MyScripts/`
- No hardcoded paths to specific projects

### 2. Composability

**Agents are building blocks**

```bash
# Use standalone
cat input.txt | question_narrowing.sh

# Chain together
cat input.txt | question_narrowing.sh | threat_intelligence.sh

# Orchestrate with workflow
adaptive-analysis.sh input.txt
```

### 3. Configuration Over Code

**Model selection via config, not CLI**

```bash
# Bad: Verbose CLI flags everywhere
fabric --model openai/gpt-4 --pattern my-pattern --session my-session

# Good: Simple config in agent script
MODEL="openai/gpt-4"
PATTERN="my-pattern"
SESSION="my-session"
```

### 4. Debuggability

**Everything is visible**

- All intermediate outputs cached
- Verbose mode available
- Clear execution logs
- Graph visualization

### 5. Intelligence Over Hardcoding

**Content-aware processing**

```bash
# Bad: Always run all agents
for agent in *; do $agent input.txt; done

# Good: Analyze content, select relevant agents
domain=$(classify_domain dimensions/)
agents=$(select_agents $domain)
for agent in $agents; do $agent dimensions/; done
```

### 6. Graceful Degradation

**Always have fallback**

- If classification fails → use general processing
- If no specific agent → use fabric pattern library
- If agent fails → continue with others
- If quality low → retry with improved prompt

---

## Security Considerations

### Input Validation

- Sanitize file paths
- Validate JSON structure
- Check file permissions
- Limit file sizes

### Output Handling

- Prevent path traversal
- Validate output directories
- Set appropriate permissions
- Clean up sensitive data

### Model Access

- Use environment variables for API keys
- Don't log API keys
- Respect rate limits
- Handle API errors gracefully

---

## Performance Characteristics

### Dimensional Extraction

**Time**: 5-15 seconds for typical input (1000-5000 words)

**Factors**:
- Input length
- Model speed
- Number of dimensions
- Validation passes

**Optimization**:
- Cache results
- Skip validation for trusted inputs
- Use faster models for simple content

### Agent Execution

**Time**: 10-30 seconds per agent

**Factors**:
- Dimension complexity
- Model speed
- Agent complexity

**Optimization**:
- Parallel execution when possible
- Session reuse for context
- Skip irrelevant agents (intelligent routing)

### Complete Workflow

**Current (Hardcoded)**: 2-5 minutes

**Future (Intelligent)**: 1-3 minutes (30-50% faster)

**Improvement**: Only run relevant agents

---

## Scalability

### Horizontal Scaling

**Parallel Agent Execution**:
```bash
# Execute independent agents in parallel
question_narrowing.sh dim1.md &
threat_intelligence.sh dim2.md &
config_validator.sh dim3.md &
wait
```

**Batch Processing**:
```bash
# Process multiple inputs
for file in inputs/*.txt; do
    adaptive-analysis.sh "$file" &
done
wait
```

### Vertical Scaling

**Resource Management**:
- Limit concurrent fabric calls
- Cache intermediate results
- Stream large files
- Clean up old cache

---

## Error Handling

### Levels

**1. Recoverable Errors**:
- Retry with backoff
- Use fallback options
- Continue with degraded functionality

**2. Non-Recoverable Errors**:
- Log error details
- Clean up partial results
- Exit gracefully
- Provide clear error message

### Examples

```bash
# Dimensional extraction fails
if ! extract_dimensions "$input"; then
    echo "ERROR: Failed to extract dimensions"
    echo "Trying with simpler prompt..."
    extract_dimensions_simple "$input" || exit 1
fi

# Agent execution fails
if ! run_agent "$agent" "$dimension"; then
    echo "WARNING: Agent $agent failed, continuing..."
    continue
fi

# Classification fails
domain=$(classify_domain "$dimensions") || {
    echo "WARNING: Classification failed, using general processing"
    domain="general"
}
```

---

## Testing Strategy

### Unit Tests

**Dimensional Extraction**:
- Test with various input types
- Validate output structure
- Check metadata accuracy
- Verify quality scores

**Domain Classification**:
- Test with known domains
- Validate confidence scores
- Check edge cases
- Verify fallback behavior

**Agent Selection**:
- Test rule matching
- Validate execution plans
- Check agent ordering
- Verify fallback options

### Integration Tests

**End-to-End Workflows**:
- Security content → security agents
- Research content → research agents
- Random content → minimal processing
- Mixed content → appropriate routing

### Performance Tests

**Benchmarks**:
- Extraction time vs input size
- Agent execution time
- Complete workflow time
- Memory usage

---

## Future Enhancements

### Phase 1: Intelligent Router
- Domain classification
- Agent selection
- Adaptive workflows

### Phase 2: Dynamic Pattern Selection
- Pattern discovery
- Pattern matching
- Automatic pattern selection

### Phase 3: Agent Creator
- Automatic agent generation
- Uniqueness validation
- Pattern creation
- Testing automation

### Phase 4: Advanced Features
- Multi-language support
- Custom domain definitions
- Learning from feedback
- Performance optimization

---

## Conclusion

Fabric Graph Agents transforms fabric from a single-pattern tool into an intelligent orchestration system that:

1. **Organizes chaos** - Dimensional extraction
2. **Routes intelligently** - Content-aware agent selection
3. **Processes efficiently** - Only relevant agents run
4. **Synthesizes coherently** - Unified final output

**Current Status**: Core infrastructure complete, intelligent routing in development

**Next Steps**: Implement domain classifier and agent selector

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-26  
**Status**: Complete specification, ready for implementation
