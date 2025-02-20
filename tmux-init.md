# Tmux Session Management Guide

## Current Setup Files
- `~/.tmux.conf` - Main configuration file
- `~/.myscripts/tmux-init.sh` - Session initialization script
- `~/.tmux/hooks/restore-env.sh` - Environment restoration hook
- `~/.bashrc` - Bash integration (auto-start tmux)

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

## Environment Management
The setup automatically handles:
- Virtualenv detection and activation
- Bashrc sourcing in all panes
- Environment variable persistence

### Virtualenv Detection Logic
1. Checks for `.venv/bin/activate` in current directory
2. Checks parent directory if not found
3. Falls back to normal bashrc sourcing if no virtualenv found

## Maintenance

### Modifying Session Layout
To modify the default session layout:
1. Edit `~/.myscripts/tmux-init.sh`
2. Kill existing session to test changes: `tmux kill-session -t main`
3. Start new terminal to trigger automatic session creation

### Updating Configuration
After making changes to any config file:
```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Force save current state
<prefix> + Ctrl-s
```

### Plugin Management
Update all plugins:
```bash
<prefix> + U
```

## Troubleshooting

| Symptom                      | Solution                          |
|------------------------------|-----------------------------------|
| Missing environments         | Check `restore-env.sh` permissions: `chmod +x ~/.tmux/hooks/*.sh` |
| Layout not restoring         | Kill session and restart: `tmux kill-session -t main` |
| Virtualenv not activating    | Verify `.venv/bin/activate` exists in project directory |
| Panes not responding         | Detach and reattach to session    |
| Session not auto-starting    | Check `.bashrc` tmux section      |

## Best Practices
1. **Version Control**  
   Keep your tmux configuration under version control:
   ```bash
   git init ~/tmux-config
   cp ~/.tmux.conf ~/tmux-config/
   cp -r ~/.tmux/hooks ~/tmux-config/
   cp ~/.myscripts/tmux-* ~/tmux-config/
   ```

2. **Regular Backups**  
   Maintain regular backups of your tmux state:
   ```bash
   # Manual backup
   cp ~/.tmux/resurrect/last ~/.tmux/resurrect/last.backup
   ```

3. **Testing Changes**  
   Always test changes in a temporary session:
   ```bash
   tmux new -t test-session
   ```

4. **Documentation Updates**  
   Update this document whenever making significant changes to the setup.

## Future Improvements
- Add more project-specific windows as needed
- Implement custom key bindings for frequent tasks
- Create session templates for different workflows
- Add health checks for environment restoration

Remember: The session will persist as you left it due to the continuum plugin. Only kill the session if you want to reset to the default layout.

