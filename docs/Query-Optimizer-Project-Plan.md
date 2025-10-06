# Query Optimizer: Intelligent Search Prompt Transformation System

## Project Context

This system emerged from a need to bridge the gap between how humans naturally express questions and how AI search systems need queries structured for optimal results. By studying the [Perplexity Prompt Guide](./Perplexity%20-%20Prompt%20Guide.md), we identified patterns and principles that can be systematically applied to any user input to create search-optimized prompts.

### The Problem

- Users ask questions naturally but vaguely ("tell me about climate models")
- AI search systems need specific, contextual queries to retrieve relevant results
- Generic inputs lead to scattered results and potential hallucinations
- Different query types (factual research, technical questions, creative requests) require different prompt structures
- Manual prompt optimization is time-consuming and requires expertise

### The Solution

An automated pipeline that:
1. Analyzes user input to understand intent and classify query type
2. Enriches queries with context and specificity using proven principles
3. Generates search-optimized prompts following best practices
4. Structures everything as JSON for traceability and further processing
5. Prepares for future API integration while remaining testable at every stage

### Why This Matters

- **Platform-agnostic**: Principles work across Perplexity, ChatGPT search, Claude, and other AI search tools
- **Fabric integration**: Leverages existing fabric pattern system for LLM operations
- **Incremental development**: Each stage is independently testable
- **Human-in-the-loop**: Generates prompts for manual testing before full automation
- **Traceable**: Complete JSON audit trail of transformations

## Core Design Principles

### From the Perplexity Guide

**Must Apply:**
- Add 2-3 words of context to increase specificity
- Avoid few-shot prompting (confuses search component)
- Think like a web search user (use search-friendly terms)
- Never request URLs in prompt text (causes hallucination)
- Include explicit fallback instructions ("if no information found...")
- Focus on publicly accessible sources
- Use conditional language to allow uncertainty

**Must Avoid:**
- Overly generic questions without scope
- Traditional LLM role-playing techniques for search queries
- Complex multi-part unrelated questions
- Assuming the system will infer search intent

### Our Implementation Philosophy

- **Composable**: Each stage does one thing well
- **Transparent**: Full visibility into transformations via JSON
- **Testable**: Every component can be validated independently
- **Practical**: Outputs real prompts you can copy and use immediately
- **Extensible**: Easy to add new stages or modify existing ones

## System Architecture

```
┌─────────────────┐
│   User Input    │  (transcription, question, raw text)
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Stage 1: Input Analysis & Classification               │
│  - Extract intent                                       │
│  - Classify query type                                  │
│  - Identify entities                                    │
│  → Uses: fabric pattern (query_classifier)             │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Stage 2: Context Enrichment                            │
│  - Add specificity (2-3 context words)                  │
│  - Flag generic queries                                 │
│  - Identify hallucination risks                         │
│  → Uses: fabric pattern (context_enricher)             │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Stage 3: Deep Search Prompt Generation                 │
│  - Apply Perplexity guide principles                    │
│  - Format for query type                                │
│  - Add fallback instructions                            │
│  → Uses: fabric pattern (search_optimizer)             │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Stage 4: Search Execution (Future/Manual)              │
│  - Output prompt for manual testing                     │
│  - (Future) API integration                             │
│  → Currently: copy-paste to web interface              │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Stage 5: Result Processing (Future)                    │
│  - Validate sources                                     │
│  - Check hallucination risk                             │
│  - Extract insights                                     │
└────────┬────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ Structured JSON │  (complete audit trail + final prompt)
│   Output File   │
└─────────────────┘
```

## Workflow Stages (Detailed)

### Stage 1: Input Analysis & Classification

**Purpose**: Understand what the user is really asking

**Input**: 
- Raw text (could be a transcription, typed question, or paste)

**Processing**:
- Run through fabric pattern to extract core intent
- Classify into query types: `factual_research`, `technical_question`, `creative_content`, `analysis_insights`
- Identify key entities, timeframes, locations, constraints
- Detect if additional context is needed

**Output Structure**:
```json
{
  "stage": "input_analysis",
  "timestamp": "2025-10-01T10:30:00Z",
  "query_type": "factual_research",
  "intent": "User wants to understand recent developments in quantum computing",
  "key_entities": ["quantum computing", "recent developments"],
  "temporal_context": "recent/current",
  "geographic_context": null,
  "specificity_level": "low",
  "needs_enrichment": true,
  "original_input": "tell me about quantum computing"
}
```

**Fabric Pattern Needed**: `query_classifier` (custom pattern to create)

### Stage 2: Context Enrichment

**Purpose**: Transform vague into specific following Perplexity principles

**Input**: 
- Analysis JSON from Stage 1

**Processing**:
- Apply "Be Specific and Contextual" principle
- Add 2-3 words of targeted context based on query type
- Flag if query requests inaccessible sources (LinkedIn, private docs)
- Detect overly generic language
- Suggest specific improvements

**Output Structure**:
```json
{
  "stage": "context_enrichment",
  "original_query": "tell me about quantum computing",
  "enriched_query": "recent advances in quantum computing for cryptography applications",
  "context_added": ["recent advances", "cryptography applications"],
  "specificity_improvement": "300%",
  "warnings": [],
  "recommendations": [
    "added temporal context: 'recent advances'",
    "added domain context: 'cryptography applications'",
    "narrowed scope from general to specific use case"
  ]
}
```

**Fabric Pattern Needed**: `context_enricher` (custom)

### Stage 3: Deep Search Prompt Generation

**Purpose**: Create the final, optimized search prompt

**Input**: 
- Enriched query from Stage 2
- Query type from Stage 1

**Processing**:
- Apply all Perplexity guide principles
- Format according to query type (factual vs technical vs creative)
- Add explicit fallback instructions
- Include source transparency requests
- Avoid few-shot patterns
- Use search-friendly language

**Output Structure**:
```json
{
  "stage": "prompt_generation",
  "optimized_prompt": "What are the recent advances in quantum computing for cryptography applications announced in the past 12 months? Focus on commercial implementations and research breakthroughs. If specific information is not available, please indicate what aspects could not be verified.",
  "prompt_characteristics": {
    "specificity": "high",
    "temporal_bounds": "past 12 months",
    "fallback_included": true,
    "source_transparency": true,
    "search_friendly": true
  },
  "suggested_parameters": {
    "search_domain_filter": ["ieee.org", "arxiv.org", "nature.com"],
    "search_recency_filter": "past_year",
    "search_context_size": "high"
  },
  "query_type_applied": "factual_research"
}
```

**Fabric Pattern Needed**: `search_optimizer` (custom), `hallucination_guard` (custom)

### Stage 4: Search Execution

**Current Implementation**: Output prompt for manual testing

**Input**:
- Optimized prompt from Stage 3

**Output Structure**:
```json
{
  "stage": "search_execution",
  "status": "ready_for_manual_test",
  "prompt_to_copy": "What are the recent advances in quantum computing...",
  "test_instructions": "Copy the prompt above and test in:",
  "test_platforms": [
    "perplexity.ai",
    "chatgpt.com (with search enabled)",
    "claude.ai (with search feature)"
  ],
  "api_integration_status": "planned",
  "next_steps": "After manual testing, evaluate result quality and iterate on prompt generation logic"
}
```

**Future Enhancement**: API integration for automated search

### Stage 5: Result Processing (Future)

**Purpose**: Validate and process search results

**Planned Processing**:
- Check if sources returned are accessible
- Validate information consistency across sources
- Flag potential hallucination indicators
- Extract key insights
- Rate confidence level

**Planned Output**:
```json
{
  "stage": "result_processing",
  "sources_analyzed": 5,
  "accessible_sources": 5,
  "inaccessible_sources": 0,
  "hallucination_risk": "low",
  "confidence_score": 0.92,
  "key_insights": [
    "IBM announced 1000+ qubit quantum processor in 2023",
    "Post-quantum cryptography standards finalized by NIST"
  ],
  "validation_notes": "All sources are from peer-reviewed publications or official announcements"
}
```

## File Structure

```
~/.myscripts/
├── query-optimizer                    # Main executable script
├── lib/
│   ├── qo-stage1-analyze.sh          # Input analysis
│   ├── qo-stage2-enrich.sh           # Context enrichment
│   ├── qo-stage3-generate.sh         # Prompt generation
│   ├── qo-stage4-execute.sh          # Search execution (manual/API)
│   ├── qo-stage5-process.sh          # Result processing
│   └── qo-common.sh                  # Shared utilities (JSON, logging)
├── docs/
│   ├── Query-Optimizer-Project-Plan.md    # This file
│   ├── Perplexity - Prompt Guide.md       # Reference documentation
│   └── Structured Outputs Guide.md        # Additional reference
└── fabric-patterns/
    ├── query_classifier/
    │   └── system.md                 # Custom pattern for Stage 1
    ├── context_enricher/
    │   └── system.md                 # Custom pattern for Stage 2
    ├── search_optimizer/
    │   └── system.md                 # Custom pattern for Stage 3
    └── hallucination_guard/
        └── system.md                 # Safety instructions generator

~/.cache/query-optimizer/
├── sessions/
│   └── session_[timestamp].json      # Complete workflow traces
├── prompts/
│   └── prompt_[timestamp].txt        # Generated prompts for testing
└── logs/
    └── qo.log                        # Execution logs
```

## JSON Session Format

Each workflow execution creates a session file:

```json
{
  "session_id": "1696118400",
  "timestamp_start": "2025-10-01T10:30:00Z",
  "timestamp_end": "2025-10-01T10:30:15Z",
  "duration_seconds": 15,
  "user_input": "tell me about quantum computing",
  "stages": {
    "input_analysis": { /* Stage 1 output */ },
    "context_enrichment": { /* Stage 2 output */ },
    "prompt_generation": { /* Stage 3 output */ },
    "search_execution": { /* Stage 4 output */ }
  },
  "final_output": {
    "optimized_prompt": "What are the recent advances...",
    "ready_for_search": true,
    "estimated_quality": "high"
  },
  "metadata": {
    "fabric_version": "1.x.x",
    "patterns_used": ["query_classifier", "context_enricher", "search_optimizer"],
    "stages_completed": 4,
    "stages_total": 5
  }
}
```

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Create main `query-optimizer` script structure
- [ ] Implement JSON session management
- [ ] Build common utilities (logging, file handling)
- [ ] Set up cache directory structure

### Phase 2: Stage 1 - Analysis (Week 1-2)
- [ ] Create `query_classifier` fabric pattern
- [ ] Implement `qo-stage1-analyze.sh`
- [ ] Test with diverse query types
- [ ] Refine classification logic

### Phase 3: Stage 2 - Enrichment (Week 2)
- [ ] Create `context_enricher` fabric pattern
- [ ] Implement `qo-stage2-enrich.sh`
- [ ] Test specificity improvements
- [ ] Validate against Perplexity guide principles

### Phase 4: Stage 3 - Generation (Week 2-3)
- [ ] Create `search_optimizer` and `hallucination_guard` patterns
- [ ] Implement `qo-stage3-generate.sh`
- [ ] Generate test prompts
- [ ] Manual testing in Perplexity/ChatGPT/Claude

### Phase 5: Integration & Testing (Week 3)
- [ ] Connect all stages in main script
- [ ] End-to-end testing with various inputs
- [ ] Refine based on actual search result quality
- [ ] Document usage patterns

### Phase 6: Stage 4 - Manual Execution (Week 4)
- [ ] Implement prompt output for manual testing
- [ ] Create testing workflow documentation
- [ ] Gather feedback on prompt quality

### Phase 7: Future - API Integration (TBD)
- [ ] Research API options (Perplexity, others)
- [ ] Implement automated search execution
- [ ] Add Stage 5 result processing
- [ ] Full automation testing

## Usage Examples

### Basic Usage
```bash
# Interactive mode
query-optimizer

# Direct input
query-optimizer "tell me about climate change"

# From file
cat transcription.txt | query-optimizer

# From clipboard
to_clip | query-optimizer
```

### Advanced Usage
```bash
# Run only specific stages
query-optimizer --stages 1,2 "your query"

# Output only final prompt (no JSON)
query-optimizer --prompt-only "your query"

# Specify query type explicitly
query-optimizer --type technical "explain kubernetes"

# Verbose output
query-optimizer --verbose "your query"

# Save session with custom name
query-optimizer --session my-research "quantum computing"
```

### Output Examples

**Simple Output (default)**:
```
📊 Analyzing query...
   Type: factual_research
   Specificity: low → high

✨ Optimized Prompt:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What are the recent advances in quantum computing 
for cryptography applications announced in the past 
12 months? Focus on commercial implementations and 
research breakthroughs. If specific information is 
not available, please indicate what aspects could 
not be verified.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💾 Session saved: ~/.cache/query-optimizer/sessions/session_1696118400.json
📋 Prompt copied to: ~/.cache/query-optimizer/prompts/prompt_1696118400.txt

🧪 Test this prompt in:
   • perplexity.ai
   • chatgpt.com
   • claude.ai
```

**JSON Output (--json flag)**:
```json
{
  "session_id": "1696118400",
  "optimized_prompt": "What are the recent advances...",
  "stages": { /* full stage data */ }
}
```

## Testing Strategy

### Unit Testing (Per Stage)
```bash
# Test Stage 1 with known inputs
echo "test query" | qo-stage1-analyze.sh --test

# Test Stage 2 with fixture data
qo-stage2-enrich.sh --test --fixture tests/stage1-output.json

# Test Stage 3 prompt generation
qo-stage3-generate.sh --test --fixture tests/stage2-output.json
```

### Integration Testing
```bash
# Run full pipeline with test cases
./tests/run-integration-tests.sh

# Test cases include:
# - Generic queries → specific prompts
# - Technical questions → proper formatting
# - Creative requests → appropriate structure
# - Hallucination-prone queries → safety guards
```

### Manual Quality Testing
1. Generate prompts with query-optimizer
2. Test in real search interfaces (Perplexity, ChatGPT, Claude)
3. Rate result quality (1-5)
4. Document what works/doesn't work
5. Iterate on patterns

## Success Criteria

### Quantitative
- [ ] 80%+ improvement in query specificity (measured by word count + context)
- [ ] 100% of prompts include fallback instructions
- [ ] 100% of prompts avoid requesting URLs directly
- [ ] < 5 seconds processing time per query
- [ ] All stages produce valid JSON

### Qualitative
- [ ] Generated prompts feel natural, not robotic
- [ ] Search results are consistently relevant (manual testing)
- [ ] Reduced hallucination incidents (compared to direct user queries)
- [ ] Users can understand and modify generated prompts
- [ ] System is easy to extend with new stages/patterns

## Key Decisions & Rationale

### Why Bash + Fabric?
- Leverages existing fabric ecosystem and patterns
- Simple to understand and modify
- Easy to integrate with existing scripts
- No dependencies beyond fabric
- Can easily call from other scripts

### Why JSON for intermediate stages?
- Structured data is easier to debug
- Can inspect any stage independently
- Future-proof for API integrations
- Enables data analysis of transformations
- Clear audit trail

### Why manual testing before API integration?
- Validate prompt quality with real results
- Iterate faster without API rate limits
- Learn what works across different platforms
- Build confidence before automation
- Keep costs down during development

### Why stage-based architecture?
- Each stage is independently testable
- Easy to add/remove/modify stages
- Clear separation of concerns
- Can run partial workflows
- Easier to debug issues

## Future Enhancements

### Short Term
- Add more query type classifications
- Create domain-specific optimizations (science, tech, business)
- Build library of validated prompt templates
- Add confidence scoring for generated prompts

### Medium Term
- Implement API integrations (Perplexity, Tavily, SerpAPI)
- Add Stage 5 result processing and validation
- Create web UI for easier testing
- Build feedback loop to improve patterns

### Long Term
- Multi-step research workflows (iterative refinement)
- Automatic source verification
- Cross-platform result comparison
- Learning system that improves from user feedback
- Integration with note-taking systems

## Resources & References

- **Perplexity Prompt Guide**: `docs/Perplexity - Prompt Guide.md`
- **Fabric Documentation**: https://github.com/danielmiessler/fabric
- **Structured Outputs Guide**: `docs/Structured Outputs Guide.md`
- **Project Repo**: `~/.myscripts/` (this workspace)

## Notes & Considerations

- **Platform Agnostic**: While based on Perplexity's guide, principles apply broadly
- **Not Perplexity-Specific**: We're extracting universal search prompt optimization principles
- **Human in Loop**: System augments, doesn't replace human judgment
- **Iterative**: Expect to refine patterns based on real-world testing
- **Extensible**: Easy to add new stages or customize for specific use cases

## Getting Started

1. **Review Documentation**: Read Perplexity Prompt Guide to understand principles
2. **Check Fabric Patterns**: Run `fabric -l` to see what's available
3. **Start Small**: Build Stage 1 first, test thoroughly
4. **Iterate**: Refine based on actual results
5. **Expand**: Add stages as needed

---

**Status**: Planning & Design Phase  
**Next Action**: Begin Phase 1 implementation  
**Last Updated**: 2025-10-01
