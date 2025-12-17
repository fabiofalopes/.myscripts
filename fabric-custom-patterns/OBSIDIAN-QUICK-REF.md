# Obsidian Workflow - Quick Reference

## 🚀 One-Time Setup

```bash
# 1. Copy patterns to fabric
cd /Users/fabiofalopes/projetos/hub/.myscripts/fabric-custom-patterns
cp -r obsidian_* ~/.config/fabric/patterns/

# 2. Verify
fabric -l | grep obsidian

# 3. Add script to PATH (optional)
echo 'export PATH="$HOME/projetos/hub/.myscripts:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 💡 Quick Usage

### 🎯 In-Place File Editing (BEST)
```bash
obsidian-polish note.md              # Edits file directly (creates .bak)
obsidian-polish note.md --no-backup  # Edit without backup
obsidian-polish note.md -y           # Skip confirmation
```

### 📋 From Clipboard (Preview First)
```bash
pbpaste | obsidian-polish        # macOS
xclip -o | obsidian-polish       # Linux
```

### 📄 Save to Different File
```bash
obsidian-polish note.md -o enhanced.md
```

## 🎯 Three Modes

| Mode | Command | Output |
|------|---------|--------|
| **Combined** (default) | `obsidian-polish` | Title + Frontmatter |
| **Title Only** | `obsidian-polish -t` | Just title |
| **Frontmatter Only** | `obsidian-polish -f` | Just YAML |

## 📝 Direct Pattern Usage

```bash
# Title only (fastest)
cat note.md | fabric -p obsidian_note_title

# Frontmatter only
cat note.md | fabric -p obsidian_frontmatter_gen

# Combined
cat note.md | fabric -p obsidian_note_polish
```

## 🔄 Typical Workflows

### Workflow 1: Direct File Edit (FASTEST)
```
1. Save note in Obsidian
   ↓
2. Terminal: obsidian-polish /path/to/note.md -y
   ↓
3. Done! File is updated with frontmatter + title
```

### Workflow 2: Review First (SAFEST)
```
1. Copy note content (Cmd+A, Cmd+C)
   ↓
2. Terminal: pbpaste | obsidian-polish
   ↓
3. Review output
   ↓
4. Paste back to Obsidian (Cmd+V)
```

## 📦 What Gets Generated

### Title Example
```
Dark Mode Implementation Plan
```

### Frontmatter Example
```yaml
---
title: Dark Mode Implementation Plan
aliases:
  - dark mode
  - theme system
tags:
  - design
  - frontend
  - ui
created: 2024-12-07
type: project
status: active
summary: Plan for implementing dark mode with CSS variables and accessibility testing.
---
```

## 🎨 Frontmatter Properties

| Property | Values | Example |
|----------|--------|---------|
| **type** | idea, reference, project, meeting, journal, article, snippet, log | `type: project` |
| **status** | draft, active, review, archived, permanent | `status: active` |
| **tags** | 2-5 lowercase tags | `- authentication` |
| **created** | YYYY-MM-DD | `2024-12-07` |

## ⚙️ Options

```bash
obsidian-polish note.md           # Edit in-place (creates .bak)
  -o, --output FILE               # Save to different file
  --no-backup                     # Don't create backup
  -y, --yes                       # Skip confirmation
  -t, --title-only                # Generate only title
  -f, --frontmatter-only          # Generate only frontmatter
  -h, --help                      # Show help
```

## 🐛 Troubleshooting

### Pattern not found
```bash
ls ~/.config/fabric/patterns/ | grep obsidian
# If empty, re-copy patterns
```

### Script not executable
```bash
chmod +x ~/projetos/hub/.myscripts/obsidian-polish
```

### Fabric not found
```bash
brew install fabric           # macOS
which fabric-ai               # Check if fabric-ai instead
```

## 📚 Documentation

- **Full Guide**: `OBSIDIAN-WORKFLOW.md`
- **Setup Details**: `OBSIDIAN-SETUP-SUMMARY.md`
- **Pattern Catalog**: `README.md`

## 🔗 Files

- **Patterns**: `~/.config/fabric/patterns/obsidian_*`
- **Script**: `~/projetos/hub/.myscripts/obsidian-polish`
- **Docs**: `~/projetos/hub/.myscripts/fabric-custom-patterns/OBSIDIAN-*.md`

---

**Quick Help**: `obsidian-polish -h`
