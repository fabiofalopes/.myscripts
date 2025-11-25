# Intelligent Router Specification

**Purpose**: Detailed specification for the Intelligent Router component

**Status**: TO BE IMPLEMENTED

---

## Overview

The Intelligent Router is the **missing intelligence layer** that analyzes extracted dimensions and selects appropriate processing agents based on content, not hardcoded rules.

### Current Problem

```bash
# Hardcoded workflow - ALWAYS runs ALL agents
extract_dimensions input.txt
question_narrowing dimensions/
threat_intelligence dimensions/
config_validator dimensions/
wisdom_synthesis dimensions/
```

**Issues**:
- Runs security analysis on random text
- Wastes tokens on irrelevant processing
- No intelligence about content type
- Fixed workflow regardless of input

### Solution

```bash
# Intelligent workflow - ANALYZES then ROUTES
extract_dimensions input.txt
classify_domain dimensions/          # NEW: Analyze content
select_agents $domain dimensions/    # NEW: Choose relevant agents
execute_agents $selected_agents      # Only run what's needed
synthesize_results
```

**Benefits**:
- Content-aware processing
- Efficient token usage
- Flexible workflows
- Extensible to new domains

---

## Architecture

### Components

```
Intelligent Router
├── Domain Classifier      # Analyzes content, determines domain
├── Agent Selector         # Matches domain to agents
└── Execution Planner      # Builds execution strategy
```

### Data Flow

```
Dimension Files + Metadata
    ↓
Domain Classifier
    ↓
Domain Classification + Confidence
    ↓
Agent Selector
    ↓
Selected Agents + Execution Plan
    ↓
Execution Planner
    ↓
Execute Agents
    ↓
Results
```

---

## Component 1: Domain Classifier

### Purpose

Analyze dimension files and classify content into domains.

### Input

**Dimension Directory Structure**:
```
dimensions/
├── dimension-1.md
├── dimension-2.md
├── dimension-3.md
└── metadata.json
```

**Metadata Format**:
```json
{
  "dimensions": [
    {
      "filename": "hardware-specifications.md",
      "title": "Hardware Specifications",
      "type": "technical",
      "weight": "high",
      "keywords": ["hardware", "router", "specifications", "ubiquiti"]
    },
    {
      "filename": "security-concerns.md",
      "title": "Security Concerns",
      "type": "security",
      "weight": "high",
      "keywords": ["security", "vulnerability", "threat", "attack"]
    }
  ]
}
```

### Process

#### Step 1: Load Dimensions

```python
def load_dimensions(dimension_dir: str) -> List[Dict]:
    """
    Load all dimension files and metadata.
    
    Returns:
    [
        {
            "filename": "dimension-1.md",
            "title": "...",
            "content": "...",
            "type": "technical",
            "weight": "high",
            "keywords": [...]
        }
    ]
    """
    metadata = json.load(open(f"{dimension_dir}/metadata.json"))
    dimensions = []
    
    for dim in metadata["dimensions"]:
        content = open(f"{dimension_dir}/{dim['filename']}").read()
        dimensions.append({
            **dim,
            "content": content
        })
    
    return dimensions
```

#### Step 2: Extract Keywords

```python
def extract_keywords(dimensions: List[Dict]) -> Dict[str, int]:
    """
    Extract and count keywords across all dimensions.
    
    Returns:
    {
        "security": 15,
        "hardware": 10,
        "threat": 8,
        "config": 5,
        ...
    }
    """
    keyword_counts = defaultdict(int)
    
    for dim in dimensions:
        # From metadata
        for keyword in dim.get("keywords", []):
            keyword_counts[keyword.lower()] += 1
        
        # From content (simple extraction)
        content_lower = dim["content"].lower()
        for keyword in DOMAIN_KEYWORDS:
            keyword_counts[keyword] += content_lower.count(keyword)
    
    return dict(keyword_counts)
```

**Domain Keywords**:
```python
DOMAIN_KEYWORDS = {
    "security": [
        "security", "threat", "vulnerability", "attack", "exploit",
        "malware", "breach", "risk", "hardening", "firewall",
        "encryption", "authentication", "authorization"
    ],
    "technical": [
        "hardware", "software", "config", "configuration", "setup",
        "installation", "implementation", "system", "network",
        "router", "device", "interface"
    ],
    "research": [
        "question", "research", "learn", "understand", "explore",
        "investigate", "study", "analyze", "why", "how",
        "what", "concept", "theory"
    ],
    "development": [
        "code", "programming", "function", "class", "method",
        "api", "library", "framework", "debug", "test",
        "deploy", "build"
    ],
    "general": [
        "insight", "wisdom", "thought", "idea", "reflection",
        "philosophy", "principle", "lesson", "experience"
    ]
}
```

#### Step 3: Analyze Dimension Types

```python
def analyze_types(dimensions: List[Dict]) -> Dict[str, int]:
    """
    Count dimensions by type.
    
    Returns:
    {
        "technical": 5,
        "security": 3,
        "cognitive": 2,
        "affective": 1
    }
    """
    type_counts = defaultdict(int)
    
    for dim in dimensions:
        dim_type = dim.get("type", "unknown")
        type_counts[dim_type] += 1
    
    return dict(type_counts)
```

#### Step 4: Calculate Domain Scores

```python
def calculate_domain_scores(
    keyword_counts: Dict[str, int],
    type_counts: Dict[str, int],
    dimensions: List[Dict]
) -> Dict[str, float]:
    """
    Calculate score for each domain.
    
    Scoring:
    - Keyword matches: 2 points each
    - Type matches: 5 points each
    - Weight multiplier: high=1.5, medium=1.0, low=0.5
    
    Returns:
    {
        "security": 45.5,
        "technical": 38.0,
        "research": 12.0,
        "general": 5.0
    }
    """
    scores = defaultdict(float)
    
    # Keyword scoring
    for domain, keywords in DOMAIN_KEYWORDS.items():
        for keyword in keywords:
            count = keyword_counts.get(keyword, 0)
            scores[domain] += count * 2
    
    # Type scoring
    type_domain_map = {
        "technical": ["security", "technical", "development"],
        "security": ["security"],
        "cognitive": ["research", "general"],
        "affective": ["general"],
        "practical": ["technical", "development"]
    }
    
    for dim_type, count in type_counts.items():
        for domain in type_domain_map.get(dim_type, []):
            scores[domain] += count * 5
    
    # Weight multiplier
    weight_multipliers = {"high": 1.5, "medium": 1.0, "low": 0.5}
    for dim in dimensions:
        weight = dim.get("weight", "medium")
        multiplier = weight_multipliers.get(weight, 1.0)
        # Apply to relevant domains based on dimension keywords
        for keyword in dim.get("keywords", []):
            for domain, domain_keywords in DOMAIN_KEYWORDS.items():
                if keyword.lower() in domain_keywords:
                    scores[domain] *= multiplier
    
    return dict(scores)
```

#### Step 5: Select Primary Domain

```python
def select_domain(scores: Dict[str, float]) -> Dict:
    """
    Select primary domain and calculate confidence.
    
    Returns:
    {
        "domain": "security",
        "confidence": 0.92,
        "scores": {...},
        "sub_domains": ["technical"],
        "reasoning": "High security keyword density..."
    }
    """
    if not scores or sum(scores.values()) == 0:
        return {
            "domain": "general",
            "confidence": 0.5,
            "scores": scores,
            "sub_domains": [],
            "reasoning": "No clear domain indicators, using general processing"
        }
    
    # Primary domain
    primary_domain = max(scores, key=scores.get)
    primary_score = scores[primary_domain]
    total_score = sum(scores.values())
    confidence = primary_score / total_score
    
    # Sub-domains (score > 20% of primary)
    threshold = primary_score * 0.2
    sub_domains = [
        domain for domain, score in scores.items()
        if domain != primary_domain and score > threshold
    ]
    
    # Reasoning
    reasoning = f"Primary domain '{primary_domain}' with {confidence:.0%} confidence. "
    if sub_domains:
        reasoning += f"Sub-domains: {', '.join(sub_domains)}. "
    reasoning += f"Based on keyword analysis and dimension types."
    
    return {
        "domain": primary_domain,
        "confidence": confidence,
        "scores": scores,
        "sub_domains": sub_domains,
        "reasoning": reasoning
    }
```

### Output

```json
{
  "domain": "security",
  "confidence": 0.92,
  "scores": {
    "security": 45.5,
    "technical": 38.0,
    "research": 12.0,
    "development": 3.0,
    "general": 5.0
  },
  "sub_domains": ["technical"],
  "reasoning": "Primary domain 'security' with 92% confidence. Sub-domains: technical. Based on keyword analysis and dimension types.",
  "metadata": {
    "total_dimensions": 5,
    "dimension_types": {
      "technical": 3,
      "security": 2
    },
    "total_keywords": 47
  }
}
```

### Implementation

**File**: `lib/utils/domain_classifier.py`

```python
#!/usr/bin/env python3
"""
Domain Classifier for Fabric Graph Agents

Analyzes dimension files and classifies content domain.
"""

import json
import sys
from pathlib import Path
from collections import defaultdict
from typing import List, Dict

# Domain keyword definitions
DOMAIN_KEYWORDS = {
    # ... (as defined above)
}

def classify_domain(dimension_dir: str) -> Dict:
    """
    Main classification function.
    
    Args:
        dimension_dir: Path to directory containing dimension files
    
    Returns:
        Classification result with domain, confidence, and reasoning
    """
    # Load dimensions
    dimensions = load_dimensions(dimension_dir)
    
    if not dimensions:
        return {
            "domain": "general",
            "confidence": 0.5,
            "reasoning": "No dimensions found"
        }
    
    # Extract keywords
    keyword_counts = extract_keywords(dimensions)
    
    # Analyze types
    type_counts = analyze_types(dimensions)
    
    # Calculate scores
    scores = calculate_domain_scores(keyword_counts, type_counts, dimensions)
    
    # Select domain
    result = select_domain(scores)
    
    # Add metadata
    result["metadata"] = {
        "total_dimensions": len(dimensions),
        "dimension_types": type_counts,
        "total_keywords": sum(keyword_counts.values())
    }
    
    return result

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: domain_classifier.py <dimension_dir>", file=sys.stderr)
        sys.exit(1)
    
    dimension_dir = sys.argv[1]
    result = classify_domain(dimension_dir)
    print(json.dumps(result, indent=2))
```

---

## Component 2: Agent Selector

### Purpose

Match classified domain to appropriate agents and build execution plan.

### Input

**Classification Result**:
```json
{
  "domain": "security",
  "confidence": 0.92,
  "sub_domains": ["technical"],
  "metadata": {
    "total_dimensions": 5
  }
}
```

**Dimension Metadata**:
```json
{
  "dimensions": [...]
}
```

### Process

#### Step 1: Define Agent Rules

```python
AGENT_RULES = {
    "security": {
        "required": ["question_narrowing", "threat_intelligence"],
        "optional": ["config_validator"],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 2
    },
    "technical": {
        "required": ["question_narrowing"],
        "optional": ["config_validator"],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 1
    },
    "research": {
        "required": ["question_narrowing"],
        "optional": [],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 1
    },
    "development": {
        "required": [],
        "optional": [],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 1,
        "fallback_patterns": ["extract_patterns", "improve_code"]
    },
    "general": {
        "required": [],
        "optional": [],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 1,
        "fallback_patterns": ["extract_wisdom", "extract_insights"]
    },
    "random": {
        "required": [],
        "optional": [],
        "synthesis": "wisdom_synthesis",
        "min_dimensions": 0,
        "fallback_patterns": ["extract_wisdom"]
    }
}
```

#### Step 2: Select Agents

```python
def select_agents(
    classification: Dict,
    dimensions: List[Dict]
) -> Dict:
    """
    Select appropriate agents based on domain and content.
    
    Returns:
    {
        "agents": ["question_narrowing", "threat_intelligence"],
        "execution_order": "sequential",
        "reasoning": "...",
        "fallback_patterns": []
    }
    """
    domain = classification["domain"]
    confidence = classification["confidence"]
    num_dimensions = len(dimensions)
    
    # Get rules for domain
    rules = AGENT_RULES.get(domain, AGENT_RULES["general"])
    
    # Start with required agents
    selected_agents = rules["required"].copy()
    
    # Add optional agents based on conditions
    if num_dimensions >= rules.get("min_dimensions", 1):
        selected_agents.extend(rules["optional"])
    
    # Add sub-domain agents
    for sub_domain in classification.get("sub_domains", []):
        sub_rules = AGENT_RULES.get(sub_domain, {})
        for agent in sub_rules.get("optional", []):
            if agent not in selected_agents:
                selected_agents.append(agent)
    
    # Add synthesis if multiple agents
    if len(selected_agents) > 1 or num_dimensions > 1:
        synthesis = rules.get("synthesis")
        if synthesis and synthesis not in selected_agents:
            selected_agents.append(synthesis)
    
    # Fallback patterns if no agents
    fallback_patterns = []
    if not selected_agents:
        fallback_patterns = rules.get("fallback_patterns", ["extract_wisdom"])
    
    # Determine execution order
    execution_order = "sequential"  # Default
    if len(selected_agents) <= 2 and num_dimensions == 1:
        execution_order = "sequential"
    elif len(selected_agents) > 3:
        execution_order = "parallel_then_synthesis"
    
    # Build reasoning
    reasoning = f"Selected {len(selected_agents)} agents for '{domain}' domain "
    reasoning += f"with {confidence:.0%} confidence. "
    if num_dimensions > 1:
        reasoning += f"Processing {num_dimensions} dimensions. "
    if fallback_patterns:
        reasoning += f"Using fallback patterns: {', '.join(fallback_patterns)}."
    
    return {
        "agents": selected_agents,
        "execution_order": execution_order,
        "reasoning": reasoning,
        "fallback_patterns": fallback_patterns,
        "estimated_time_seconds": len(selected_agents) * 30
    }
```

### Output

```json
{
  "agents": [
    "question_narrowing",
    "threat_intelligence",
    "config_validator",
    "wisdom_synthesis"
  ],
  "execution_order": "sequential",
  "reasoning": "Selected 4 agents for 'security' domain with 92% confidence. Processing 5 dimensions.",
  "fallback_patterns": [],
  "estimated_time_seconds": 120
}
```

### Implementation

**File**: `lib/utils/agent_selector.py`

```python
#!/usr/bin/env python3
"""
Agent Selector for Fabric Graph Agents

Selects appropriate agents based on domain classification.
"""

import json
import sys
from typing import List, Dict

# Agent rules (as defined above)
AGENT_RULES = {
    # ...
}

def select_agents(
    classification: Dict,
    dimensions: List[Dict]
) -> Dict:
    """Main agent selection function."""
    # ... (as defined above)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: agent_selector.py <classification_json> <dimensions_json>", 
              file=sys.stderr)
        sys.exit(1)
    
    classification = json.loads(sys.argv[1])
    dimensions = json.loads(sys.argv[2])
    
    result = select_agents(classification, dimensions)
    print(json.dumps(result, indent=2))
```

---

## Component 3: Execution Planner

### Purpose

Build detailed execution plan and orchestrate agent execution.

### Input

**Agent Selection**:
```json
{
  "agents": ["question_narrowing", "threat_intelligence"],
  "execution_order": "sequential"
}
```

### Process

#### Step 1: Build Execution Graph

```python
def build_execution_graph(agents: List[str], order: str) -> Dict:
    """
    Build execution graph with dependencies.
    
    Returns:
    {
        "nodes": [
            {"id": "question_narrowing", "depends_on": []},
            {"id": "threat_intelligence", "depends_on": ["question_narrowing"]}
        ],
        "execution_strategy": "sequential"
    }
    """
    if order == "sequential":
        nodes = []
        for i, agent in enumerate(agents):
            depends_on = [agents[i-1]] if i > 0 else []
            nodes.append({
                "id": agent,
                "depends_on": depends_on
            })
        return {"nodes": nodes, "execution_strategy": "sequential"}
    
    elif order == "parallel_then_synthesis":
        # All agents except last run in parallel
        # Last agent (synthesis) depends on all others
        synthesis = agents[-1]
        parallel_agents = agents[:-1]
        
        nodes = [
            {"id": agent, "depends_on": []}
            for agent in parallel_agents
        ]
        nodes.append({
            "id": synthesis,
            "depends_on": parallel_agents
        })
        
        return {"nodes": nodes, "execution_strategy": "parallel_then_synthesis"}
```

#### Step 2: Execute Agents

```bash
# In workflows/adaptive-analysis.sh

execute_agents() {
    local execution_plan="$1"
    local dimension_dir="$2"
    local output_dir="$3"
    
    # Parse execution plan
    local strategy=$(echo "$execution_plan" | jq -r '.execution_strategy')
    
    if [ "$strategy" = "sequential" ]; then
        # Execute sequentially
        echo "$execution_plan" | jq -r '.nodes[].id' | while read agent; do
            echo "Executing: $agent"
            agents/$agent.sh "$dimension_dir" > "$output_dir/$agent.md"
        done
    elif [ "$strategy" = "parallel_then_synthesis" ]; then
        # Execute parallel agents
        local synthesis=$(echo "$execution_plan" | jq -r '.nodes[-1].id')
        echo "$execution_plan" | jq -r '.nodes[:-1][].id' | while read agent; do
            echo "Executing (parallel): $agent"
            agents/$agent.sh "$dimension_dir" > "$output_dir/$agent.md" &
        done
        wait
        
        # Execute synthesis
        echo "Executing (synthesis): $synthesis"
        agents/$synthesis.sh "$output_dir" > "$output_dir/$synthesis.md"
    fi
}
```

### Output

Executed agents with results in output directory.

---

## Complete Workflow

### Script: `workflows/adaptive-analysis.sh`

```bash
#!/bin/bash
#
# Adaptive Analysis Workflow
# Intelligently routes content through appropriate agents
#

set -euo pipefail

INPUT_FILE="$1"
OUTPUT_DIR="${2:-./analysis-output}"

# Create output structure
mkdir -p "$OUTPUT_DIR"/{dimensions,results,logs}

echo "=== Fabric Graph Agents: Adaptive Analysis ==="
echo "Input: $INPUT_FILE"
echo "Output: $OUTPUT_DIR"
echo

# Stage 1: Extract Dimensions
echo "[1/5] Extracting dimensions..."
lib/dimensional.sh extract "$INPUT_FILE" "$OUTPUT_DIR/dimensions"

# Validate extraction
QUALITY=$(lib/quality.sh validate "$OUTPUT_DIR/dimensions")
echo "Quality score: $QUALITY"

if [ "$QUALITY" -lt 70 ]; then
    echo "WARNING: Low quality extraction, retrying..."
    lib/dimensional.sh extract "$INPUT_FILE" "$OUTPUT_DIR/dimensions" --retry
fi

# Stage 2: Classify Domain
echo "[2/5] Classifying domain..."
CLASSIFICATION=$(python3 lib/utils/domain_classifier.py "$OUTPUT_DIR/dimensions")
echo "$CLASSIFICATION" | jq '.'
echo "$CLASSIFICATION" > "$OUTPUT_DIR/logs/classification.json"

DOMAIN=$(echo "$CLASSIFICATION" | jq -r '.domain')
CONFIDENCE=$(echo "$CLASSIFICATION" | jq -r '.confidence')
echo "Domain: $DOMAIN (confidence: $CONFIDENCE)"
echo

# Stage 3: Select Agents
echo "[3/5] Selecting agents..."
DIMENSIONS=$(cat "$OUTPUT_DIR/dimensions/metadata.json")
AGENT_SELECTION=$(python3 lib/utils/agent_selector.py \
    "$CLASSIFICATION" \
    "$DIMENSIONS")
echo "$AGENT_SELECTION" | jq '.'
echo "$AGENT_SELECTION" > "$OUTPUT_DIR/logs/agent-selection.json"

AGENTS=$(echo "$AGENT_SELECTION" | jq -r '.agents[]')
echo "Selected agents: $(echo $AGENTS | tr '\n' ' ')"
echo

# Stage 4: Execute Agents
echo "[4/5] Executing agents..."
EXECUTION_PLAN=$(python3 lib/utils/execution_planner.py "$AGENT_SELECTION")
execute_agents "$EXECUTION_PLAN" "$OUTPUT_DIR/dimensions" "$OUTPUT_DIR/results"
echo

# Stage 5: Generate Report
echo "[5/5] Generating final report..."
agents/wisdom_synthesis.sh "$OUTPUT_DIR/results" > "$OUTPUT_DIR/FINAL-REPORT.md"

echo
echo "=== Analysis Complete ==="
echo "Report: $OUTPUT_DIR/FINAL-REPORT.md"
echo "Results: $OUTPUT_DIR/results/"
echo "Logs: $OUTPUT_DIR/logs/"
```

---

## Testing

### Test Cases

#### Test 1: Security Content

**Input**: Text about router security, vulnerabilities, hardening

**Expected**:
- Domain: `security`
- Confidence: > 0.8
- Agents: `question_narrowing`, `threat_intelligence`, `config_validator`

#### Test 2: Random Content

**Input**: Random thoughts, no clear topic

**Expected**:
- Domain: `random` or `general`
- Confidence: < 0.6
- Agents: `extract_wisdom` (minimal processing)

#### Test 3: Research Content

**Input**: Questions about learning, exploration

**Expected**:
- Domain: `research`
- Confidence: > 0.7
- Agents: `question_narrowing`, possibly research-specific agents

#### Test 4: Mixed Content

**Input**: Security + hardware + philosophy

**Expected**:
- Domain: `security` or `technical`
- Sub-domains: Other relevant domains
- Agents: Mix of security and technical agents

### Validation

```bash
# Run test suite
./test-intelligent-router.sh

# Test individual components
python3 lib/utils/domain_classifier.py test-data/security-dimensions/
python3 lib/utils/agent_selector.py '{"domain":"security","confidence":0.9}' '{}'

# End-to-end test
./workflows/adaptive-analysis.sh test-data/security-input.txt test-output/
```

---

## Performance Targets

**Domain Classification**: < 1 second  
**Agent Selection**: < 0.5 seconds  
**Total Routing Overhead**: < 2 seconds  
**Improvement vs Hardcoded**: 30-50% faster (fewer agents run)

---

## Error Handling

```python
# Graceful degradation
try:
    classification = classify_domain(dimensions)
except Exception as e:
    logger.warning(f"Classification failed: {e}")
    classification = {
        "domain": "general",
        "confidence": 0.5,
        "reasoning": "Fallback due to classification error"
    }

try:
    agents = select_agents(classification, dimensions)
except Exception as e:
    logger.warning(f"Agent selection failed: {e}")
    agents = {
        "agents": ["extract_wisdom"],
        "reasoning": "Fallback to basic processing"
    }
```

---

## Future Enhancements

1. **Learning from Feedback**
   - Track which agents produce best results
   - Adjust selection rules based on outcomes

2. **Custom Domain Definitions**
   - Allow users to define custom domains
   - Custom keyword sets
   - Custom agent rules

3. **Confidence Thresholds**
   - Require minimum confidence for agent selection
   - Fallback to simpler processing if uncertain

4. **Multi-Domain Support**
   - Process different dimensions with different agents
   - Parallel execution per domain

---

## Implementation Checklist

- [ ] Create `lib/utils/domain_classifier.py`
- [ ] Create `lib/utils/agent_selector.py`
- [ ] Create `lib/utils/execution_planner.py`
- [ ] Create `workflows/adaptive-analysis.sh`
- [ ] Write unit tests for classifier
- [ ] Write unit tests for selector
- [ ] Write integration tests
- [ ] Test with real content
- [ ] Document usage in README
- [ ] Update examples

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-26  
**Status**: Complete specification, ready for implementation  
**Priority**: HIGH - Core functionality
