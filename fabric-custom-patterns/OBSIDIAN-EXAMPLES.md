# Obsidian Polish - Usage Examples

## 🎯 In-Place File Editing (NEW!)

### Example 1: Basic In-Place Edit
The most common use case - edit a file directly:

```bash
$ obsidian-polish meeting-notes.md

╔════════════════════════════════════════╗
║   Obsidian Note Polish Workflow      ║
╚════════════════════════════════════════╝

▶ Reading from file: meeting-notes.md
✓ Captured 441 characters
✓ Generated title and frontmatter
✓ Backup created: meeting-notes.md.bak
✓ File updated: meeting-notes.md

✨ Workflow complete!
```

**Result**: File is enhanced with frontmatter + title. Original saved as `.bak`

---

### Example 2: Quick Edit (No Prompts, No Backup)

For trusted workflows where you want speed:

```bash
obsidian-polish draft.md --no-backup -y
```

- `--no-backup`: Don't create `.bak` file
- `-y`: Skip all confirmation prompts

---

### Example 3: Replace Existing Frontmatter

If file already has frontmatter:

```bash
$ obsidian-polish note.md

⚠ Note already has frontmatter
Replace existing frontmatter? [y/N]: y

✓ Backup created: note.md.bak
✓ File updated: note.md
```

The script detects existing frontmatter and asks for confirmation (unless `-y` flag is used).

---

### Example 4: Save to Different File

Preserve original, create enhanced version:

```bash
obsidian-polish draft.md -o final.md
```

**Result:**
- `draft.md` - unchanged
- `final.md` - new file with frontmatter + title

---

## 📋 Pipe Mode (Preview Before Applying)

### Example 5: From Clipboard (macOS)

Review the AI suggestions before applying:

```bash
# 1. Copy note content in Obsidian (Cmd+A, Cmd+C)

# 2. Run polish
pbpaste | obsidian-polish

# 3. Output shown + copied to clipboard
# 4. Review, then paste back (Cmd+V)
```

---

### Example 6: From Clipboard (Linux)

```bash
xclip -o | obsidian-polish
```

---

### Example 7: From File via Pipe

```bash
cat my-notes.md | obsidian-polish
```

Output goes to stdout and clipboard for review.

---

## 🎨 Mode Selection

### Example 8: Title Only

Just generate a title, no frontmatter:

```bash
obsidian-polish note.md -t

# Output:
---
title: OAuth2 Authentication Implementation Plan
---

# OAuth2 Authentication Implementation Plan

[original content...]
```

---

### Example 9: Frontmatter Only

Just generate frontmatter, no title change:

```bash
obsidian-polish note.md -f

# Output:
---
title: OAuth2 Authentication Implementation Plan
aliases:
  - OAuth2 meeting
tags:
  - authentication
  - oauth2
created: 2024-12-07
type: meeting
status: active
summary: Dev team meeting on OAuth2 implementation.
---

[original content unchanged...]
```

---

## 🔄 Real-World Workflows

### Workflow 1: New Note Creation

```bash
# 1. Write note in Obsidian
# 2. Save file
# 3. Run enhancement

obsidian-polish ~/Documents/vault/inbox/new-note.md -y

# Done! Note has proper metadata
```

---

### Workflow 2: Batch Processing

Process multiple notes at once:

```bash
#!/bin/bash
# enhance-all.sh

for note in ~/Documents/vault/inbox/*.md; do
    echo "Processing: $note"
    obsidian-polish "$note" -y --no-backup
done
```

---

### Workflow 3: Safe Review Workflow

When you want to be cautious:

```bash
# 1. Test first with pipe mode
cat note.md | obsidian-polish

# 2. Review output

# 3. If good, apply to file
obsidian-polish note.md
```

---

### Workflow 4: Daily Note Template

Create a script for daily notes:

```bash
#!/bin/bash
# daily-note-polish.sh

VAULT="$HOME/Documents/vault"
TODAY=$(date +%Y-%m-%d)
NOTE="$VAULT/daily/$TODAY.md"

if [ -f "$NOTE" ]; then
    obsidian-polish "$NOTE" -y --no-backup
    echo "✓ Enhanced daily note: $TODAY"
else
    echo "✗ Daily note not found: $NOTE"
fi
```

---

## 🔧 Advanced Usage

### Example 10: With Specific Model

Use a specific AI model:

```bash
cat note.md | fabric-ai -p obsidian_note_polish -m claude-opus-20240229
```

---

### Example 11: Streaming Output

Watch AI generate in real-time:

```bash
cat note.md | fabric-ai -p obsidian_note_polish --stream
```

---

### Example 12: Chain with Other Patterns

Extract key points first, then enhance:

```bash
cat meeting-transcript.txt | \
  fabric-ai -p extract_wisdom | \
  tee refined-notes.md | \
  obsidian-polish refined-notes.md -y
```

---

## 📊 Before/After Examples

### Before:
```markdown
Had meeting about dark mode. CSS variables. Sarah does colors. Mike does toggle. Test by Friday. Check contrast.
```

### After:
```markdown
---
title: Dark Mode Implementation Meeting
aliases:
  - dark mode meeting
  - theme implementation
tags:
  - design
  - frontend
  - css
  - meeting-notes
created: 2024-12-07
type: meeting
status: active
summary: Team meeting on dark mode implementation using CSS variables with task assignments.
---

# Dark Mode Implementation Meeting

Had meeting about dark mode. CSS variables. Sarah does colors. Mike does toggle. Test by Friday. Check contrast.
```

---

## 🛡️ Safety Features

### Automatic Backups

By default, original file is saved:

```bash
obsidian-polish note.md

# Creates:
# - note.md        (enhanced)
# - note.md.bak    (original)
```

To restore:
```bash
mv note.md.bak note.md
```

---

### Confirmation Prompts

Script asks before replacing existing frontmatter:

```bash
obsidian-polish note.md

⚠ Note already has frontmatter
Replace existing frontmatter? [y/N]:
```

Skip with `-y` flag:
```bash
obsidian-polish note.md -y
```

---

## 🐛 Troubleshooting Examples

### Issue: Pattern Not Found

```bash
$ obsidian-polish note.md
Error: Pattern 'obsidian_note_polish' not found

# Solution: Copy patterns to fabric
cp -r ~/projetos/hub/.myscripts/fabric-custom-patterns/obsidian_* \
     ~/.config/fabric/patterns/
```

---

### Issue: Empty Output

```bash
$ cat note.md | obsidian-polish
✗ Empty input received

# Solution: Check file has content
cat note.md  # Verify content exists
```

---

### Issue: Permission Denied

```bash
$ ./obsidian-polish note.md
bash: ./obsidian-polish: Permission denied

# Solution: Make executable
chmod +x ~/projetos/hub/.myscripts/obsidian-polish
```

---

## 💡 Tips & Tricks

### Tip 1: Add to PATH

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="$HOME/projetos/hub/.myscripts:$PATH"

# Then use anywhere:
obsidian-polish note.md
```

---

### Tip 2: Create Alias

```bash
# Add to shell config
alias op='obsidian-polish'
alias opp='obsidian-polish --no-backup -y'

# Quick usage:
op note.md           # With prompts
opp note.md          # Fast, no prompts
```

---

### Tip 3: Keyboard Shortcut (macOS)

Create Automator Quick Action:

1. Open Automator → New → Quick Action
2. Add "Run Shell Script"
3. Script: `obsidian-polish "$1" -y`
4. Save as "Polish Obsidian Note"
5. Assign keyboard shortcut in System Preferences

---

### Tip 4: Obsidian Hotkey (via Templater)

Install Templater plugin, create template:

```javascript
<%*
const file = tp.file.path(true);
await tp.user.system(`obsidian-polish "${file}" -y`);
await tp.file.reload();
%>
```

Assign hotkey in Templater settings.

---

## 📈 Performance Notes

| Mode | Speed | Use Case |
|------|-------|----------|
| Title only (`-t`) | Fastest | Quick titling |
| Frontmatter only (`-f`) | Fast | Metadata only |
| Combined (default) | Medium | Full enhancement |
| Pipe mode | Same | Preview first |

---

## 🎯 Best Practices

1. **Use `-y` flag for trusted workflows** - Skip prompts
2. **Keep backups for important notes** - Don't use `--no-backup`
3. **Review output in pipe mode first** - Test with new patterns
4. **Batch process carefully** - Verify first file before loop
5. **Check frontmatter before re-running** - Avoid duplicates

---

## 📚 Related Patterns

Use these fabric patterns directly if you need just the data:

```bash
# Get just the title
cat note.md | fabric-ai -p obsidian_note_title

# Get just the frontmatter
cat note.md | fabric-ai -p obsidian_frontmatter_gen

# Get both formatted
cat note.md | fabric-ai -p obsidian_note_polish
```

---

**Quick Help**: `obsidian-polish -h`
