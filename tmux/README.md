# Personal Tmux Configuration

## Directory Structure
- `~/.myscripts/tmux/` - Main configuration directory
  - `init.sh` - Main session initialization script
  - `tmux.conf` -> `~/.tmux.conf` - Tmux configuration file
- `~/.tmux/` - Tmux plugin directory (managed by TPM)
  - `plugins/` - Contains installed plugins
  - `resurrect/` - Session backup data

## Session: main
The default session contains:
1. System monitoring (window 1)
   - neofetch
   - htop
   - system stats
2. Voice Note project (window 2)
   - Automatically loads existing venv if present
3. Config directories (window 3)
   - Four-way split for different config locations

## Plugin Management
- TPM (Tmux Plugin Manager) handles plugins
- Plugins are defined in tmux.conf
- Install plugins: `prefix + I`
- Update plugins: `prefix + U`

## Session Management
- Sessions auto-restore after reboot (tmux-resurrect)
- Save session: `prefix + Ctrl-s`
- Restore session: `prefix + Ctrl-r`

## Common Issues
1. After reboot:
   - Environment might need reinitialization
   - Solution: Detach and reattach or restart session
2. Virtual environments:
   - Only sources existing venvs, never creates them
   - Located in project directories as `.venv`
