# Troubleshooting Guide

## Common Issues and Solutions

### Installation Issues

#### "tmux/tmux.conf not found" when running link.sh
**Problem**: Running the link script from wrong directory.
**Solution**: Make sure you're in the dot-tmux repository root directory.

#### "Homebrew not found" on macOS
**Problem**: Homebrew is not installed.
**Solution**: Install Homebrew first: https://brew.sh

#### "apt-get not found" on Linux
**Problem**: Using the Debian script on a non-Debian system.
**Solution**: Install tmux and git manually, then run `scripts/link.sh`

### Plugin Issues

#### Plugins not loading after installation
**Problem**: TPM not properly initialized.
**Solution**: 
1. Start tmux: `tmux`
2. Press `prefix + I` (default prefix is Ctrl-b)
3. Wait for plugins to install

#### "prefix + I" doesn't work
**Problem**: Wrong prefix key or TPM not installed.
**Solution**:
1. Check your prefix: default is Ctrl-b, not Ctrl-a
2. Verify TPM exists: `ls ~/.tmux/plugins/tpm`
3. If missing, run the appropriate setup script again

### Configuration Issues

#### Colors look wrong in tmux
**Problem**: Terminal doesn't support proper color modes.
**Solution**:
1. Check terminal capabilities: `echo $TERM`
2. Try setting: `export TERM=xterm-256color`
3. For better support, install: `tic -x tmux-256color`

#### Copy/paste not working
**Problem**: Clipboard integration issues.
**Solutions**:

**macOS**:
- Ensure you're using a recent tmux version: `tmux -V`
- Try: `brew upgrade tmux`

**Linux**:
- Install clipboard tools: `sudo apt install xclip wl-clipboard`
- For X11: uncomment xclip binding in `~/.tmux/linux.conf`
- For Wayland: uncomment wl-copy binding in `~/.tmux/linux.conf`

#### Sessions not restoring after reboot
**Problem**: tmux-continuum plugin not working.
**Solution**:
1. Verify plugin installed: `ls ~/.tmux/plugins/tmux-continuum`
2. Check tmux version compatibility
3. Manually save session: `prefix + Ctrl-s`
4. Manually restore: `prefix + Ctrl-r`

### Customization Issues

#### Want to change prefix to Ctrl-a
**Problem**: Default prefix is Ctrl-b.
**Solution**: Add to `~/.tmux.local.conf`:
```
set -g prefix C-a
unbind C-b
bind C-a send-prefix
```

#### Custom keybindings not working
**Problem**: Conflicting or incorrect syntax.
**Solution**: Add custom bindings to `~/.tmux.local.conf` to avoid conflicts.

### System-Specific Issues

#### macOS: "reattach-to-user-namespace" errors
**Problem**: Old tmux versions needed this for clipboard.
**Solution**: Update tmux: `brew upgrade tmux` (modern versions don't need this)

#### Linux: SSH sessions lose clipboard
**Problem**: DISPLAY variable not set in SSH.
**Solution**: SSH with X11 forwarding: `ssh -X user@host`

## Diagnostic Commands

### Check your setup
```bash
# Run the audit script
bash scripts/tmux_audit.sh

# Check tmux version
tmux -V

# List active sessions
tmux ls

# Check plugin status (inside tmux)
# prefix + alt + u
```

### Verify configuration files
```bash
# Check symlinks
ls -la ~/.tmux.conf ~/.tmux/*.conf

# Test configuration syntax
tmux -f ~/.tmux.conf -L test new-session -d \; kill-session
```

### Reset to defaults
```bash
# Uninstall current setup
bash scripts/uninstall.sh

# Clean install
bash scripts/link.sh
```

## Getting Help

If you're still having issues:

1. **Run the audit script**: `bash scripts/tmux_audit.sh`
2. **Check tmux logs**: Look for error messages when starting tmux
3. **Test minimal config**: Temporarily move `~/.tmux.local.conf` aside
4. **Verify plugins**: `ls ~/.tmux/plugins/` should show installed plugins

## Reporting Issues

When reporting problems, include:
- Output of `scripts/tmux_audit.sh`
- Your operating system and version
- tmux version (`tmux -V`)
- Any custom configurations in `~/.tmux.local.conf`
- Error messages or unexpected behavior description