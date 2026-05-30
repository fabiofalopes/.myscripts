# slugfile - Quick Reference

**Cheat sheet for daily usage**

---

## Common Commands

### Quick Actions
```bash
# Just slugify
slugfile note.md

# Add date
slugfile -d note.md

# Add tags
slugfile -t note.md

# Date + tags (most common)
slugfile -d -t note.md

# Polish + date + tags
slugfile -p note.md
```

### Batch Operations
```bash
# Preview first (IMPORTANT!)
slugfile -n *.md

# Execute
slugfile *.md

# Recursive folder
slugfile -d -t -r ./inbox/

# Polish entire folder
slugfile -p -r ./inbox/
```

### Tag Management
```bash
# Limit tags in filename
slugfile -t note.md --max-tags 2

# Skip noise tags
slugfile -t note.md -k "untitled,draft"

# Both combined
slugfile -t note.md --max-tags 3 -k "untitled,draft,todo"
```

### Collision Handling
```bash
# Auto-increment (safe)
slugfile *.md --collision increment

# Ask for each collision
slugfile *.md --collision ask

# Force overwrite (DANGER!)
slugfile *.md --collision overwrite
```

---

## My Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Basic
alias sf='slugfile'
alias sfn='slugfile -n'

# Common workflows
alias sfd='slugfile -d -t'
alias sfp='slugfile -p'

# Safe batch
alias sfi='slugfile -d -t -r --collision increment'

# Inbox cleanup
alias inbox-clean='slugfile -d -t -r ~/Documents/obsidian_vault/inbox/ --collision increment'
```

---

## Tag Formats Supported

```yaml
# Array
tags: [tag1, tag2, tag3]

# Inline
tags: tag1, tag2, tag3

# List
tags:
  - tag1
  - tag2
  - tag3

# In content
#tag1 #tag2 #tag3
```

---

## My Workflow

### 1. Quick Note
```bash
# Created as Untitled.md
slugfile -d -t "Untitled.md"
# Result: 2026-04-22-my-note-tags.md
```

### 2. Clean Inbox
```bash
cd ~/Documents/obsidian_vault/inbox/
slugfile -n *.md                    # Preview
slugfile -d -t *.md                 # Execute
```

### 3. Polish and Organize
```bash
# Quick notes without metadata
slugfile -p -r ./quick-notes/
# obsidian-polish adds title/tags, then slugify with date
```

### 4. Archive
```bash
# Add specific date (e.g., when note was written)
slugfile -d "2026-01-15" old-note.md
```

---

## Safety First

```bash
# ALWAYS dry-run first
slugfile -n *.md

# Then execute
slugfile *.md

# Use increment for batches (safer than skip)
slugfile -r ./folder/ --collision increment
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Command not found | `npm install -g @sindresorhus/slugify-cli` |
| Tags not extracted | Check YAML format, needs `---` delimiters |
| Polish fails | Check `obsidian-polish` is in PATH |
| Filename too long | Use `--max-tags 2` |

---

## File: Location

- **Script:** `~/.myscripts/slugfile`
- **Backup:** `~/.myscripts/slugfile.backup-YYYYMMDD-HHMMSS`
- **Docs:** `~/.myscripts/SLUGFILE_ENHANCED.md`
- **Tests:** `~/.myscripts/test-slugfile.sh`

---

## Version

**v2.0** - Enhanced with Obsidian features

- Date prefixes
- Tag extraction
- Polish mode
- Smart collision handling
- Tag filtering

---

**Tip:** Create an alias for your most common workflow!
