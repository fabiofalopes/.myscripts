# Documentation Navigation Index

## Purpose
Quick reference for finding documentation across the myscripts repository. This index maps topics to relevant documentation files.

---

## 🎯 Start Here

**New to this repository?**
1. Read: [tmux/README.md](../tmux/README.md) - Tmux setup overview
2. Read: [CROSS-REPO-CONFIG-LINKAGES.md](CROSS-REPO-CONFIG-LINKAGES.md) - How everything connects
3. Try: `tmux/scripts/start-opencode-observability-monitoring.sh` - Launch monitoring

---

## 📂 By Topic

### OpenCode Observability & Monitoring
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [OBSERVABILITY-WORKFLOW.md](OBSERVABILITY-WORKFLOW.md) | Quick reference for monitoring workflow | Daily use, troubleshooting |
| [tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md](../tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md) | Design decisions and architecture | Understanding "why", customization |
| [CROSS-REPO-CONFIG-LINKAGES.md](CROSS-REPO-CONFIG-LINKAGES.md) | Configuration relationships | Setup, migration, debugging |

### Tmux Configuration
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [tmux/README.md](../tmux/README.md) | Tmux setup and features | Initial setup, reference |
| [tmux/TROUBLESHOOTING.md](../tmux/TROUBLESHOOTING.md) | Tmux-specific issues | When things break |

### Configuration Management
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [CROSS-REPO-CONFIG-LINKAGES.md](CROSS-REPO-CONFIG-LINKAGES.md) | Cross-repo configuration architecture | Setup, migration, understanding system |

### Audio / Video Download
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [yta-quickref.md](yta-quickref.md) | Download audio from YouTube/yt-dlp sites | Using `yta`, batch/channel downloads |

### Documentation Strategy
| Document | Purpose | When to Read |
|----------|---------|--------------|
| [Documentation-Strategy-Framework.md](Documentation-Strategy-Framework.md) | How to write good docs iteratively | Creating new documentation |

---

## 🔧 By Task

### "I want to start monitoring OpenCode"
1. Deploy config: `~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh`
2. Start dashboard: `~/.myscripts/tmux/scripts/start-opencode-observability-monitoring.sh`
3. Read: [OBSERVABILITY-WORKFLOW.md](OBSERVABILITY-WORKFLOW.md)

### "I want to customize ocmonitor settings"
1. Edit: `~/.myscripts/tmux/configs/ocmonitor.config.toml`
2. Deploy: `~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh`
3. Reference: [CROSS-REPO-CONFIG-LINKAGES.md § Configuration Deployment](CROSS-REPO-CONFIG-LINKAGES.md#data-flow)

### "I want to understand the architecture"
1. Read: [CROSS-REPO-CONFIG-LINKAGES.md](CROSS-REPO-CONFIG-LINKAGES.md)
2. Read: [tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md](../tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md)

### "I want to set up a new machine"
1. Follow: [CROSS-REPO-CONFIG-LINKAGES.md § Migration and Portability](CROSS-REPO-CONFIG-LINKAGES.md#migration-and-portability)

### "I want to download audio from YouTube"
1. Read: [yta-quickref.md](yta-quickref.md)
2. Quick start: `yta -f opus -o ~/yt-audio 'https://youtube.com/watch?v=...'`
3. Batch/channel: add `-p` and a playlist/channel URL

### "Something broke, help!"
1. Check: [OBSERVABILITY-WORKFLOW.md § Troubleshooting](OBSERVABILITY-WORKFLOW.md#troubleshooting)
2. Check: [CROSS-REPO-CONFIG-LINKAGES.md § Troubleshooting](CROSS-REPO-CONFIG-LINKAGES.md#troubleshooting-cross-repo-issues)
3. Check: [tmux/TROUBLESHOOTING.md](../tmux/TROUBLESHOOTING.md)

---

## 📍 Key Locations

### Configuration Files
```
~/.myscripts/tmux/configs/ocmonitor.config.toml  # Edit here
~/.myscripts/tmux/tmux/tmux.conf                 # Tmux config
~/.config/ocmonitor/config.toml                  # Symlink (deployed)
~/.config/opencode/opencode.json                 # OpenCode config (separate repo)
```

### Scripts
```
~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh             # Deploy config
~/.myscripts/tmux/scripts/start-opencode-observability-monitoring.sh  # Start monitoring
~/.myscripts/tmux/scripts/link.sh                                # Link tmux configs
```

### Data
```
~/.local/share/opencode/storage/session/  # OpenCode sessions
~/.local/share/opencode/log/              # OpenCode logs
```

---

## 🔍 Document Status

| Document | Status | Last Updated |
|----------|--------|--------------|
| OBSERVABILITY-WORKFLOW.md | Current | 2025-12-31 |
| CROSS-REPO-CONFIG-LINKAGES.md | Current | 2025-12-31 |
| tmux/docs/OPENCODE-OBSERVABILITY-DESIGN.md | Current | 2025-12-31 |
| tmux/README.md | Current | - |
| Documentation-Strategy-Framework.md | Reference | 2025-10-07 |
| yta-quickref.md | Current | 2026-07-30 |

---

## 📝 Quick Commands

```bash
# Monitoring
~/.myscripts/tmux/scripts/start-opencode-observability-monitoring.sh
tmux attach -t opencode-observability-monitoring

# Configuration
~/.myscripts/tmux/scripts/deploy-ocmonitor-config.sh

# Sessions
ocmonitor sessions
ocmonitor daily --breakdown
ocmonitor models
ocmonitor export --format json
```
