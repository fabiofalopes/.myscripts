# Tmux Session Management Guide

## Current Setup Files
- `~/.tmux.conf` - Main configuration file
- `~/.myscripts/tmux-init.sh` - Session initialization script

## Basic Session Commands
```bash
# List all sessions
tmux ls

# Attach to existing session
tmux attach -t main

# Kill session (if you need to reset everything)
tmux kill-session -t main
```

## Current Session Layout
1. Window 1 ('system'): Three-pane layout
   - Left: neofetch
   - Top-right: htop
   - Bottom-right: system monitoring stats

2. Window 2 ('voice-note'):
   - Directory: ~/projetos/hub/voice_note/
   - Auto-activates Python virtual environment

3. Window 3 ('projetos'):
   - Directory: ~/projetos/

## Default Key Bindings
(Using `C-a` as prefix)

### Session Management
- `C-a d` - Detach from session
- `C-a s` - List sessions
- `C-a $` - Rename session

### Window Management
- `C-a c` - Create new window
- `C-a ,` - Rename window
- `C-a n` - Next window
- `C-a p` - Previous window
- `C-a w` - List windows
- `C-a &` - Kill window

### Pane Management
- `C-a %` - Split pane vertically
- `C-a "` - Split pane horizontally
- `C-a o` - Switch to next pane
- `C-a q` - Show pane numbers
- `C-a x` - Kill pane
- `C-a z` - Toggle pane zoom

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

