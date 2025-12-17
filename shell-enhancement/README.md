# Shell Enhancement

Kali Linux-style shell experience for macOS and Debian.

## What You Get

- **Autosuggestions**: History-based inline suggestions as you type
- **Syntax highlighting**: Valid commands green, invalid red
- **Enhanced completion**: Colored, grouped, arrow-navigable menus

## Quick Start

### macOS (with oh-my-zsh)

```bash
./scripts/setup-macos.sh
```

Then restart your terminal.

### Debian

```bash
./scripts/setup-debian.sh
```

## Manual Setup

If scripts don't work, install manually:

### 1. Install Plugins

**macOS:**
```bash
# Clone to oh-my-zsh custom plugins
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**Debian:**
```bash
sudo apt install zsh-autosuggestions zsh-syntax-highlighting
```

### 2. Enable in ~/.zshrc

**For oh-my-zsh users**, add to `plugins=()`:
```bash
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
#                                 ↑ must be last!
```

**For standalone zsh**, add to end of `~/.zshrc`:
```bash
# Source the snippet from this repo
source ~/.myscripts/shell-enhancement/config/.zshrc.snippet
```

### 3. Restart Shell

```bash
exec zsh
# or just open a new terminal
```

## Testing

After setup:

1. Type `git pu` - should see grey suggestion `sh origin main`
2. Press `→` (right arrow) - accepts suggestion
3. Type `gti` - should turn red (invalid command)
4. Type `git` - should turn green (valid)
5. Type `ls -` then Tab - should see colored menu

## Files

```
shell-enhancement/
├── README.md              # This file
├── docs/
│   └── VISION.md         # Why this exists, the Kali story
├── scripts/
│   ├── setup-macos.sh    # Automated macOS setup
│   └── setup-debian.sh   # Automated Debian setup
└── config/
    └── .zshrc.snippet    # Zsh settings to source
```

## Troubleshooting

**Autosuggestions not appearing?**
- Check if plugin is loaded: `echo $plugins`
- Ensure `zsh-autosuggestions` is in the list
- Try: `source ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh`

**Syntax highlighting not working?**
- Must be the LAST plugin in `plugins=()`
- Restart shell completely (not just `source ~/.zshrc`)

**Completion menu not colored?**
- Source the `.zshrc.snippet` from this repo
- Or add manually: `zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"`

## See Also

- `../fabric-completion/` - Fabric-AI specific completions
- `../tmux/` - Tmux configuration

---

## Status

| Item | Status |
|------|--------|
| Research (Kali config, plugins) | ✅ Done |
| Vision documented | ✅ Done |
| macOS setup script | ✅ Done |
| `.zshrc.snippet` config | ✅ Done |
| macOS tested | ⏳ Ready to test (run `setup-macos.sh`) |
| Debian setup script | ⏳ TODO: develop on Debian machine |

**macOS is ready.** Run the setup, enable plugins in `.zshrc`, restart shell.

**Debian is future work.** When on the Debian machine, develop and test `setup-debian.sh`.
