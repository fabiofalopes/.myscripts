# Session Management Specification

**Purpose**: Specification for fabric session management and context handling

**Status**: ENHANCEMENT (Fabric already supports sessions, we need better integration)

**Priority**: MEDIUM (after Intelligent Router)

---

## Overview

Fabric already provides session management capabilities. This specification defines how to **leverage and enhance** fabric's sessions for multi-agent workflows.

### Current Fabric Session Support

```bash
# Create/resume session
fabric --session my-analysis --pattern dimension_extractor_ultra < input.txt

# Continue in same session (maintains context)
fabric --session my-analysis --pattern question_narrowing

# Session persists across calls
fabric --session my-analysis --pattern threat_intelligence
```

### What We Need

1. **Session Orchestration**: Manage sessions across multiple agents
2. **Context Passing**: Share relevant context between agents
3. **Session Lifecycle**: Create, use, clean up sessions
4. **Cache Management**: Store intermediate results
5. **Session Visualization**: Show what's in a session

---

## Architecture

### Components

```
Session Manager
├── Session Creator       # Initialize sessions
├── Context Selector      # Choose relevant context
├── Session Executor      # Run agents with sessions
├── Cache Manager         # Store intermediate results
└── Session Cleaner       # Clean up old sessions
```

### Session Lifecycle

```
1. CREATE
   ↓
2. POPULATE (add initial context)
   ↓
3. EXECUTE (run agents with session)
   ↓
4. CACHE (store intermediate results)
   ↓
5. CLEANUP (remove when done)
```

---

## Component 1: Session Creator

### Purpose

Initialize fabric sessions for workflows.

### Input

**Workflow Specification**:
```json
{
  "workflow_id": "analysis-20251026-123456",
  "input_file": "input.txt",
  "agents": ["question_narrowing", "threat_intelligence"]
}
```

### Process

```bash
create_session() {
    local workflow_id="$1"
    local input_file="$2"
    
    # Generate session name
    local session_name="fga-${workflow_id}"
    
    # Initialize session with input
    fabric --session "$session_name" \
           --pattern dimension_extractor_ultra \
           < "$input_file" > /dev/null
    
    echo "$session_name"
}
```

### Output

```
Session created: fga-analysis-20251026-123456
```

---

## Component 2: Context Selector

### Purpose

Select relevant context to include in agent calls.

### Problem

**Too much context**:
- Wastes tokens
- Slows processing
- May confuse agent

**Too little context**:
- Agent lacks necessary information
- Inconsistent results
- Loses coherence

### Solution

**Intelligent context selection** based on:
- Agent type
- Dimension relevance
- Previous agent outputs

### Input

**Session State**:
```json
{
  "session_name": "fga-analysis-123",
  "dimensions": [
    {"id": "dim1", "type": "technical", "keywords": ["hardware"]},
    {"id": "dim2", "type": "security", "keywords": ["threat"]}
  ],
  "previous_outputs": {
    "question_narrowing": "..."
  }
}
```

**Current Agent**:
```json
{
  "agent": "threat_intelligence",
  "domain": "security"
}
```

### Process

```python
def select_context(
    session_state: Dict,
    current_agent: Dict
) -> Dict:
    """
    Select relevant context for agent.
    
    Returns:
    {
        "dimensions": ["dim2"],  # Only security dimension
        "previous_outputs": ["question_narrowing"],
        "reasoning": "..."
    }
    """
    agent_name = current_agent["agent"]
    agent_domain = current_agent["domain"]
    
    # Select relevant dimensions
    relevant_dimensions = []
    for dim in session_state["dimensions"]:
        # Match by type
        if dim["type"] == agent_domain:
            relevant_dimensions.append(dim["id"])
        # Match by keywords
        elif any(kw in dim["keywords"] for kw in AGENT_KEYWORDS[agent_name]):
            relevant_dimensions.append(dim["id"])
    
    # Select relevant previous outputs
    relevant_outputs = []
    agent_dependencies = AGENT_DEPENDENCIES.get(agent_name, [])
    for dep in agent_dependencies:
        if dep in session_state["previous_outputs"]:
            relevant_outputs.append(dep)
    
    return {
        "dimensions": relevant_dimensions,
        "previous_outputs": relevant_outputs,
        "reasoning": f"Selected {len(relevant_dimensions)} dimensions and {len(relevant_outputs)} previous outputs for {agent_name}"
    }
```

**Agent Dependencies**:
```python
AGENT_DEPENDENCIES = {
    "threat_intelligence": ["question_narrowing"],  # Needs refined questions
    "wisdom_synthesis": ["*"],  # Needs all previous outputs
    "config_validator": [],  # Standalone
}
```

### Output

```json
{
  "dimensions": ["dim2"],
  "previous_outputs": ["question_narrowing"],
  "reasoning": "Selected 1 dimensions and 1 previous outputs for threat_intelligence"
}
```

---

## Component 3: Session Executor

### Purpose

Execute agents with appropriate session context.

### Input

**Agent Specification**:
```json
{
  "agent": "threat_intelligence",
  "session": "fga-analysis-123",
  "context": {
    "dimensions": ["dim2"],
    "previous_outputs": ["question_narrowing"]
  }
}
```

### Process

#### Strategy 1: Full Session Context (Simple)

```bash
execute_with_session() {
    local agent="$1"
    local session="$2"
    local dimension_file="$3"
    
    # Agent automatically gets full session context
    fabric --session "$session" \
           --pattern "$agent" \
           < "$dimension_file"
}
```

**Pros**: Simple, automatic context
**Cons**: May include irrelevant context

#### Strategy 2: Selective Context (Advanced)

```bash
execute_with_selective_context() {
    local agent="$1"
    local session="$2"
    local context_spec="$3"
    local dimension_file="$4"
    
    # Build context prompt
    local context_prompt=$(build_context_prompt "$context_spec")
    
    # Combine context + dimension
    {
        echo "# Context"
        echo "$context_prompt"
        echo
        echo "# Current Input"
        cat "$dimension_file"
    } | fabric --session "$session" --pattern "$agent"
}
```

```python
def build_context_prompt(context_spec: Dict) -> str:
    """
    Build context prompt from specification.
    
    Returns:
    '''
    ## Previous Analysis
    
    ### Question Narrowing Results
    [content]
    
    ## Relevant Dimensions
    
    ### Security Concerns
    [content]
    '''
    """
    prompt = "## Previous Analysis\n\n"
    
    # Add previous outputs
    for output_name in context_spec["previous_outputs"]:
        content = load_output(output_name)
        prompt += f"### {output_name.replace('_', ' ').title()}\n"
        prompt += f"{content}\n\n"
    
    # Add relevant dimensions
    if context_spec["dimensions"]:
        prompt += "## Relevant Dimensions\n\n"
        for dim_id in context_spec["dimensions"]:
            dim = load_dimension(dim_id)
            prompt += f"### {dim['title']}\n"
            prompt += f"{dim['content']}\n\n"
    
    return prompt
```

**Pros**: Precise context control
**Cons**: More complex, requires context building

#### Strategy 3: Hybrid (Recommended)

```bash
execute_agent() {
    local agent="$1"
    local session="$2"
    local dimension_file="$3"
    local use_selective_context="${4:-false}"
    
    if [ "$use_selective_context" = "true" ]; then
        # Use selective context for complex workflows
        context_spec=$(select_context "$session" "$agent")
        execute_with_selective_context "$agent" "$session" "$context_spec" "$dimension_file"
    else
        # Use full session for simple workflows
        execute_with_session "$agent" "$session" "$dimension_file"
    fi
}
```

### Output

Agent output with appropriate context.

---

## Component 4: Cache Manager

### Purpose

Store intermediate results for debugging and reuse.

### Structure

```
.cache/
└── sessions/
    └── fga-analysis-123/
        ├── session-info.json
        ├── dimensions/
        │   ├── dim1.md
        │   └── dim2.md
        ├── agent-outputs/
        │   ├── question_narrowing.md
        │   ├── threat_intelligence.md
        │   └── wisdom_synthesis.md
        └── logs/
            ├── execution.log
            └── context-selections.json
```

### Operations

#### Save Session Info

```bash
save_session_info() {
    local session="$1"
    local workflow_spec="$2"
    
    local cache_dir=".cache/sessions/$session"
    mkdir -p "$cache_dir"
    
    cat > "$cache_dir/session-info.json" << EOF
{
    "session_name": "$session",
    "created": "$(date -Iseconds)",
    "workflow": $workflow_spec
}
EOF
}
```

#### Cache Agent Output

```bash
cache_agent_output() {
    local session="$1"
    local agent="$2"
    local output="$3"
    
    local cache_dir=".cache/sessions/$session/agent-outputs"
    mkdir -p "$cache_dir"
    
    echo "$output" > "$cache_dir/$agent.md"
    
    # Log execution
    echo "[$(date -Iseconds)] $agent completed" >> \
        ".cache/sessions/$session/logs/execution.log"
}
```

#### Load Cached Output

```bash
load_cached_output() {
    local session="$1"
    local agent="$2"
    
    local cache_file=".cache/sessions/$session/agent-outputs/$agent.md"
    
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    else
        return 1
    fi
}
```

#### Cache Context Selections

```bash
cache_context_selection() {
    local session="$1"
    local agent="$2"
    local context_spec="$3"
    
    local cache_file=".cache/sessions/$session/logs/context-selections.json"
    
    # Append to context selections log
    jq --arg agent "$agent" \
       --argjson spec "$context_spec" \
       '. += [{agent: $agent, context: $spec, timestamp: now}]' \
       "$cache_file" > "$cache_file.tmp"
    
    mv "$cache_file.tmp" "$cache_file"
}
```

---

## Component 5: Session Cleaner

### Purpose

Clean up old sessions and cache.

### Operations

#### List Sessions

```bash
list_sessions() {
    local cache_dir=".cache/sessions"
    
    for session_dir in "$cache_dir"/*; do
        if [ -d "$session_dir" ]; then
            local session=$(basename "$session_dir")
            local created=$(jq -r '.created' "$session_dir/session-info.json")
            local age=$(( ($(date +%s) - $(date -d "$created" +%s)) / 86400 ))
            
            echo "$session (created: $created, age: ${age}d)"
        fi
    done
}
```

#### Clean Old Sessions

```bash
clean_old_sessions() {
    local max_age_days="${1:-7}"
    local cache_dir=".cache/sessions"
    
    echo "Cleaning sessions older than $max_age_days days..."
    
    for session_dir in "$cache_dir"/*; do
        if [ -d "$session_dir" ]; then
            local created=$(jq -r '.created' "$session_dir/session-info.json")
            local age=$(( ($(date +%s) - $(date -d "$created" +%s)) / 86400 ))
            
            if [ "$age" -gt "$max_age_days" ]; then
                local session=$(basename "$session_dir")
                echo "Removing: $session (${age}d old)"
                rm -rf "$session_dir"
                
                # Also clean fabric session
                fabric --session "$session" --clear 2>/dev/null || true
            fi
        fi
    done
}
```

#### Clean Specific Session

```bash
clean_session() {
    local session="$1"
    
    # Remove cache
    rm -rf ".cache/sessions/$session"
    
    # Clear fabric session
    fabric --session "$session" --clear
    
    echo "Session cleaned: $session"
}
```

---

## Integration with Workflows

### Workflow with Sessions

```bash
#!/bin/bash
#
# Adaptive Analysis with Session Management
#

INPUT_FILE="$1"
OUTPUT_DIR="${2:-./analysis-output}"

# Generate workflow ID
WORKFLOW_ID="analysis-$(date +%Y%m%d-%H%M%S)"
SESSION_NAME="fga-$WORKFLOW_ID"

echo "=== Fabric Graph Agents: Adaptive Analysis ==="
echo "Workflow ID: $WORKFLOW_ID"
echo "Session: $SESSION_NAME"
echo

# Create session
echo "[1/6] Creating session..."
create_session "$SESSION_NAME" "$INPUT_FILE"
save_session_info "$SESSION_NAME" "{\"input\": \"$INPUT_FILE\"}"

# Extract dimensions
echo "[2/6] Extracting dimensions..."
DIMENSIONS=$(extract_dimensions_with_session "$SESSION_NAME" "$INPUT_FILE")
cache_dimensions "$SESSION_NAME" "$DIMENSIONS"

# Classify domain
echo "[3/6] Classifying domain..."
CLASSIFICATION=$(classify_domain "$DIMENSIONS")

# Select agents
echo "[4/6] Selecting agents..."
AGENTS=$(select_agents "$CLASSIFICATION" "$DIMENSIONS")

# Execute agents with session
echo "[5/6] Executing agents..."
for agent in $(echo "$AGENTS" | jq -r '.agents[]'); do
    echo "  Running: $agent"
    
    # Select context for this agent
    CONTEXT=$(select_context "$SESSION_NAME" "$agent")
    cache_context_selection "$SESSION_NAME" "$agent" "$CONTEXT"
    
    # Execute with session
    OUTPUT=$(execute_agent "$agent" "$SESSION_NAME" "$DIMENSIONS" true)
    
    # Cache output
    cache_agent_output "$SESSION_NAME" "$agent" "$OUTPUT"
    
    # Save to output directory
    echo "$OUTPUT" > "$OUTPUT_DIR/results/$agent.md"
done

# Synthesize
echo "[6/6] Synthesizing results..."
FINAL_REPORT=$(execute_agent "wisdom_synthesis" "$SESSION_NAME" "$OUTPUT_DIR/results" true)
echo "$FINAL_REPORT" > "$OUTPUT_DIR/FINAL-REPORT.md"

echo
echo "=== Analysis Complete ==="
echo "Session: $SESSION_NAME"
echo "Cache: .cache/sessions/$SESSION_NAME"
echo "Report: $OUTPUT_DIR/FINAL-REPORT.md"
echo
echo "To clean session: clean_session $SESSION_NAME"
```

---

## Session Visualization

### View Session Contents

```bash
view_session() {
    local session="$1"
    
    echo "=== Session: $session ==="
    echo
    
    # Session info
    echo "## Info"
    jq '.' ".cache/sessions/$session/session-info.json"
    echo
    
    # Dimensions
    echo "## Dimensions"
    ls -1 ".cache/sessions/$session/dimensions/" | while read dim; do
        echo "- $dim"
    done
    echo
    
    # Agent outputs
    echo "## Agent Outputs"
    ls -1 ".cache/sessions/$session/agent-outputs/" | while read output; do
        echo "- $output"
    done
    echo
    
    # Execution log
    echo "## Execution Log"
    cat ".cache/sessions/$session/logs/execution.log"
}
```

### Session Statistics

```bash
session_stats() {
    local session="$1"
    
    local num_dimensions=$(ls -1 ".cache/sessions/$session/dimensions/" | wc -l)
    local num_outputs=$(ls -1 ".cache/sessions/$session/agent-outputs/" | wc -l)
    local cache_size=$(du -sh ".cache/sessions/$session" | cut -f1)
    
    cat << EOF
Session Statistics: $session
- Dimensions: $num_dimensions
- Agent outputs: $num_outputs
- Cache size: $cache_size
EOF
}
```

---

## Best Practices

### 1. Session Naming

```bash
# Good: Descriptive, timestamped
SESSION="fga-security-analysis-20251026-123456"

# Bad: Generic
SESSION="session1"
```

### 2. Context Selection

```bash
# Good: Select relevant context
context=$(select_context "$session" "$agent")

# Bad: Always use full context
# (wastes tokens)
```

### 3. Cache Management

```bash
# Good: Regular cleanup
clean_old_sessions 7  # Clean sessions older than 7 days

# Bad: Never clean
# (fills disk)
```

### 4. Error Handling

```bash
# Good: Handle session errors
if ! create_session "$session" "$input"; then
    echo "ERROR: Failed to create session"
    exit 1
fi

# Bad: Assume success
create_session "$session" "$input"
```

---

## Performance Considerations

### Session Overhead

**Creating session**: ~1-2 seconds  
**Context selection**: ~0.1 seconds  
**Cache operations**: ~0.1 seconds  
**Total overhead**: ~1-2 seconds per workflow

**Worth it?** Yes, for multi-agent workflows (better coherence)

### Token Usage

**Without sessions**: Each agent gets full input  
**With sessions**: Agents share context, less repetition  
**Savings**: 20-40% token reduction in multi-agent workflows

### Cache Size

**Typical session**: 100KB - 1MB  
**With 100 sessions**: 10MB - 100MB  
**Recommendation**: Clean sessions older than 7 days

---

## Testing

### Test Session Creation

```bash
test_session_creation() {
    local test_input="Test input for session"
    local session="test-session-$$"
    
    # Create session
    create_session "$session" <(echo "$test_input")
    
    # Verify session exists
    if fabric --session "$session" --pattern extract_wisdom < /dev/null; then
        echo "PASS: Session created"
        clean_session "$session"
        return 0
    else
        echo "FAIL: Session not created"
        return 1
    fi
}
```

### Test Context Selection

```bash
test_context_selection() {
    # Setup test data
    local session_state='{
        "dimensions": [
            {"id": "dim1", "type": "security"},
            {"id": "dim2", "type": "technical"}
        ]
    }'
    local agent='{"agent": "threat_intelligence", "domain": "security"}'
    
    # Select context
    local context=$(python3 -c "
from lib.utils.context_selector import select_context
import json
print(json.dumps(select_context(
    json.loads('$session_state'),
    json.loads('$agent')
)))
")
    
    # Verify security dimension selected
    if echo "$context" | jq -e '.dimensions | contains(["dim1"])' > /dev/null; then
        echo "PASS: Correct context selected"
        return 0
    else
        echo "FAIL: Wrong context selected"
        return 1
    fi
}
```

---

## Future Enhancements

### 1. Session Sharing

```bash
# Share session between users/machines
export_session "$session" > session.tar.gz
import_session session.tar.gz
```

### 2. Session Branching

```bash
# Create branch from existing session
branch_session "$original_session" "$new_session"
```

### 3. Session Merging

```bash
# Merge multiple sessions
merge_sessions "$session1" "$session2" "$merged_session"
```

### 4. Session Replay

```bash
# Replay session execution
replay_session "$session"
```

---

## Implementation Checklist

- [ ] Create session creator
- [ ] Create context selector
- [ ] Create session executor
- [ ] Create cache manager
- [ ] Create session cleaner
- [ ] Integrate with workflows
- [ ] Add session visualization
- [ ] Write tests
- [ ] Document usage
- [ ] Add examples

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-26  
**Status**: Complete specification, ready for implementation  
**Priority**: MEDIUM (after Intelligent Router)
