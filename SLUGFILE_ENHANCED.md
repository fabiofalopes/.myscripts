# Enhanced slugfile - Obsidian-Friendly Filename Management

**Version:** 2.0
**Date:** 2026-04-22
**Author:** Enhanced with Obsidian workflow integration

---

## Overview

`slugfile` is a bash script that renames files to clean, slugified names with Obsidian-specific features including date prefixes, tag extraction, and integration with `obsidian-polish`.

**What's new in v2.0:**
- ✅ Date prefix support (`-d` flag)
- ✅ Tag extraction from frontmatter and inline tags (`-t` flag)
- ✅ Polish mode integration (`-p` flag)
- ✅ Smart collision handling (increment, ask, skip, overwrite)
- ✅ Tag filtering and limits
- ✅ Full backward compatibility with v1.x

---

## Installation

```bash
# Already installed if you have .myscripts repository
# Just ensure it's in your PATH

# Verify installation
which slugfile

# Check version
slugfile --help
```

**Dependencies:**
- `slugify` command from npm: `npm install -g @sindresorhus/slugify-cli`
- (Optional) `obsidian-polish` for polish mode

---

## Quick Start

### Basic Usage (Backward Compatible)

```bash
# Simple slugification
slugfile "My Document (Final).md"
# Result: my-document-final.md

# Multiple files
slugfile *.md

# Recursive
slugfile -r ./messy-folder/

# Dry run (preview)
slugfile -n *.md
```

### Date Prefixes

```bash
# Add today's date
slugfile -d note.md
# Result: 2026-04-22-note.md

# Specific date
slugfile -d "2026-01-15" note.md
# Result: 2026-01-15-note.md

# Combine with slugification
slugfile -d "My Document.md"
# Result: 2026-04-22-my-document.md
```

### Tag Extraction

```bash
# Extract tags from frontmatter
slugfile -t note.md
# Result: note-tag1-tag2-tag3.md

# Combine date and tags
slugfile -d -t note.md
# Result: 2026-04-22-note-tag1-tag2.md

# Limit number of tags
slugfile -t note.md --max-tags 2
# Result: note-tag1-tag2.md (only first 2 tags)

# Skip certain tags
slugfile -t note.md -k "untitled,draft"
# Result: note.md (untitled and draft excluded)
```

### Polish Mode

```bash
# Run obsidian-polish first, then slugify with date+tags
slugfile -p note.md
# Process:
#   1. obsidian-polish generates title and frontmatter
#   2. Extract tags from generated frontmatter
#   3. Add date prefix
#   4. Slugify everything
# Result: 2026-04-22-generated-title-tags.md

# Batch polish entire folder
slugfile -p -r ./inbox/
```

---

## Flag Reference

### Basic Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-h, --help` | Show help | `slugfile --help` |
| `-n, --dry-run` | Preview without renaming | `slugfile -n *.md` |
| `-r, --recursive` | Process directories recursively | `slugfile -r ./notes/` |
| `-f, --force` | Overwrite existing files | `slugfile -f note.md` |
| `-e, --ext EXT` | Change extension | `slugfile -e txt note.md` |

### Obsidian Flags

| Flag | Description | Example |
|------|-------------|---------|
| `-d, --date [DATE]` | Add date prefix | `slugfile -d note.md` |
| `-t, --tags` | Extract tags from content | `slugfile -t note.md` |
| `-p, --polish` | Run obsidian-polish first | `slugfile -p note.md` |
| `-k, --skip-tags` | Skip certain tags | `slugfile -t note.md -k "untitled"` |
| `--max-tags N` | Max tags in filename | `slugfile -t note.md --max-tags 3` |

### Advanced Flags

| Flag | Description | Example |
|------|-------------|---------|
| `--collision MODE` | Collision handling | `slugfile --collision increment note.md` |

**Collision modes:**
- `skip` - Skip if target exists (default)
- `increment` - Add numeric suffix (note-2.md)
- `ask` - Prompt user what to do
- `overwrite` - Overwrite existing file

---

## Tag Extraction

### YAML Frontmatter

```yaml
---
tags: [obsidian, workflow, tools]
---

# My Document
```

Result: `my-document-obsidian-workflow-tools.md`

### Inline Tags

```markdown
# My Document

This has #inline tags in the content.
More #tags here.
```

Result: `my-document-inline-tags-more-tags.md`

### Tag Formats Supported

1. **Array format:** `tags: [tag1, tag2, tag3]`
2. **Inline format:** `tags: tag1, tag2, tag3`
3. **List format:**
   ```yaml
   tags:
     - tag1
     - tag2
     - tag3
   ```
4. **Inline in content:** `#tag1 #tag2 #tag3`

---

## Common Workflows

### Workflow 1: Quick Note Organization

```bash
# Single note
slugfile -d -t "Untitled.md"

# Entire folder
slugfile -d -t -r ./inbox/
```

### Workflow 2: Clean Up Messy Files

```bash
# Preview first
slugfile -n *.md

# Execute
slugfile *.md
```

### Workflow 3: Polish and Organize

```bash
# Single file
slugfile -p note.md

# Batch processing
slugfile -p -r ./inbox/
```

### Workflow 4: Archive with Dates

```bash
# Add date prefix to archive
slugfile -d "2026-01-15" -r ./2026-archive/

# Or use file's modification date (example)
find ./old-notes/ -name "*.md" -exec slugfile -d $(date -r {} +%Y-%m-%d) {} \;
```

### Workflow 5: Filter Noise Tags

```bash
# Skip common noise tags
slugfile -t -r ./notes/ -k "untitled,draft,todo"
```

---

## Aliases and Shortcuts

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Quick slugify
alias sf='slugfile'

# Quick date+tags
alias sfd='slugfile -d -t'

# Quick polish
alias sfp='slugfile -p'

# Batch organize inbox
alias inbox-clean='slugfile -d -t -r ~/Documents/obsidian_vault/inbox/'

# Dry run alias
alias sfn='slugfile -n'
```

---

## Integration with Obsidian

### Option 1: Shell Integration

Use Obsidian's terminal plugin to run `slugfile` from within Obsidian:

```bash
# In Obsidian terminal
slugfile -d -t "%{filepath}"
```

### Option 2: Hotkey Plugin

Map a hotkey to run `slugfile` on the current file (requires shell command plugin).

### Option 3: Obsidian Local REST API

Create a script that uses Obsidian's API to get the current file and run `slugfile`:

```bash
#!/bin/bash
# slugfile-current.sh - Rename current Obsidian file

FILE=$(curl -s http://localhost:27124/active | jq -r '.file')
slugfile -d -t "$FILE"
```

---

## Examples

### Example 1: Single File with Tags

**Input file:** `My Meeting Notes.md`

```markdown
---
tags: [meeting, work, project-x]
---
# Meeting Notes

Discussed project X timeline.
```

**Command:**
```bash
slugfile -d -t "My Meeting Notes.md"
```

**Result:** `2026-04-22-my-meeting-notes-meeting-work-project-x.md`

### Example 2: Batch Process Inbox

**Input:** Folder with messy filenames
```
inbox/
  ├── Untitled 1.md
  ├── Untitled 2.md
  └── Random Notes.md
```

**Command:**
```bash
slugfile -p -r ./inbox/
```

**Result:**
```
inbox/
  ├── 2026-04-22-discussion-topics.md
  ├── 2026-04-22-quick-thoughts.md
  └── 2026-04-22-random-notes.md
```

### Example 3: Tag Filtering

**Input file:** `draft-untitled-note.md`

```markdown
---
tags: [untitled, draft, important, urgent]
---
# Important Note
```

**Command:**
```bash
slugfile -t "draft-untitled-note.md" -k "untitled,draft" --max-tags 2
```

**Result:** `draft-untitled-note-important-urgent.md`

---

## Testing

Run the test suite:

```bash
cd /Users/fabiofalopes/projetos/hub/.myscripts
bash test-slugfile.sh
```

This will:
- Create a temporary test directory
- Run all feature tests
- Clean up automatically

---

## Troubleshooting

### Issue: "slugify command not found"

**Solution:**
```bash
npm install -g @sindresorhus/slugify-cli
```

### Issue: Tags not being extracted

**Check:**
1. File has YAML frontmatter with `---` delimiters
2. Tags are in one of the supported formats
3. File is readable

### Issue: Date format wrong

**Check:**
- Custom dates must be `YYYY-MM-DD` format
- If no date specified, uses current date

### Issue: obsidian-polish not working

**Check:**
1. `obsidian-polish` is in your PATH
2. Run `obsidian-polish --help` to verify
3. If not found, slugfile will skip polish step (with warning)

---

## Performance

| Operation | Files | Time |
|-----------|-------|------|
| Basic slugify | 100 | ~2s |
| With tags | 100 | ~5s |
| With polish | 10 | ~15s |

**Note:** Polish mode is slower because it runs Fabric AI for each file. Use `-p` judiciously.

---

## Backward Compatibility

All v1.x flags work exactly as before:

```bash
slugfile document.md                    # ✓ Still works
slugfile -n *.md                        # ✓ Still works
slugfile -r ./folder/                   # ✓ Still works
slugfile -f document.md                 # ✓ Still works
```

New flags are additive, not breaking.

---

## Future Enhancements

Potential future features:
- [ ] Integration with Obsidian Local REST API
- [ ] Automatic tag suggestion based on content
- [ ] Config file for default settings
- [ ] Parallel processing for large batches
- [ ] Zsh completion for flags
- [ ] GUI wrapper

---

## Changelog

### v2.0 (2026-04-22)
- ✅ Added date prefix support (`-d` flag)
- ✅ Added tag extraction (`-t` flag)
- ✅ Added polish mode (`-p` flag)
- ✅ Added collision handling strategies
- ✅ Added tag filtering and limits
- ✅ Full backward compatibility

### v1.0 (Previous)
- Basic slugification
- Recursive mode
- Dry run
- Extension changing

---

## Contributing

This script is part of the `.myscripts` repository. To contribute:

1. Test changes with `test-slugfile.sh`
2. Update this documentation
3. Create backup before modifying
4. Test with real files (use `--dry-run` first!)

---

## License

Part of personal scripts repository. Use freely.

---

**Remember:** Always use `--dry-run` first when testing with important files!

**Questions?** Check the test suite or run `slugfile --help`.
