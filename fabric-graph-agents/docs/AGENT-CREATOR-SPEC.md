# Agent Creator Specification

**Purpose**: Specification for automatic agent creation system

**Status**: FUTURE ENHANCEMENT (Phase 3)

**Priority**: MEDIUM (after Intelligent Router)

---

## Overview

The Agent Creator is a **meta-agent** that creates new agents when the Intelligent Router identifies content that doesn't match existing agents.

### Vision

```bash
# User provides content about a new domain
./adaptive-analysis.sh blockchain-analysis.txt

# Router detects: No agents for "blockchain" domain
# Agent Creator triggers automatically:
# - Analyzes what's needed
# - Creates custom fabric pattern
# - Generates wrapper script
# - Tests new agent
# - Registers for future use

# Next time: blockchain agent is available
```

### Benefits

- **Extensibility**: System grows with usage
- **Automation**: No manual agent creation
- **Consistency**: All agents follow same structure
- **Validation**: Automatic testing before deployment

---

## Architecture

### Components

```
Agent Creator
├── Gap Detector          # Identifies missing capabilities
├── Uniqueness Checker    # Prevents redundant agents
├── Pattern Generator     # Creates fabric pattern
├── Wrapper Generator     # Creates bash wrapper
├── Validator             # Tests new agent
└── Registrar             # Adds to system
```

### Trigger Conditions

1. **No Matching Agents**
   - Router finds no agents for domain
   - Confidence in domain classification is high (> 0.7)
   - Content is substantial (> 500 words)

2. **Explicit Request**
   - User runs: `create-agent.sh "blockchain analysis"`
   - User provides example inputs/outputs

3. **Gap Analysis**
   - Periodic review of unmatched content
   - Identify patterns in fallback usage

---

## Component 1: Gap Detector

### Purpose

Identify when new agent is needed.

### Input

**Router Decision**:
```json
{
  "domain": "blockchain",
  "confidence": 0.85,
  "agents": [],
  "fallback_patterns": ["extract_wisdom"],
  "reasoning": "No specific agents for blockchain domain"
}
```

**Dimension Content**:
```json
{
  "dimensions": [
    {
      "title": "Blockchain Security Analysis",
      "keywords": ["blockchain", "smart contract", "ethereum", "security"],
      "type": "technical"
    }
  ]
}
```

### Process

```python
def detect_gap(router_decision: Dict, dimensions: List[Dict]) -> Dict:
    """
    Detect if new agent is needed.
    
    Returns:
    {
        "gap_detected": true,
        "proposed_agent": "blockchain_security_analyzer",
        "domain": "blockchain",
        "reasoning": "...",
        "confidence": 0.85
    }
    """
    # Check if fallback was used
    if not router_decision.get("agents") and router_decision.get("fallback_patterns"):
        # Check confidence
        if router_decision.get("confidence", 0) > 0.7:
            # Check content substance
            total_content = sum(len(d.get("content", "")) for d in dimensions)
            if total_content > 500:
                # Gap detected
                domain = router_decision["domain"]
                proposed_name = f"{domain}_analyzer"
                
                return {
                    "gap_detected": True,
                    "proposed_agent": proposed_name,
                    "domain": domain,
                    "reasoning": f"High confidence ({router_decision['confidence']:.0%}) in '{domain}' domain but no specific agents available",
                    "confidence": router_decision["confidence"],
                    "keywords": extract_top_keywords(dimensions, n=10)
                }
    
    return {"gap_detected": False}
```

### Output

```json
{
  "gap_detected": true,
  "proposed_agent": "blockchain_security_analyzer",
  "domain": "blockchain",
  "reasoning": "High confidence (85%) in 'blockchain' domain but no specific agents available",
  "confidence": 0.85,
  "keywords": [
    "blockchain", "smart contract", "ethereum", "security",
    "vulnerability", "audit", "defi", "consensus"
  ]
}
```

---

## Component 2: Uniqueness Checker

### Purpose

Ensure new agent doesn't duplicate existing functionality.

### Input

**Proposed Agent**:
```json
{
  "proposed_agent": "blockchain_security_analyzer",
  "domain": "blockchain",
  "keywords": ["blockchain", "smart contract", "security"]
}
```

**Existing Agents**:
```json
[
  {
    "name": "threat_intelligence",
    "domain": "security",
    "keywords": ["security", "threat", "vulnerability"]
  },
  {
    "name": "config_validator",
    "domain": "security",
    "keywords": ["config", "security", "validation"]
  }
]
```

### Process

```python
def check_uniqueness(proposed: Dict, existing: List[Dict]) -> Dict:
    """
    Check if proposed agent is unique.
    
    Returns:
    {
        "is_unique": true,
        "similarity_scores": {...},
        "recommendation": "create" | "use_existing" | "merge"
    }
    """
    proposed_keywords = set(proposed["keywords"])
    
    similarity_scores = {}
    for agent in existing:
        agent_keywords = set(agent["keywords"])
        
        # Jaccard similarity
        intersection = proposed_keywords & agent_keywords
        union = proposed_keywords | agent_keywords
        similarity = len(intersection) / len(union) if union else 0
        
        similarity_scores[agent["name"]] = similarity
    
    # Check if too similar to existing
    max_similarity = max(similarity_scores.values()) if similarity_scores else 0
    
    if max_similarity > 0.7:
        most_similar = max(similarity_scores, key=similarity_scores.get)
        return {
            "is_unique": False,
            "similarity_scores": similarity_scores,
            "recommendation": "use_existing",
            "suggested_agent": most_similar,
            "reasoning": f"Proposed agent is {max_similarity:.0%} similar to existing '{most_similar}'"
        }
    elif max_similarity > 0.4:
        return {
            "is_unique": True,
            "similarity_scores": similarity_scores,
            "recommendation": "create_with_caution",
            "reasoning": f"Some overlap with existing agents (max {max_similarity:.0%}), but unique enough to warrant new agent"
        }
    else:
        return {
            "is_unique": True,
            "similarity_scores": similarity_scores,
            "recommendation": "create",
            "reasoning": "Proposed agent is sufficiently unique"
        }
```

### Output

```json
{
  "is_unique": true,
  "similarity_scores": {
    "threat_intelligence": 0.35,
    "config_validator": 0.20
  },
  "recommendation": "create",
  "reasoning": "Proposed agent is sufficiently unique"
}
```

---

## Component 3: Pattern Generator

### Purpose

Generate fabric pattern for new agent using fabric itself.

### Input

**Agent Specification**:
```json
{
  "name": "blockchain_security_analyzer",
  "domain": "blockchain",
  "keywords": ["blockchain", "smart contract", "security"],
  "purpose": "Analyze blockchain and smart contract security",
  "example_inputs": ["..."],
  "desired_outputs": ["..."]
}
```

### Process

#### Step 1: Generate Pattern Using Fabric

```bash
generate_pattern() {
    local agent_name="$1"
    local domain="$2"
    local purpose="$3"
    local keywords="$4"
    
    # Create prompt for pattern generation
    cat > /tmp/pattern-prompt.txt << EOF
Create a fabric pattern for an agent with these specifications:

Name: $agent_name
Domain: $domain
Purpose: $purpose
Keywords: $keywords

The pattern should follow this structure:

# IDENTITY
[Define the agent's role and expertise]

# GOAL
[Define what the agent should accomplish]

# STEPS
[List the processing steps]

# OUTPUT
[Define the output format]

Create a complete, production-ready fabric pattern.
EOF
    
    # Use fabric to generate pattern
    fabric --pattern create_pattern < /tmp/pattern-prompt.txt
}
```

#### Step 2: Validate Pattern Structure

```python
def validate_pattern(pattern_text: str) -> Dict:
    """
    Validate pattern has required sections.
    
    Returns:
    {
        "valid": true,
        "sections": ["IDENTITY", "GOAL", "STEPS", "OUTPUT"],
        "issues": []
    }
    """
    required_sections = ["IDENTITY", "GOAL", "STEPS", "OUTPUT"]
    found_sections = []
    issues = []
    
    for section in required_sections:
        if f"# {section}" in pattern_text:
            found_sections.append(section)
        else:
            issues.append(f"Missing section: {section}")
    
    # Check minimum length
    if len(pattern_text) < 200:
        issues.append("Pattern too short (< 200 characters)")
    
    # Check for placeholder text
    placeholders = ["TODO", "FIXME", "[...]", "..."]
    for placeholder in placeholders:
        if placeholder in pattern_text:
            issues.append(f"Contains placeholder: {placeholder}")
    
    return {
        "valid": len(issues) == 0,
        "sections": found_sections,
        "issues": issues
    }
```

#### Step 3: Save Pattern

```bash
save_pattern() {
    local agent_name="$1"
    local pattern_text="$2"
    
    local pattern_dir="fabric-custom-patterns/$agent_name"
    mkdir -p "$pattern_dir"
    
    echo "$pattern_text" > "$pattern_dir/system.md"
    
    echo "Pattern saved: $pattern_dir/system.md"
}
```

### Output

**File**: `fabric-custom-patterns/blockchain_security_analyzer/system.md`

```markdown
# IDENTITY

You are an expert blockchain security analyst specializing in smart contract auditing, DeFi protocol analysis, and blockchain infrastructure security.

# GOAL

Your purpose is to analyze blockchain-related content and provide comprehensive security assessments, identify vulnerabilities, and recommend best practices.

# STEPS

- Identify the blockchain platform and technologies mentioned
- Analyze smart contract code or architecture if provided
- Identify potential security vulnerabilities
- Assess common attack vectors (reentrancy, overflow, access control, etc.)
- Evaluate consensus mechanism security
- Review key management and cryptographic practices
- Provide risk assessment and severity ratings
- Recommend specific security improvements

# OUTPUT

Provide a structured security analysis with:

1. **Overview**: Summary of the blockchain system/contract analyzed
2. **Security Findings**: List of identified vulnerabilities with severity
3. **Attack Vectors**: Potential attack scenarios
4. **Risk Assessment**: Overall security posture rating
5. **Recommendations**: Specific, actionable security improvements
6. **Best Practices**: General blockchain security guidelines relevant to this case

Format findings clearly with severity levels (Critical, High, Medium, Low).
```

---

## Component 4: Wrapper Generator

### Purpose

Generate bash wrapper script for the agent.

### Input

**Agent Specification**:
```json
{
  "name": "blockchain_security_analyzer",
  "pattern": "blockchain_security_analyzer",
  "default_model": "openai/gpt-4"
}
```

### Process

```bash
generate_wrapper() {
    local agent_name="$1"
    local pattern_name="$2"
    local default_model="$3"
    
    cat > "agents/$agent_name.sh" << 'EOF'
#!/bin/bash
#
# Agent: blockchain_security_analyzer
# Purpose: Analyze blockchain and smart contract security
# Auto-generated by Agent Creator
#

set -euo pipefail

# Configuration
MODEL="${MODEL:-openai/gpt-4}"
PATTERN="blockchain_security_analyzer"
SESSION="${SESSION:-}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

# Source fabric wrapper
source "$LIB_DIR/fabric-wrapper.sh"

# Main execution
main() {
    local input="${1:-}"
    
    if [ -z "$input" ]; then
        # Read from stdin
        fabric_call --model "$MODEL" --pattern "$PATTERN" ${SESSION:+--session "$SESSION"}
    else
        # Read from file
        fabric_call --model "$MODEL" --pattern "$PATTERN" ${SESSION:+--session "$SESSION"} < "$input"
    fi
}

main "$@"
EOF
    
    chmod +x "agents/$agent_name.sh"
    echo "Wrapper created: agents/$agent_name.sh"
}
```

### Output

**File**: `agents/blockchain_security_analyzer.sh`

Executable bash script that wraps the fabric pattern.

---

## Component 5: Validator

### Purpose

Test new agent with sample inputs before deployment.

### Input

**Agent**: `blockchain_security_analyzer.sh`

**Test Cases**:
```json
{
  "test_cases": [
    {
      "input": "Sample smart contract code...",
      "expected_sections": ["Security Findings", "Risk Assessment"]
    }
  ]
}
```

### Process

```bash
validate_agent() {
    local agent_script="$1"
    local test_input="$2"
    
    echo "Testing agent: $agent_script"
    
    # Run agent with test input
    output=$(echo "$test_input" | "$agent_script" 2>&1)
    exit_code=$?
    
    # Check exit code
    if [ $exit_code -ne 0 ]; then
        echo "FAIL: Agent exited with code $exit_code"
        return 1
    fi
    
    # Check output not empty
    if [ -z "$output" ]; then
        echo "FAIL: Agent produced no output"
        return 1
    fi
    
    # Check output length
    if [ ${#output} -lt 100 ]; then
        echo "FAIL: Output too short (< 100 characters)"
        return 1
    fi
    
    # Check for expected sections
    for section in "Security Findings" "Risk Assessment" "Recommendations"; do
        if ! echo "$output" | grep -q "$section"; then
            echo "WARNING: Missing expected section: $section"
        fi
    done
    
    echo "PASS: Agent validation successful"
    return 0
}
```

### Output

```
Testing agent: agents/blockchain_security_analyzer.sh
PASS: Agent validation successful
```

---

## Component 6: Registrar

### Purpose

Register new agent in the system.

### Process

#### Step 1: Update Agent Registry

```bash
register_agent() {
    local agent_name="$1"
    local domain="$2"
    local keywords="$3"
    
    # Update agents.json
    local registry="config/agents.json"
    
    jq --arg name "$agent_name" \
       --arg domain "$domain" \
       --arg keywords "$keywords" \
       '.agents += [{
           "name": $name,
           "domain": $domain,
           "keywords": ($keywords | split(",")),
           "created": (now | strftime("%Y-%m-%d")),
           "auto_generated": true
       }]' "$registry" > "$registry.tmp"
    
    mv "$registry.tmp" "$registry"
    
    echo "Agent registered: $agent_name"
}
```

#### Step 2: Update Router Rules

```bash
update_router_rules() {
    local agent_name="$1"
    local domain="$2"
    
    # Add to agent selection rules
    python3 << EOF
import json

with open('lib/utils/agent_selector.py', 'r') as f:
    content = f.read()

# Add agent to domain rules
# (This is simplified - actual implementation would be more sophisticated)

print("Router rules updated")
EOF
}
```

#### Step 3: Update Documentation

```bash
update_documentation() {
    local agent_name="$1"
    local purpose="$2"
    
    # Add to README
    cat >> README.md << EOF

#### $agent_name
- **Purpose**: $purpose
- **Auto-generated**: Yes
- **Domain**: blockchain
- **Use case**: Blockchain security analysis

EOF
    
    echo "Documentation updated"
}
```

---

## Complete Workflow

### Script: `create-agent.sh`

```bash
#!/bin/bash
#
# Agent Creator
# Automatically creates new agents
#

set -euo pipefail

AGENT_NAME="$1"
DOMAIN="$2"
PURPOSE="$3"
KEYWORDS="$4"

echo "=== Agent Creator ==="
echo "Creating agent: $AGENT_NAME"
echo "Domain: $DOMAIN"
echo "Purpose: $PURPOSE"
echo

# Step 1: Check uniqueness
echo "[1/6] Checking uniqueness..."
UNIQUENESS=$(python3 lib/utils/uniqueness_checker.py "$AGENT_NAME" "$KEYWORDS")
IS_UNIQUE=$(echo "$UNIQUENESS" | jq -r '.is_unique')

if [ "$IS_UNIQUE" != "true" ]; then
    echo "ERROR: Agent not unique"
    echo "$UNIQUENESS" | jq '.'
    exit 1
fi

# Step 2: Generate pattern
echo "[2/6] Generating fabric pattern..."
PATTERN=$(generate_pattern "$AGENT_NAME" "$DOMAIN" "$PURPOSE" "$KEYWORDS")

# Validate pattern
VALIDATION=$(python3 lib/utils/pattern_validator.py "$PATTERN")
IS_VALID=$(echo "$VALIDATION" | jq -r '.valid')

if [ "$IS_VALID" != "true" ]; then
    echo "ERROR: Generated pattern invalid"
    echo "$VALIDATION" | jq '.'
    exit 1
fi

# Save pattern
save_pattern "$AGENT_NAME" "$PATTERN"

# Step 3: Generate wrapper
echo "[3/6] Generating wrapper script..."
generate_wrapper "$AGENT_NAME" "$AGENT_NAME" "openai/gpt-4"

# Step 4: Validate agent
echo "[4/6] Validating agent..."
TEST_INPUT="Test input for $DOMAIN domain"
if ! validate_agent "agents/$AGENT_NAME.sh" "$TEST_INPUT"; then
    echo "ERROR: Agent validation failed"
    exit 1
fi

# Step 5: Register agent
echo "[5/6] Registering agent..."
register_agent "$AGENT_NAME" "$DOMAIN" "$KEYWORDS"
update_router_rules "$AGENT_NAME" "$DOMAIN"

# Step 6: Update documentation
echo "[6/6] Updating documentation..."
update_documentation "$AGENT_NAME" "$PURPOSE"

echo
echo "=== Agent Created Successfully ==="
echo "Pattern: fabric-custom-patterns/$AGENT_NAME/system.md"
echo "Script: agents/$AGENT_NAME.sh"
echo "Test: echo 'test' | agents/$AGENT_NAME.sh"
```

---

## Usage Examples

### Automatic Creation (Triggered by Router)

```bash
# Router detects gap
./adaptive-analysis.sh blockchain-content.txt

# Output:
# [Router] No agents for 'blockchain' domain
# [Agent Creator] Creating blockchain_security_analyzer...
# [Agent Creator] Agent created successfully
# [Router] Retrying with new agent...
```

### Manual Creation

```bash
# Create agent manually
./create-agent.sh \
    "blockchain_security_analyzer" \
    "blockchain" \
    "Analyze blockchain and smart contract security" \
    "blockchain,smart contract,security,ethereum"

# Test new agent
echo "Analyze this smart contract..." | agents/blockchain_security_analyzer.sh
```

### Batch Creation

```bash
# Create multiple agents from spec file
cat agents-to-create.json | while read spec; do
    ./create-agent.sh $(echo "$spec" | jq -r '.name, .domain, .purpose, .keywords')
done
```

---

## Safety Mechanisms

### 1. Human Approval

```bash
# Require approval before deployment
if [ "$AUTO_APPROVE" != "true" ]; then
    echo "Review generated agent:"
    cat "fabric-custom-patterns/$AGENT_NAME/system.md"
    echo
    read -p "Deploy this agent? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Agent creation cancelled"
        exit 1
    fi
fi
```

### 2. Sandbox Testing

```bash
# Test in isolated environment
SANDBOX_DIR="/tmp/agent-test-$$"
mkdir -p "$SANDBOX_DIR"
cp "agents/$AGENT_NAME.sh" "$SANDBOX_DIR/"

# Run in sandbox
(cd "$SANDBOX_DIR" && ./$AGENT_NAME.sh < test-input.txt)
```

### 3. Rollback Capability

```bash
# Backup before registration
backup_system() {
    tar -czf "backups/pre-agent-$AGENT_NAME-$(date +%s).tar.gz" \
        agents/ fabric-custom-patterns/ config/
}

# Rollback if issues
rollback_agent() {
    local agent_name="$1"
    rm -f "agents/$agent_name.sh"
    rm -rf "fabric-custom-patterns/$agent_name"
    # Restore from backup
}
```

---

## Limitations

1. **Pattern Quality**: Generated patterns may need human refinement
2. **Domain Specificity**: May not capture nuanced domain requirements
3. **Testing Coverage**: Limited automated testing
4. **Maintenance**: Auto-generated agents need periodic review

---

## Future Enhancements

1. **Learning from Usage**
   - Track agent performance
   - Refine patterns based on feedback
   - Improve generation prompts

2. **Template Library**
   - Pre-built pattern templates
   - Domain-specific templates
   - Faster generation

3. **Collaborative Creation**
   - Multiple agents collaborate to create new agent
   - Peer review by existing agents
   - Iterative refinement

4. **Version Control**
   - Track agent versions
   - A/B testing of patterns
   - Rollback to previous versions

---

## Implementation Checklist

- [ ] Create gap detector
- [ ] Create uniqueness checker
- [ ] Create pattern generator
- [ ] Create wrapper generator
- [ ] Create validator
- [ ] Create registrar
- [ ] Create `create-agent.sh` script
- [ ] Write tests
- [ ] Add safety mechanisms
- [ ] Document usage
- [ ] Integrate with router

---

**Document Version**: 1.0  
**Last Updated**: 2025-10-26  
**Status**: Complete specification, future implementation  
**Priority**: MEDIUM (Phase 3, after Intelligent Router)
