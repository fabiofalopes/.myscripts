# obsidian-polish

Generate AI-powered title + frontmatter for Obsidian notes using Fabric patterns.

---

## Quick Start

```bash
# Most common workflow: edit + rename
obsidian-polish note.md -r

# Edit in-place (creates backup)
obsidian-polish note.md

# Quick edit from clipboard
pbpaste | obsidian-polish
```

---

## What It Does

- Generates semantic title using AI (obsidian_note_title pattern)
- Creates YAML frontmatter with tags, type, status (obsidian_frontmatter_gen pattern)
- Edits files in-place with automatic backups
- Optionally renames files based on slugified title
- Works with pipes (clipboard, cat, etc.)
- Preserves existing content

---

## Common Workflows

### New Note from Clipboard

```bash
# Review before applying
pbpaste | obsidian-polish

# Direct to file
pbpaste | obsidian-polish -o "$OBSVAULT/inbox/new-note.md"
```

### Existing Note Enhancement

```bash
# Edit with backup (safest)
obsidian-polish meeting-notes.md

# Edit + rename based on title
obsidian-polish meeting-notes.md -r

# Quick edit without backup or prompts
obsidian-polish draft.md --no-backup -y

# Just rename with proper title
obsidian-polish draft.md -r -y
```

### Batch Processing

```bash
# Process multiple notes
for file in "$OBSVAULT/inbox"/*.md; do
    obsidian-polish "$file" -r -y
done

# Only add frontmatter (keep existing titles)
for file in *.md; do
    obsidian-polish "$file" -f --no-backup -y
done
```

---

## Options Reference

### Core Modes

- **Default**: Combined (title + frontmatter)
- `-t, --title-only`: Generate only title (uses obsidian_note_title)
- `-f, --frontmatter-only`: Generate only frontmatter (uses obsidian_frontmatter_gen)

### File Operations

- `-o, --output FILE`: Save to different file (no in-place edit)
- `-r, --rename-file`: Rename file based on generated title (slugified)
- `--no-backup`: Don't create `.bak` file for in-place edits

### Behavior

- `-y, --yes`: Skip all confirmation prompts
- `-h, --help`: Show full help message

---

## Flag Interactions

### ✅ Valid Combinations

```bash
obsidian-polish note.md -r -y           # Rename without prompts
obsidian-polish note.md -r --no-backup  # Rename without backup (risky!)
obsidian-polish note.md -t -y           # Title only, no prompts
```

### ⚠️ Ignored Combinations (with warnings)

```bash
obsidian-polish note.md -r -o out.md    # -r ignored (can't rename with -o)
obsidian-polish note.md -r -f           # -r ignored (needs title to rename)
cat note.md | obsidian-polish -r        # -r ignored (pipe mode, no file)
```

---

## Backup Files

### How Backups Work

- Created **before** any modifications (safety-first)
- Stored in **same directory** as original file
- Naming: `filename.md` → `filename.md.bak`
- **Never automatically deleted** (manual cleanup needed)

### Backup with Rename

```bash
# Initial: note.md
obsidian-polish note.md -r

# After:
# - note.md.bak (backup of original)
# - meeting-with-team-q1-planning.md (renamed + edited)
```

**Note**: Backup keeps original filename. This is intentional for safety.

### Cleanup

```bash
# Remove all backups in directory
rm *.md.bak

# Remove backups older than 7 days
find . -name "*.md.bak" -mtime +7 -delete

# Create alias for cleanup
alias clean-backups='find "$OBSVAULT" -name "*.md.bak" -delete'
```

---

## File Renaming (-r)

### How Slugification Works

The `-r` flag converts titles to filesystem-safe names:

```
Title: "Meeting with Team - Q1 Planning"
File:  meeting-with-team-q1-planning.md

Title: "🚀 Project Kickoff & Goals"
File:  project-kickoff-goals.md

Title: "Notes from 2025-01-15"
File:  notes-from-2025-01-15.md
```

### Rules

1. Converts to ASCII (removes accents: é → e)
2. Replaces non-alphanumeric with hyphens
3. Removes duplicate/leading/trailing hyphens
4. Converts to lowercase
5. Truncates to 100 characters (filesystem safety)

### Edge Cases

**Empty/Invalid Titles**
```bash
# Title: "!!!" or "###"
# Fallback: note-20250119-143025.md (timestamp)
```

**Very Long Titles**
```bash
# Title longer than 100 chars
# Truncated to: first-100-characters-of-the-slugified-title.md
```

**File Already Exists**
```bash
# Prompts for confirmation (unless -y flag)
⚠ Target file already exists: new-title.md
Overwrite? [y/N]:
```

---

## Modes Explained

### Combined Mode (Default)

Uses `obsidian_note_polish` pattern.

```bash
obsidian-polish note.md
```

**Generates:**
- H1 title
- YAML frontmatter (tags, type, status, date)
- Replaces existing frontmatter if present
- Replaces existing H1 if present

**Example output:**
```markdown
---
tags: [meetings, planning]
type: note
status: draft
created: 2025-01-19
---

# Meeting with Team - Q1 Planning

[original content...]
```

### Title-Only Mode

Uses `obsidian_note_title` pattern.

```bash
obsidian-polish note.md -t
```

**Generates:**
- H1 title only
- No frontmatter changes
- Replaces existing H1 if present

### Frontmatter-Only Mode

Uses `obsidian_frontmatter_gen` pattern.

```bash
obsidian-polish note.md -f
```

**Generates:**
- YAML frontmatter only
- No title changes
- Replaces existing frontmatter if present

---

## Fabric Patterns

This script uses three custom Fabric patterns:

### obsidian_note_polish
**Purpose**: Generate both title and frontmatter
**Used in**: Default/combined mode
**Output**: `TITLE: ...` + `FRONTMATTER: ...`

### obsidian_note_title
**Purpose**: Generate semantic title only
**Used in**: `-t, --title-only` mode
**Output**: Just the title text

### obsidian_frontmatter_gen
**Purpose**: Generate YAML frontmatter only
**Used in**: `-f, --frontmatter-only` mode
**Output**: YAML block with tags, type, status, etc.

These patterns must be installed in your `~/.config/fabric/patterns/` directory.

---

## Examples

### Daily Workflow

```bash
# Morning: process inbox
cd "$OBSVAULT/inbox"
for file in *.md; do
    obsidian-polish "$file" -r -y
done

# Quick capture from clipboard
alias quick='pbpaste | obsidian-polish -o "$OBSVAULT/inbox/$(date +%Y%m%d-%H%M%S).md"'
```

### Existing Vault Cleanup

```bash
# Add frontmatter to all notes without it
cd "$OBSVAULT"
for file in **/*.md; do
    # Only if no frontmatter exists
    if ! head -1 "$file" | grep -q "^---$"; then
        obsidian-polish "$file" -f --no-backup -y
    fi
done
```

### Integration with Other Tools

```bash
# With to_note
pbpaste | fabric-ai -p summarize -s | obsidian-polish -o summary.md

# With voice_note
voice_note | obsidian-polish -o "$OBSVAULT/voice/$(date +%Y%m%d-%H%M%S).md"

# Chain operations
pbpaste | fabric-ai -p extract_wisdom -s > temp.md
obsidian-polish temp.md -r -y
mv *.md "$OBSVAULT/insights/"
```

---

## Troubleshooting

### "fabric command not found"

Install Fabric:
```bash
pip install fabric-ai
# or
brew install fabric
```

### "Pattern not found"

Install custom patterns:
```bash
# Patterns location
ls ~/.config/fabric/patterns/obsidian_*

# If missing, copy from your patterns directory
cp -r patterns/obsidian_* ~/.config/fabric/patterns/
```

### Backup Files Everywhere

Create cleanup alias:
```bash
# Add to .zshrc or .bashrc
alias clean-obs-backups='find "$OBSVAULT" -name "*.md.bak" -delete'
```

### Title/Frontmatter Not Generated

Check pattern output:
```bash
# Test patterns directly
echo "test content" | fabric-ai -p obsidian_note_polish
echo "test content" | fabric-ai -p obsidian_note_title
echo "test content" | fabric-ai -p obsidian_frontmatter_gen
```

### File Won't Rename

Common causes:
- No title generated (using `-f` mode)
- Invalid characters in title (falls back to timestamp)
- Target file exists (needs confirmation without `-y`)
- Using `-o` or pipe mode (rename only works with in-place edit)

### Encoding Issues

The slugify function uses `iconv`:
```bash
# Test if available
which iconv

# If missing (unlikely), install:
# macOS: included by default
# Linux: apt-get install libc-bin
```

---

## Advanced Usage

### Shell Aliases

```bash
# Essential shortcuts
alias op='obsidian-polish'
alias opr='obsidian-polish -r -y'
alias opt='obsidian-polish -t --no-backup -y'

# Quick capture
alias ocap='pbpaste | obsidian-polish -o "$OBSVAULT/inbox/$(date +%Y%m%d-%H%M%S).md"'

# Process directory
alias op-inbox='for f in "$OBSVAULT/inbox"/*.md; do obsidian-polish "$f" -r -y; done'
```

### Custom Fabric Patterns

Modify patterns in `~/.config/fabric/patterns/` to customize:
- Tag generation logic
- Frontmatter fields
- Title style/formatting
- Language/tone

### Integration with Obsidian Templates

```bash
# Template + polish workflow
cat "$OBSVAULT/templates/meeting.md" > new-note.md
# Add your content to new-note.md
obsidian-polish new-note.md -r -y
```

### Automated Processing

```bash
# Watch directory for new files
fswatch -0 "$OBSVAULT/inbox" | xargs -0 -n1 -I{} obsidian-polish {} -r -y

# Cron job (every hour)
0 * * * * cd "$OBSVAULT/inbox" && for f in *.md; do obsidian-polish "$f" -r -y 2>&1 | logger; done
```

---

## Dependencies

- **bash** (standard on macOS/Linux)
- **fabric-ai** or **fabric** (AI pattern processing)
- **iconv** (character conversion - usually pre-installed)
- **pbcopy/xclip** (clipboard - optional, for pipe mode)

---

## Related Scripts

- **to_note**: Run commands and append output to notes
- **voice_note**: Voice-to-text → Obsidian
- **txrefine**: Transcript refinement with AI

---

**Location**: `~/.myscripts/obsidian-polish`  
**Documentation**: `~/.myscripts/docs/obsidian-polish.md`  
**Patterns**: `~/.config/fabric/patterns/obsidian_*`
