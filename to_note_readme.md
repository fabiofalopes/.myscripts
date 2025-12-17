# to_note

Prefix any command with `to_note <file>` to run it normally AND append command + output to your note.

---

## Quick Start

```bash
export OBSVAULT="/path/to/your/ObsidianVault"
alias tn='to_note'

tn "$OBSVAULT/scratch.md" echo "Hello world"
```

---

## What It Does

- Runs your command normally (live terminal output)
- Appends the command itself + output to the specified file
- Timestamps each entry
- Never overwrites (append-only)

---

## Examples

```bash
# Basic
tn "$OBSVAULT/scratch.md" date
tn "$OBSVAULT/notes.md" uname -a

# Multiple commands (semicolon separated)
tn "$OBSVAULT/session.md" echo "Step 1" ; echo "Step 2" ; date

# Piped commands
tn "$OBSVAULT/network.md" netstat -an | grep LISTEN

# With Fabric
pbpaste | tn "$OBSVAULT/insights.md" fabric-ai -p summarize -s
cat article.txt | tn "$OBSVAULT/notes.md" fabric-ai -p extract_wisdom -s

# Debug session
NOTE="$OBSVAULT/debug/issue.md"
tn $NOTE docker logs webapp
tn $NOTE curl -v http://localhost:8080
```

---

## Output Format

Each command produces:

```markdown
### 2025-12-17 14:30:45

```bash
$ echo "test"
test
```

----
```

Entries keep appending to the same file.

---

## Streaming Commands

Commands that stream (like `fabric-ai -s`) work naturally—you see output in real-time while it saves to your note.

```bash
pbpaste | tn "$OBSVAULT/ai.md" fabric-ai -p summarize -s
```

---

## Aliases

```bash
# Essential
alias tn='to_note'

# Optional: quick scratch note
alias tn-scratch='to_note "$OBSVAULT/scratch.md"'
```

---

## Gotchas

```bash
# Interactive commands won't work
tn note.md vim file.txt    # Hangs - use cat instead
tn note.md less log.txt    # Hangs - use head/tail instead

# Variables expand before logging
tn note.md echo $HOME      # Logs: $ echo /Users/you
tn note.md echo '$HOME'    # Logs: $ echo $HOME

# Failed commands are logged (this is a feature)
tn note.md curl https://bad-url.com  # Error captured
```

---

## Setup

```bash
# 1. Make executable
chmod +x ~/.myscripts/to_note

# 2. Add to PATH
export PATH="$PATH:$HOME/.myscripts"

# 3. Set vault
export OBSVAULT="/path/to/your/ObsidianVault"

# 4. Create alias
alias tn='to_note'

# 5. Test
tn "$OBSVAULT/test.md" echo "It works!"
```

---

## Troubleshooting

**"OBSVAULT not set"** - Add `export OBSVAULT=...` to your shell config

**"Permission denied"** - Run `chmod +x ~/.myscripts/to_note`

**"Command not found"** - Add `.myscripts` to your PATH

**Notes not in Obsidian** - Check path is inside `$OBSVAULT`

---

**That's it.** A prefix for any command that logs to your notes.
