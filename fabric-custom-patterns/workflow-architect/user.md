# Example Usage

## Example 1: Simple Request

"I want to create a workflow that takes meeting notes and generates action items with assignees and deadlines"

## Example 2: Detailed Request

"I have a tool called 'voicenote' that outputs raw transcriptions. I want to:
1. Clean up the transcription (fix typos, remove filler words)
2. Extract key points and decisions
3. Generate a structured summary in markdown

How should I design the patterns and script?"

## Example 3: Improvement Request

"I have a workflow where I analyze code errors and suggest fixes. Currently it's one big pattern but it's not working well. How can I break this into multiple stages?"

## How to Use This Pattern

```bash
# Describe your workflow idea
echo "I want to create a workflow that..." | fabric -p workflow-architect

# Or from a file with detailed requirements
cat workflow-requirements.txt | fabric -p workflow-architect

# Or pipe in existing workflow description for improvement
cat current-workflow-docs.md | fabric -p workflow-architect
```

## What You'll Get

- Complete workflow design with stage breakdown
- Pattern specifications ready to implement
- Bash script structure
- System prompt templates for each pattern
- Testing strategy
- Implementation guidance
