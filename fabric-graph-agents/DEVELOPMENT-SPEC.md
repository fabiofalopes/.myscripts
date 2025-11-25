# Development Specification: Fabric Graph Agents

**Purpose**: Define what exists, what needs to be built, and how to build it.

---

## Current State

### ✅ What Works

#### 1. Dimensional Extraction
**Status**: Production-ready

**What it does**:
- Takes any text input (messy, unstructured, multi-topic)
- Extracts semantic dimensions (coherent topic clusters)
- Outputs organized markdown files with metadata

**Components**:
- Pattern: `dimension_extractor_ultra`
- Library: `lib/dimensional.sh`
- Workflow: `workflows/create-knowledge-base.sh`

**Quality**: Consistently produces 85+ quality scores

**Example**:
```bash
Input: 10,000 words of rambling about routers, security, hardware
Output: 9 organized dimension files (hardware, security, config, etc.)
```

#### 2. Domain-Specific Agents
**Status**: Working but isolated

**Agents**:
- `question_narrowing.sh` - Refines vague questions
- `threat_intelligence.sh` - Generates research queries
- `config_validator.sh` - Validates configurations
- `wisdom_synthesis.sh` - Extracts insights

**Each agent**:
- Has custom fabric pattern
- Has wrapper script
- Works standalone
- Can be piped

**Limitation**: No intelligence about WHEN to use each agent

#### 3. Hardcoded Workflow
**Status**: Works but inflexible

**File**: `workflows/full-analysis.sh`

**What it does**:
- Extracts dimensions
- Runs ALL agents on ALL content
- Synthesizes results

**Problem**: Runs security analysis on random text, threat intel on non-technical content

#### 4. Core Libraries
**Status**: Production-ready

**Libraries**:
- `dimensional.sh` - Dimension management
- `graph.sh` - Graph execution
- `quality.sh` - Quality validation
- `fabric-wrapper.sh` - Fabric aliasing
- `semantic.py` - Text analysis
- `graph_planner.py` - Graph planning

**All tested and working**

---

## ❌ What's Missing

### 1. Intelligent Router (CRITICAL)

**Problem**: System doesn't know WHAT to run based on WHAT was extracted

**Current**:
```
Dimensions → [Always runs all 4 agents] → Output
```

**Needed**:
```
Dimensions → [Analyzes content] → [Selects relevant agents] → Output
```

**Requirements**:

#### A. Domain Classifier
**Input**: Dimension files with metadata

**Process**:
- Read all dimension files
- Analyze keywords (security, hardware, code, philosophy, etc.)
- Analyze types (technical, affective, cognitive)
- Classify content domain

**Output**: Domain classification + confidence

**Domains**:
- `security` - Security/threat content
- `technical` - Hardware/software/config
- `research` - Learning/exploration
- `development` - Code/programming
- `general` - Philosophy/insights
- `random` - Unstructured/unclear

**Implementation**:
```python
# lib/utils/domain_classifier.py

def classify_domain(dimensions: List[Dict]) -> Dict:
    """
    Analyzes dimensions and classifies content domain.
    
    Returns:
    {
        "domain": "security",
        "confidence": 0.92,
        "indicators": ["security keywords", "technical type"],
        "dimensions_by_type": {
            "technical": 5,
            "security": 3,
            "cognitive": 1
        }
    }
    """
```

#### B. Agent Selector
**Input**: Domain classification + dimension metadata

**Process**:
- Match domain to agent rules
- Select appropriate agents
- Build execution plan
- Include fallback for unmatched content

**Output**: List of agents to run + execution order

**Rules**:
```python
AGENT_RULES = {
    "security": [
        "question_narrowing",
        "threat_intelligence",
        "config_validator",
        "wisdom_synthesis"
    ],
    "research": [
        "question_narrowing",
        "search_query_generator",
        "wisdom_synthesis"
    ],
    "development": [
        "code_analyzer",
        "extract_patterns",
        "improve_code"
    ],
    "general": [
        "extract_wisdom",
        "extract_insights",
        "improve_prompt"
    ],
    "random": [
        "extract_wisdom"  # Minimal processing
    ]
}
```

**Implementation**:
```python
# lib/utils/agent_selector.py

def select_agents(domain: str, dimensions: List[Dict]) -> Dict:
    """
    Selects appropriate agents based on domain and content.
    
    Returns:
    {
        "agents": ["question_narrowing", "threat_intelligence"],
        "execution_order": "sequential",
        "fallback": ["extract_wisdom"],
        "reasoning": "Security domain detected with 5 technical dimensions"
    }
    """
```

#### C. Intelligent Router Script
**Input**: Dimension directory

**Process**:
1. Load dimensions
2. Classify domain
3. Select agents
4. Execute agents
5. Synthesize results

**Output**: Complete analysis with only relevant agents

**Implementation**:
```bash
# workflows/adaptive-analysis.sh

#!/bin/bash
# Intelligent routing workflow

INPUT="$1"
OUTPUT_DIR="$2"

# Stage 1: Extract dimensions
create-knowledge-base.sh "$INPUT" "$OUTPUT_DIR/dimensions"

# Stage 2: Classify domain
DOMAIN=$(python3 lib/utils/domain_classifier.py "$OUTPUT_DIR/dimensions")

# Stage 3: Select agents
AGENTS=$(python3 lib/utils/agent_selector.py "$DOMAIN" "$OUTPUT_DIR/dimensions")

# Stage 4: Execute selected agents
for agent in $AGENTS; do
    agents/$agent.sh "$OUTPUT_DIR/dimensions" > "$OUTPUT_DIR/results/$agent.md"
done

# Stage 5: Synthesize
wisdom_synthesis.sh "$OUTPUT_DIR/results" > "$OUTPUT_DIR/FINAL-REPORT.md"
```

---

### 2. Dynamic Pattern Selection

**Problem**: Can't automatically use fabric's pattern library

**Current**: Only uses hardcoded agents

**Needed**: Discover and use any fabric pattern when appropriate

**Requirements**:

#### A. Pattern Discovery
```bash
# Get all available fabric patterns
fabric --listpatterns

# Filter by keywords
fabric --listpatterns | grep -i "extract\|analyze\|improve"
```

#### B. Pattern Matcher
**Input**: Dimension content + keywords

**Process**:
- Search fabric patterns by keywords
- Match pattern purpose to dimension type
- Rank by relevance

**Output**: Recommended patterns

**Implementation**:
```python
# lib/utils/pattern_matcher.py

def find_matching_patterns(dimension: Dict) -> List[str]:
    """
    Finds fabric patterns that match dimension content.
    
    Returns: ["extract_wisdom", "analyze_claims", "improve_prompt"]
    """
```

#### C. Integration with Router
```python
# In agent_selector.py

if no_specific_agent_matches:
    # Fall back to fabric pattern library
    patterns = pattern_matcher.find_matching_patterns(dimension)
    return {"agents": [], "fabric_patterns": patterns}
```

---

### 3. Agent Creator (Future)

**Problem**: Creating new agents is manual

**Vision**: Agent that creates agents

**Requirements**:

#### A. Uniqueness Checker
```python
def check_agent_exists(purpose: str) -> bool:
    """
    Checks if agent with similar purpose already exists.
    Prevents redundant agents.
    """
```

#### B. Pattern Generator
```python
def generate_pattern(purpose: str, examples: List[str]) -> str:
    """
    Generates fabric pattern system.md for new agent.
    Uses fabric to create the pattern itself.
    """
```

#### C. Wrapper Generator
```bash
def generate_wrapper(agent_name: str, pattern_name: str) -> str:
    """
    Generates bash wrapper script for agent.
    """
```

#### D. Validation
```python
def validate_new_agent(agent_name: str) -> bool:
    """
    Tests new agent with sample inputs.
    Validates output quality.
    """
```

---

## Implementation Roadmap

### Phase 1: Intelligent Router (PRIORITY)

**Goal**: Stop running all agents on all content

**Tasks**:

1. **Domain Classifier** (2-3 hours)
   - Create `lib/utils/domain_classifier.py`
   - Implement keyword analysis
   - Implement type analysis
   - Test with various dimension sets
   - Validate accuracy

2. **Agent Selector** (2-3 hours)
   - Create `lib/utils/agent_selector.py`
   - Define agent rules for each domain
   - Implement selection logic
   - Add fallback handling
   - Test with various domains

3. **Adaptive Workflow** (2-3 hours)
   - Create `workflows/adaptive-analysis.sh`
   - Integrate classifier and selector
   - Implement agent execution
   - Add result synthesis
   - Test end-to-end

4. **Validation** (1-2 hours)
   - Test with security content (should run security agents)
   - Test with random content (should run minimal processing)
   - Test with research content (should run research agents)
   - Validate no unnecessary agent execution

**Success Criteria**:
- Security content → security agents only
- Random content → basic processing only
- Research content → research agents only
- No wasted agent execution

---

### Phase 2: Dynamic Pattern Selection

**Goal**: Use fabric's pattern library dynamically

**Tasks**:

1. **Pattern Discovery** (1 hour)
   - Script to list all fabric patterns
   - Parse pattern names and purposes
   - Cache pattern list

2. **Pattern Matcher** (2-3 hours)
   - Create `lib/utils/pattern_matcher.py`
   - Implement keyword matching
   - Implement purpose matching
   - Rank patterns by relevance

3. **Integration** (2 hours)
   - Integrate with agent selector
   - Add fallback to pattern library
   - Test with unmatched content

4. **Validation** (1 hour)
   - Test with content that has no specific agent
   - Verify appropriate patterns are selected
   - Validate output quality

**Success Criteria**:
- Content without specific agent gets appropriate fabric pattern
- Pattern selection is relevant
- Output quality maintained

---

### Phase 3: Agent Creator (Future)

**Goal**: Automate agent creation

**Tasks**:

1. **Uniqueness Checker** (2 hours)
   - Analyze existing agents
   - Compare purposes
   - Prevent redundancy

2. **Pattern Generator** (3-4 hours)
   - Use fabric to generate patterns
   - Validate pattern structure
   - Test generated patterns

3. **Wrapper Generator** (1-2 hours)
   - Generate bash scripts
   - Set permissions
   - Add to agent directory

4. **Validation System** (2-3 hours)
   - Test new agents automatically
   - Validate output quality
   - Approve or reject

**Success Criteria**:
- Can create new agent from description
- Validates uniqueness
- Tests automatically
- Produces working agent

---

## Technical Requirements

### Domain Classifier

**Input Format**:
```json
{
  "dimensions": [
    {
      "filename": "hardware-specs.md",
      "type": "technical",
      "weight": "high",
      "keywords": ["hardware", "router", "specs"]
    }
  ]
}
```

**Output Format**:
```json
{
  "domain": "technical",
  "confidence": 0.85,
  "sub_domains": ["networking", "hardware"],
  "indicators": {
    "technical_keywords": 15,
    "security_keywords": 3,
    "technical_dimensions": 5
  },
  "recommendation": "Use technical + security agents"
}
```

**Algorithm**:
```python
def classify_domain(dimensions):
    # Count keywords by category
    keyword_counts = count_keywords_by_category(dimensions)
    
    # Count dimensions by type
    type_counts = count_dimensions_by_type(dimensions)
    
    # Calculate domain scores
    scores = {
        "security": keyword_counts["security"] * 2 + type_counts["technical"],
        "technical": keyword_counts["technical"] * 2 + type_counts["technical"],
        "research": keyword_counts["research"] + type_counts["cognitive"],
        "general": type_counts["affective"] + type_counts["cognitive"]
    }
    
    # Select highest score
    domain = max(scores, key=scores.get)
    confidence = scores[domain] / sum(scores.values())
    
    return {"domain": domain, "confidence": confidence}
```

---

### Agent Selector

**Input Format**:
```json
{
  "domain": "security",
  "confidence": 0.92,
  "dimensions": [...]
}
```

**Output Format**:
```json
{
  "agents": [
    {
      "name": "question_narrowing",
      "reason": "Clarify security questions",
      "priority": 1
    },
    {
      "name": "threat_intelligence",
      "reason": "Research security threats",
      "priority": 2
    }
  ],
  "execution_order": "sequential",
  "estimated_time": "90s"
}
```

**Selection Logic**:
```python
def select_agents(domain, dimensions):
    # Get base agents for domain
    agents = AGENT_RULES.get(domain, ["extract_wisdom"])
    
    # Filter based on dimension count
    if len(dimensions) == 1:
        # Single dimension - simpler workflow
        agents = agents[:2]
    
    # Add synthesis if multiple agents
    if len(agents) > 1:
        agents.append("wisdom_synthesis")
    
    return {
        "agents": agents,
        "execution_order": "sequential",
        "estimated_time": len(agents) * 30
    }
```

---

## Testing Strategy

### Unit Tests

**Domain Classifier**:
```python
def test_security_classification():
    dimensions = load_test_dimensions("security-content")
    result = classify_domain(dimensions)
    assert result["domain"] == "security"
    assert result["confidence"] > 0.8

def test_random_classification():
    dimensions = load_test_dimensions("random-content")
    result = classify_domain(dimensions)
    assert result["domain"] == "random" or result["domain"] == "general"
```

**Agent Selector**:
```python
def test_security_agent_selection():
    domain = {"domain": "security", "confidence": 0.9}
    result = select_agents(domain, [])
    assert "threat_intelligence" in result["agents"]
    assert "config_validator" in result["agents"]

def test_random_agent_selection():
    domain = {"domain": "random", "confidence": 0.7}
    result = select_agents(domain, [])
    assert len(result["agents"]) <= 2  # Minimal processing
```

### Integration Tests

**End-to-End**:
```bash
# Test 1: Security content
./adaptive-analysis.sh security-input.txt output/
# Verify: Only security agents ran

# Test 2: Random content
./adaptive-analysis.sh random-input.txt output/
# Verify: Only basic processing ran

# Test 3: Research content
./adaptive-analysis.sh research-input.txt output/
# Verify: Research agents ran
```

---

## Performance Targets

**Dimension Extraction**: < 10 seconds  
**Domain Classification**: < 1 second  
**Agent Selection**: < 1 second  
**Agent Execution**: 30-60 seconds per agent  
**Total Workflow**: < 3 minutes for typical content

---

## Error Handling

### Graceful Degradation

```python
try:
    domain = classify_domain(dimensions)
except Exception:
    # Fall back to general processing
    domain = {"domain": "general", "confidence": 0.5}

try:
    agents = select_agents(domain, dimensions)
except Exception:
    # Fall back to basic wisdom extraction
    agents = {"agents": ["extract_wisdom"]}
```

### Validation

```python
# Validate dimension extraction
if not dimensions or len(dimensions) == 0:
    raise ValueError("No dimensions extracted")

# Validate domain classification
if domain["confidence"] < 0.3:
    logger.warning("Low confidence classification, using fallback")
    domain = {"domain": "general"}

# Validate agent selection
if not agents or len(agents["agents"]) == 0:
    agents = {"agents": ["extract_wisdom"]}  # Always have fallback
```

---

## Next Steps

1. **Implement Domain Classifier** - Start here
2. **Implement Agent Selector** - Second priority
3. **Create Adaptive Workflow** - Integrate components
4. **Test with Real Content** - Validate behavior
5. **Document Results** - Update README with examples

---

**Status**: Specification complete, ready for implementation  
**Priority**: Intelligent Router (Phase 1)  
**Timeline**: 8-10 hours for Phase 1 completion
