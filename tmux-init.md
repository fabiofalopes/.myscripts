# Tmux Session Management Guide

## Current Setup Files
- `~/.tmux.conf` - Main configuration file
- `~/.myscripts/tmux-init.sh` - Session initialization script

## Basic Session Commands
```bash
# List all sessions
tmux ls

# Attach to existing session (two equivalent methods)
tmux a -t main
tmux attach -t main

# Detach current session
# Using key binding: Ctrl-b d

# Kill session (if you need to reset everything)
tmux kill-session -t main
```

## Default Key Bindings
(Using `C-b` as prefix)

### Session Management
- `C-b d` - Detach from session
- `C-b s` - List sessions
- `C-b $` - Rename session

### Window Management
- `C-b c` - Create new window
- `C-b ,` - Rename window
- `C-b n` - Next window
- `C-b p` - Previous window
- `C-b w` - List windows
- `C-b &` - Kill window

### Pane Management
- `C-b %` - Split pane vertically
- `C-b "` - Split pane horizontally
- `C-b o` - Switch to next pane
- `C-b q` - Show pane numbers
- `C-b x` - Kill pane
- `C-b z` - Toggle pane zoom

## Plugin Features
- Session persistence across reboots (tmux-resurrect, tmux-continuum)
- Auto-save every 15 minutes
- Auto-restore on tmux start

## Maintenance
To modify the default session layout:
1. Edit `~/.myscripts/tmux-init.sh`
2. Kill existing session to test changes: `tmux kill-session -t main`
3. Start new terminal to trigger automatic session creation

Remember: The session will persist as you left it due to the continuum plugin. Only kill the session if you want to reset to the default layout.

