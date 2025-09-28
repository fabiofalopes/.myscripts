# Portable tmux Configuration

Cross-platform tmux setup with session persistence and clean styling. No bullshit, just works.

## Philosophy

- **Portable**: Same config works on macOS and Linux
- **Non-invasive**: Symlinks files, doesn't mess with your home directory
- **Persistent**: Sessions survive reboots
- **Clean**: Minimal, tasteful green/gray color scheme

## Quick Start

```bash
# 1. Link configuration files
bash scripts/link.sh

# 2. Install plugins (start tmux first)
tmux
# Then press: Ctrl-b + I

# 3. Done
```

## What You Get

- **Window switching**: `Ctrl-b + 1/2/3/4` switches windows
- **Mouse support**: Click, drag, scroll all work
- **Session persistence**: Sessions restore after reboot
- **Clean colors**: Green accents, gray backgrounds, no ugly blue
- **Cross-platform**: Works identically on macOS and Linux

## Files Created

```
~/.tmux.conf          -> tmux/tmux/tmux.conf
~/.tmux/mac.conf      -> tmux/tmux/mac.conf  
~/.tmux/linux.conf    -> tmux/tmux/linux.conf
```

## Customization

Create `~/.tmux.local.conf` for personal settings:

```bash
# Example: Change prefix to Ctrl-a
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

## Management

```bash
# Test configuration
bash scripts/test.sh

# Update plugins and config
bash scripts/update.sh

# Remove everything (restores backups)
bash scripts/uninstall.sh

# System diagnostics
bash scripts/tmux_audit.sh
```

## Troubleshooting

- **Plugins missing**: Press `Ctrl-b + I` in tmux
- **Colors wrong**: Reload with `Ctrl-b + r` 
- **Keys not working**: Check `tmux list-keys`
- **More help**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

That's it. No complexity, no surprises.