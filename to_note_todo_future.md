# to_note - Future Ideas

Ideas and patterns that emerged during documentation. Keep these **OUT** of main README to preserve simplicity.

---

## Specialized Aliases (Not Recommended for Main Docs)

```bash
# Fabric shortcuts - user creates if they want them
alias tn-wisdom='pbpaste | to_note "$OBSVAULT/ai/wisdom.md" fabric-ai -p extract_wisdom -s'
alias tn-summary='pbpaste | to_note "$OBSVAULT/ai/summaries.md" fabric-ai -p summarize -s'
alias tn-claims='pbpaste | to_note "$OBSVAULT/ai/analysis.md" fabric-ai -p analyze_claims -s'

# Location shortcuts
alias tn-debug='to_note "$OBSVAULT/debug/session-$(date +%F-%H%M).md"'
alias tn-ops='to_note "$OBSVAULT/ops/$(hostname).md"'
alias tn-learn='to_note "$OBSVAULT/learn/today.md"'

# Functions
tn-quick() { to_note "$OBSVAULT/scratch/$1.md" "${@:2}"; }
tn-fabric() { pbpaste | to_note "$OBSVAULT/ai/$1.md" fabric-ai -p "$1" -s; }
```

---

## Integration Patterns

### With obsidian-polish
```bash
tn "$OBSVAULT/projects/work.md" ...commands...
obsidian-polish "$OBSVAULT/projects/work.md"
```

### With OCR Workflows
```bash
tn "$OBSVAULT/ocr/tests.md" fabric-ai -a screenshot.png -p expert-ocr-engine -s
```

### With voice_note.sh
```bash
voice_note.sh  # Record hypothesis
tn "$OBSVAULT/debug/issue.md" psql -c "SELECT * FROM ..."
```

---

## Note Organization Strategies

### By Project
```
$OBSVAULT/projects/webapp/setup.md
$OBSVAULT/projects/api/queries.md
```

### By Date
```bash
tn "$OBSVAULT/daily/$(date +%F).md" <cmd>
```

### By Tool
```
$OBSVAULT/learn/jq.md
$OBSVAULT/learn/docker.md
```

### By Host
```bash
tn "$OBSVAULT/ops/$(hostname).md" <cmd>
```

---

## Search Patterns

### Obsidian Search
- `path:ops curl` - Find curl commands in ops/
- `path:debug error` - Find errors

### grep/ripgrep
```bash
grep -r "docker ps" "$OBSVAULT"
rg "npm (install|run|test)" "$OBSVAULT"
```

---

## Potential Enhancements

1. **Timing** - Show command execution duration
2. **Error-only mode** - Only log failed commands
3. **Session mode** - Start/stop captures multiple commands
4. **Diff mode** - Capture before/after file states

---

## Known Issue: Shell Quoting & Auto-completion

**Problem:** When using semicolon-separated commands, they must be quoted:
```bash
tn file.md 'cmd1 ; cmd2 ; cmd3'
```

This works correctly BUT causes issues:
- **Lost auto-completion** - Shell doesn't complete commands inside quotes
- **No alias expansion** - Aliases aren't expanded within quotes
- **No env var completion** - Can't tab-complete `$OBSVAULT` etc.

**Current workaround:** Single commands don't need quotes, work fine:
```bash
tn file.md echo "hello"          # Auto-completion works
tn file.md pbpaste | fabric -s   # Auto-completion works
```

**Future investigation:**
- Shell configuration to enable completion inside quotes?
- Alternative command separator that doesn't need quoting?
- Wrapper function that handles the quoting automatically?
- Custom completion script for `tn` command?

**Note:** This is a shell behavior limitation, not a `to_note` bug. The tool works correctly; it's the typing UX that could be improved via shell configuration.

---

## Comparison Notes

| Tool | Auto | Curated | Live | Markdown |
|------|------|---------|------|----------|
| to_note | No | Yes | Yes | Yes |
| bash history | Yes | No | No | No |
| script | Yes | No | Yes | No |
| Atuin | Yes | No | No | No |

---

**Note:** All of this is EXTRA. The tool is complete and simple as-is.
