# OpenCode Observability Workflow

## Overview
This workflow establishes a dedicated `tmux` environment for monitoring OpenCode AI usage, costs, and performance. It uses `ocmonitor` as the primary tool, orchestrated into a persistent multi-window dashboard.

**Key Features:**
- Explicit window names (no ambiguity)
- Session persistence across reboots (via tmux-resurrect/continuum)
- Version-controlled configuration
- Automated deployment from myscripts repo

## Quick Start

```bash
# 1. Deploy ocmonitor configuration (one-time setup)
~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh

# 2. Launch the monitoring dashboard
~/.myscripts/tmux/scripts/start-opencode-observability-monitoring.sh
```

## Configuration

**Source of Truth:** `~/.myscripts/tmux/configs/ocmonitor.config.toml`
**Deployed To:** `~/.config/ocmonitor/config.toml` (symlinked)

To modify configuration:
1. Edit: `~/.myscripts/tmux/configs/ocmonitor.config.toml`
2. Redeploy: `~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh`
3. Restart monitoring session if needed

**Key Settings:**
- `sessions_path`: Points to `~/.local/share/opencode/storage/session/`
- `daily_budget`: Alert threshold for daily costs
- `refresh.*`: Auto-refresh intervals for watch commands

## The Dashboard

**Session Name:** `opencode-observability-monitoring`

**Window Structure:**
- Window 0: `ocmonitor-live-feed` - Real-time session monitoring
- Window 1: `ocmonitor-daily-costs` - Daily budget tracking (refreshes every 60s)
- Window 2: `ocmonitor-model-breakdown` - Model usage analytics (refreshes every 5m)
- Window 3: `ocmonitor-session-history` - Interactive session browser
- Window 4: `opencode-logs-tail` - Raw OpenCode logs (live tail)
- Window 5: `workspace` - General terminal for ad-hoc commands

**Navigation:**
- Switch windows: `Ctrl-b + 0` through `Ctrl-b + 5`
- Detach: `Ctrl-b + d`
- Reattach: `tmux attach -t opencode-observability-monitoring`

## Session Persistence

The dashboard session **automatically persists** across:
- Tmux server restarts
- System reboots
- Crashes

**How it works:**
- `tmux-resurrect` captures window names and running commands
- `tmux-continuum` automatically restores sessions on boot
- No manual intervention required

## Key Commands

### Inside the dashboard:
```bash
# Window 3 (session-history) or Window 5 (workspace)
ocmonitor sessions                    # List all sessions
ocmonitor session <session-id>        # Deep dive into specific session
ocmonitor daily --breakdown           # Daily costs per model
ocmonitor weekly --start-day monday   # Weekly summary
ocmonitor export --format json        # Export for analysis
```

### Managing the session:
```bash
# From outside
tmux attach -t opencode-observability-monitoring  # Reattach
tmux kill-session -t opencode-observability-monitoring  # Stop

# From inside
Ctrl-b + d    # Detach (session keeps running)
```

## Documentation Links

- **Design Document:** `~/.myscripts/tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md`
- **Cross-Repo Linkages:** `~/.myscripts/docs/CROSS-REPO-CONFIG-LINKAGES.md`
- **ocmonitor Source:** https://github.com/Shlomob/ocmonitor-share

## Troubleshooting

**Issue:** Can't find ocmonitor command
**Fix:** Install ocmonitor: https://github.com/Shlomob/ocmonitor-share

**Issue:** Session doesn't show any data
**Fix:** Verify sessions path in config and check `ls ~/.local/share/opencode/storage/session/`

**Issue:** Session doesn't persist after reboot
**Fix:** Install tmux plugins: `Ctrl-b + I` inside tmux

See `~/.myscripts/docs/CROSS-REPO-CONFIG-LINKAGES.md` for comprehensive troubleshooting.
