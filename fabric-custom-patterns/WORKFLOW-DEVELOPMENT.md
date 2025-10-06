# Workflow Development Quick Start

## The Pattern: workflow-architect

Use this pattern when you need to design new script+pattern workflows.

### Direct Usage

```bash
# Describe your idea
echo "I want to create a workflow that..." | fabric -p workflow-architect

# From a file
cat idea.txt | fabric -p workflow-architect
```

### Helper Script

```bash
# Quick access with our helper
workflow-design "I want to create a workflow that..."

# Interactive mode
workflow-design
```

## What You'll Get

The pattern provides:

1. **Workflow Overview** - High-level description
2. **Pipeline Design** - Visual flow diagram  
3. **Required Patterns** - Each agent specification
   - Purpose
   - Input/output formats
   - Key instructions
4. **Script Design** - Orchestration logic
5. **Implementation Skeleton** - Ready-to-use code
6. **Pattern System Prompts** - Template prompts for each agent
7. **Testing Examples** - How to test the workflow
8. **Iteration Suggestions** - How to improve

## Example Workflow Ideas

### 1. Code Documentation Generator
```bash
workflow-design "Takes code snippets and generates detailed docs with examples and gotchas"
```

### 2. Meeting Notes Processor
```bash
workflow-design "Converts raw meeting transcripts into action items with assignees and deadlines"
```

### 3. Error Analysis Pipeline
```bash
workflow-design "Analyzes error logs, categorizes issues, and suggests fixes with priority levels"
```

### 4. Content Summarizer
```bash
workflow-design "Reads long articles, extracts key points, and generates executive summaries with citations"
```

## Development Workflow

```
1. Use workflow-architect to design
   ↓
2. Create pattern directories
   mkdir -p fabric-patterns/pattern-name
   ↓
3. Write system.md prompts from templates
   vim fabric-patterns/pattern-name/system.md
   ↓
4. Create orchestration script
   vim script-name
   chmod +x script-name
   ↓
5. Test with sample data
   echo "test" | ./script-name
   ↓
6. Iterate on patterns and script
   (edit patterns, test, refine, repeat)
   ↓
7. Document in NOTES.md
```

## Tips

- **Start Simple**: Begin with 2-3 stages, add complexity later
- **Test Each Stage**: Verify patterns individually before chaining
- **Show Progress**: Use verbose output to debug the pipeline
- **Handle Errors**: Add fallbacks for when patterns fail
- **Keep Reusable**: Design patterns that can work in multiple workflows

## Pattern Structure Reference

```
fabric-patterns/
└── your-pattern/
    ├── system.md      # The AI prompt (required)
    └── user.md        # Example inputs (optional)
```

System prompt template:
```markdown
# IDENTITY and PURPOSE
[Who the AI is and what it does]

# INPUT FORMAT
[What data it expects]

# OUTPUT FORMAT
[What data it produces]

# STEPS
[Instructions for the AI]

# OUTPUT INSTRUCTIONS
[Formatting and style guidelines]

# INPUT
INPUT:
```

## Resources

- **Main Docs**: `fabric-patterns/README.md`
- **Script Notes**: `.myscripts/NOTES.md`  
- **Pattern Examples**: Look at `transcript-analyzer` and `transcript-refiner`
- **Test Your Ideas**: Use `workflow-design` command

---

**Remember**: Patterns are agents. Scripts are orchestrators. workflow-architect helps you design both! 🎨
