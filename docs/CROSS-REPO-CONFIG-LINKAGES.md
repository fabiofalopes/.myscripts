# Cross-Repository Configuration Linkages

## Overview
This document maps how configurations across multiple repositories and system locations interact to create the OpenCode observability environment.

## Repository Structure

```
~/.myscripts/                           [Git Repo: local scripts and configs]
├── tmux/
│   ├── configs/
│   │   └── ocmonitor.config.toml       [SOURCE OF TRUTH for ocmonitor]
│   ├── scripts/
│   │   ├── deploy-ocmonitor-config.sh  [Deployment automation]
│   │   └── start-opencode-observability-monitoring.sh  [Session launcher]
│   ├── docs/
│   │   └── OPENCODE-OBSERVABILITY-DESIGN.md
│   └── tmux/
│       └── tmux.conf                   [Session persistence config]

~/.config/opencode/                     [Git Repo: OpenCode agent configuration]
├── opencode.json                       [Agent and model configuration]
├── AGENTS.md                           [Agent instructions]
└── docs/                               [OpenCode documentation]

~/.config/ocmonitor/                    [Deployed config - NOT version controlled]
└── config.toml                         [Symlink → ~/.myscripts/tmux/configs/ocmonitor.config.toml]

~/.local/share/opencode/                [OpenCode runtime data - NOT version controlled]
├── storage/
│   └── session/                        [Session data - monitored by ocmonitor]
└── log/                                [OpenCode logs - tailed in monitoring]
```

## Data Flow

### 1. Configuration Deployment
```
Edit: ~/.myscripts/tmux/configs/ocmonitor.config.toml
  ↓
Run: ~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh
  ↓
Symlink created: ~/.config/ocmonitor/config.toml → source config
  ↓
ocmonitor reads: ~/.config/ocmonitor/config.toml
```

### 2. Session Monitoring
```
OpenCode runs → Generates sessions in ~/.local/share/opencode/storage/session/
  ↓
ocmonitor reads: Sessions from path defined in config.toml
  ↓
Dashboard displays: Real-time stats in tmux session
  ↓
tmux-resurrect saves: Session state including window names and commands
  ↓
tmux-continuum restores: Dashboard persists across reboots
```

### 3. Logging Pipeline
```
OpenCode writes: ~/.local/share/opencode/log/*.log
  ↓
tmux window tails: tail -f ~/.local/share/opencode/log/*.log | ccze
  ↓
User monitors: Live log stream in dedicated window
```

## Configuration Ownership

| Config File | Owner | Purpose | Version Control |
|-------------|-------|---------|-----------------|
| `~/.myscripts/tmux/configs/ocmonitor.config.toml` | myscripts repo | ocmonitor source of truth | ✓ Git tracked |
| `~/.myscripts/tmux/scripts/start-opencode-observability-monitoring.sh` | myscripts repo | Session launcher | ✓ Git tracked |
| `~/.myscripts/tmux/tmux/tmux.conf` | myscripts repo | tmux base config + persistence | ✓ Git tracked |
| `~/.config/opencode/opencode.json` | opencode config repo | OpenCode agent config | ✓ Git tracked (separate repo) |
| `~/.config/ocmonitor/config.toml` | Symlink (myscripts) | Runtime config for ocmonitor | ✗ Symlink to tracked file |
| `~/.local/share/opencode/storage/session/` | OpenCode runtime | Session data | ✗ Runtime data only |
| `~/.local/share/opencode/log/` | OpenCode runtime | Log files | ✗ Runtime data only |

## Cross-Repo Dependencies

### myscripts → OpenCode Runtime
- **Dependency:** ocmonitor config points to OpenCode session storage path
- **Failure mode:** If path changes, update `~/.myscripts/tmux/configs/ocmonitor.config.toml` and redeploy
- **Test:** `ocmonitor sessions` should show sessions

### myscripts → ocmonitor installation
- **Dependency:** Launcher script requires `ocmonitor` in PATH
- **Failure mode:** Script exits with error if not found
- **Test:** `which ocmonitor` should return path

### tmux persistence → Session launcher
- **Dependency:** tmux-resurrect captures window names and commands
- **Benefit:** Dashboard survives reboots automatically
- **Test:** Create session, reboot, session should restore

### OpenCode config repo → myscripts
- **Separation:** These are independent
- **Linkage:** Both are documented together for holistic understanding
- **Recommendation:** Keep separate repos, document cross-references

## Version Control Strategy

### What to commit to myscripts repo:
- ✓ ocmonitor config source (`tmux/configs/ocmonitor.config.toml`)
- ✓ Launcher scripts (`tmux/scripts/start-*.sh`)
- ✓ Deployment scripts (`tmux/scripts/deploy-*.sh`)
- ✓ Documentation (`tmux/docs/*.md`)
- ✓ tmux base config (`tmux/tmux/*.conf`)

### What NOT to commit:
- ✗ Runtime session data
- ✗ OpenCode logs
- ✗ Deployed symlinks in `~/.config/`
- ✗ User-specific local overrides

## Migration and Portability

### Setting up on a new system:

1. **Clone myscripts repo:**
   ```bash
   git clone <repo> ~/.myscripts
   cd ~/.myscripts/tmux
   ```

2. **Deploy tmux configuration:**
   ```bash
   bash scripts/link.sh
   tmux  # Start tmux
   # Press Ctrl-b + I to install plugins (tmux-resurrect, tmux-continuum)
   ```

3. **Install ocmonitor:**
   ```bash
   # Follow: https://github.com/Shlomob/ocmonitor-share
   ```

4. **Deploy ocmonitor config:**
   ```bash
   bash scripts/deploy-ocmonitor-config.sh
   ```

5. **Verify OpenCode is installed and sessions exist:**
   ```bash
   ls ~/.local/share/opencode/storage/session/
   ```

6. **Launch dashboard:**
   ```bash
   bash scripts/start-opencode-observability-monitoring.sh
   ```

### Syncing changes across systems:
- Push changes from system A: `git push` from `~/.myscripts/`
- Pull on system B: `git pull` in `~/.myscripts/`
- Redeploy configs: `bash tmux/scripts/deploy-ocmonitor-config.sh`
- Restart monitoring session if already running

## Troubleshooting Cross-Repo Issues

### Issue: ocmonitor can't find sessions
**Check:**
```bash
# Verify config symlink
ls -la ~/.config/ocmonitor/config.toml

# Verify sessions path
grep sessions_path ~/.myscripts/tmux/configs/ocmonitor.config.toml

# Verify sessions exist
ls ~/.local/share/opencode/storage/session/
```

**Fix:**
Redeploy config: `bash ~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh`

### Issue: Session launcher fails
**Check:**
```bash
# Verify ocmonitor installed
which ocmonitor

# Verify tmux installed
which tmux

# Check for running sessions
tmux ls
```

**Fix:**
Install missing dependencies or attach to existing session.

### Issue: tmux session doesn't persist after reboot
**Check:**
```bash
# Verify plugins installed
ls ~/.tmux/plugins/

# Check for resurrect/continuum
tmux show-options -g | grep resurrect
tmux show-options -g | grep continuum
```

**Fix:**
Run `Ctrl-b + I` inside tmux to install plugins.

## Future Enhancements

- **Automated deployment:** Run deploy script on git pull via hook
- **Config validation:** Pre-deployment checks for path existence
- **Multi-machine sync:** Consider using a dotfiles manager (chezmoi, GNU stow)
- **Monitoring configs in OpenCode repo:** Add observability config to .config/opencode for completeness
