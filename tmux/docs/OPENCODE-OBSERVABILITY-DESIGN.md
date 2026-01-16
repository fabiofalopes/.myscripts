# OpenCode Observability Tmux Session Design

## Naming Convention

**Session Name:** `opencode-observability-monitoring`
- Explicit: Clearly indicates this is for OpenCode
- Scoped: "observability" narrows it to monitoring/analytics
- Purpose: "monitoring" indicates it's a live dashboard

**Alternative session names for future expansion:**
- `opencode-observability-analysis` - For deep-dive session analysis
- `opencode-observability-costs` - For cost tracking and budget management
- `opencode-development-primary` - For actual coding sessions with OpenCode

## Window Structure (Not Panes)

Using **windows** instead of panes for better organization and persistence:

### Window 0: `ocmonitor-live-feed`
- **Purpose:** Real-time session monitoring
- **Command:** `ocmonitor live`
- **Why window:** Can be restarted independently without affecting other views

### Window 1: `ocmonitor-daily-costs`
- **Purpose:** Daily budget tracking
- **Command:** `watch -n 60 --color 'ocmonitor daily --breakdown'`
- **Why window:** Separate refresh cycle, can switch away when not needed

### Window 2: `ocmonitor-model-breakdown`
- **Purpose:** Model usage analytics
- **Command:** `watch -n 300 --color 'ocmonitor models'`
- **Why window:** Long refresh interval, reference data

### Window 3: `ocmonitor-session-history`
- **Purpose:** Historical session browser
- **Command:** `ocmonitor sessions`
- **Why window:** Interactive - user will navigate through sessions

### Window 4: `opencode-logs-tail`
- **Purpose:** Raw OpenCode logs
- **Command:** `tail -f ~/.local/share/opencode/log/*.log | ccze -A` (if ccze available, else plain tail)
- **Why window:** Debugging and detailed investigation

### Window 5: `workspace`
- **Purpose:** General terminal for ad-hoc commands
- **Command:** `bash` (with cwd in ~/.myscripts)
- **Why window:** Freedom to run exports, custom queries, etc.

## Session Persistence

**How it works with tmux-resurrect/continuum:**
1. Session is created with explicit window names
2. Commands in each window are captured by resurrect
3. On system restart, continuum automatically restores
4. Window names remain explicit and clear

**No data loss:** Sessions survive crashes, reboots, and tmux server restarts.

## Configuration Linkage

```
~/.myscripts/tmux/
├── scripts/
│   └── start-opencode-observability-monitoring.sh  # Launcher
├── configs/
│   └── ocmonitor.config.toml                        # Source of truth
└── docs/
    └── OPENCODE-OBSERVABILITY-DESIGN.md             # This file

~/.config/ocmonitor/
└── config.toml  # Deployed from tmux/configs/ocmonitor.config.toml

~/.config/opencode/
└── (OpenCode configuration - separate repo)
```

**Deployment flow:**
1. Edit `~/.myscripts/tmux/configs/ocmonitor.config.toml`
2. Run `~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh`
3. Config is symlinked/copied to `~/.config/ocmonitor/config.toml`
4. Changes are versioned in myscripts repo

## Why This Design

**Explicit over implicit:**
- Window names tell you exactly what's running
- Session name clearly scopes the purpose
- No guessing what "observability" or "monitor" means alone

**Windows over panes:**
- Each window can crash/restart independently
- Better for different refresh intervals
- Easier to navigate with tmux window switching (Ctrl-b 0-5)
- Cleaner separation of concerns

**Persistence built-in:**
- tmux-resurrect captures window names and commands
- tmux-continuum auto-restores after reboot
- No custom persistence logic needed

**Maintainability:**
- Config source of truth in myscripts (version controlled)
- Deployment script ensures consistency
- Documentation lives with the code

## Future Enhancements

**Potential additions:**
- `ocmonitor-projects` window for project-level analytics
- `ocmonitor-exports` window for running scheduled exports
- Integration with system monitoring (htop, glances) in additional windows
- Alert system (if daily cost exceeds threshold, send notification)
