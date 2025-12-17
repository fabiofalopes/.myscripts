# Obsidian Note Polish Workflow

A fabric-based workflow for automatically generating titles and frontmatter for Obsidian notes.

## Overview

This workflow uses three fabric patterns to enhance Obsidian notes:

1. **`obsidian_note_title`** - Generates natural, human-readable titles
2. **`obsidian_frontmatter_gen`** - Generates complete YAML frontmatter with metadata
3. **`obsidian_note_polish`** - Combined pattern that does both in one shot

## Installation

### 1. Copy Patterns to Fabric

```bash
# Copy all three patterns to your fabric patterns directory
cp -r obsidian_note_title ~/.config/fabric/patterns/
cp -r obsidian_frontmatter_gen ~/.config/fabric/patterns/
cp -r obsidian_note_polish ~/.config/fabric/patterns/
```

### 2. Install Workflow Script

The `obsidian-polish` script is located in the parent `.myscripts` folder:

```bash
# Make sure it's executable
chmod +x ../obsidian-polish

# Optionally, add to PATH or create alias
alias op='~/path/to/.myscripts/obsidian-polish'
```

## Usage

### Basic Usage (Combined Mode - Default)

Generates both title and frontmatter in one go:

```bash
# From clipboard (macOS)
pbpaste | obsidian-polish

# From clipboard (Linux)
xclip -o | obsidian-polish

# From file
cat my-note.md | obsidian-polish
obsidian-polish -i my-note.md

# Save to file
obsidian-polish -i input.md -o output.md
```

### Title Only Mode

Generate just a title:

```bash
cat note.md | obsidian-polish --title-only

# Or use the pattern directly
cat note.md | fabric -p obsidian_note_title
```

### Frontmatter Only Mode

Generate just the YAML frontmatter:

```bash
cat note.md | obsidian-polish --frontmatter-only

# Or use the pattern directly
cat note.md | fabric -p obsidian_frontmatter_gen
```

## Workflow Examples

### Typical Obsidian Workflow

1. Write note content in Obsidian
2. Select and copy the content (`Cmd+A`, `Cmd+C`)
3. Run: `pbpaste | obsidian-polish`
4. Review the suggested title and frontmatter
5. Paste back into note (`Cmd+V`)

### Batch Processing Multiple Notes

```bash
#!/bin/bash
# Process all notes in a folder

for note in notes/*.md; do
    echo "Processing: $note"
    obsidian-polish -i "$note" -o "enhanced/$note"
done
```

### Integration with Obsidian Templater

Create a Templater script in Obsidian:

```javascript
<%*
// Get current note content
const content = await tp.file.content;

// Run obsidian-polish (requires shell access)
const result = await tp.user.run_shell_command(`echo "${content}" | obsidian-polish`);

// Insert result
return result;
%>
```

## Pattern Details

### `obsidian_note_title`

**Input:** Raw note content  
**Output:** Single title string (50-80 chars)

**Examples:**
- Meeting notes → "Q4 Marketing Campaign Kickoff"
- Code snippet → "Tax Calculation Function"
- Research → "Redis Overview and Key Features"

### `obsidian_frontmatter_gen`

**Input:** Raw note content  
**Output:** Complete YAML frontmatter block

**Generated Properties:**
- `title`: Clear, descriptive title
- `aliases`: Alternative names for linking
- `tags`: Relevant categories (2-5 tags)
- `created`: Date in YYYY-MM-DD format
- `type`: Note classification (idea, reference, project, meeting, etc.)
- `status`: Current state (draft, active, review, archived, permanent)
- `summary`: One-line description

**Example Output:**
```yaml
---
title: Authentication System Planning Meeting
aliases:
  - auth meeting
  - OAuth2 decision
tags:
  - authentication
  - oauth2
  - meeting-notes
  - security
created: 2024-01-15
type: meeting
status: active
summary: Team meeting deciding on OAuth2 + JWT for new auth system, with task assignments and deadline.
---
```

### `obsidian_note_polish` (Combined)

**Input:** Raw note content  
**Output:** Both title and frontmatter in readable format

**Example Output:**
```
TITLE: Dashboard Design Meeting - Dark Mode Decision

FRONTMATTER:
---
title: Dashboard Design Meeting - Dark Mode Decision
aliases:
  - dashboard meeting
  - dark mode discussion
tags:
  - design
  - dashboard
  - meeting-notes
  - ui
created: 2024-01-15
type: meeting
status: active
summary: Design team call deciding on dark-mode-first dashboard approach, Figma delivery Friday.
---
```

## Configuration

### Custom Date Format

The patterns default to YYYY-MM-DD. To change this, edit the `system.md` files:

```markdown
- created: Current date in YYYY-MM-DD format (use today's date)
```

Change to your preferred format (e.g., DD/MM/YYYY, YYYY-MM-DD HH:mm).

### Custom Note Types

Default types: `idea`, `reference`, `project`, `meeting`, `journal`, `article`, `snippet`, `log`

Add custom types by editing the pattern's `system.md`:

```markdown
NOTE TYPES (choose one):
- idea: Thoughts, concepts, brainstorms
- reference: Information, documentation, how-tos
- mycustomtype: Description of your custom type
```

### Language Support

Patterns automatically detect and respond in the same language as the input content. No configuration needed.

## Troubleshooting

### "fabric command not found"

Install fabric:
```bash
brew install fabric  # macOS
# or
pipx install fabric  # Linux/macOS
```

### Empty Output

Check that patterns are in the correct location:
```bash
ls ~/.config/fabric/patterns/ | grep obsidian
```

Should show:
- obsidian_note_title
- obsidian_frontmatter_gen
- obsidian_note_polish

### Incorrect Dates

Patterns use "today's date" instruction. If dates are wrong, check your system clock:
```bash
date
```

## Advanced Usage

### Custom Fabric Model

Use a specific model:
```bash
pbpaste | fabric -p obsidian_note_polish -m claude-3-opus-20240229
```

### Streaming Output

Watch the AI generate in real-time:
```bash
cat note.md | fabric -p obsidian_note_polish --stream
```

### Integration with Other Tools

Chain with other fabric patterns:
```bash
# Extract key points, then generate note metadata
cat meeting.txt | fabric -p extract_wisdom | obsidian-polish
```

## Related Projects

- [Fabric](https://github.com/danielmiessler/fabric) - AI pattern framework
- [Obsidian](https://obsidian.md) - Knowledge base app
- [Obsidian Properties](https://help.obsidian.md/Editing+and+formatting/Properties) - Metadata documentation

## License

Same as parent fabric-custom-patterns repository.
