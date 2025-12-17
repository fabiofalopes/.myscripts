# Fabric Shell Completions

Autocompletion for `fabric-ai -p <pattern>` and all other flags.

## Quick Start

```bash
./scripts/setup.sh
```

Then restart your shell. Done.

## What This Does

Fabric has official shell completions, but they're not installed by default.
This script runs the official installer from the fabric repository.

## Testing

After setup, try:

```bash
fabric-ai -p <TAB>      # Shows all patterns
fabric-ai -p ana<TAB>   # Filters to patterns starting with "ana"
fabric-ai -m <TAB>      # Shows all models
```

## Supported Shells

- Zsh (macOS, Kali, etc.)
- Bash (Debian, Ubuntu, etc.)
- Fish

## Troubleshooting

**Completions not working after restart?**

```bash
# Zsh
autoload -U compinit && compinit

# Bash
source ~/.bashrc
```

**Where are completions installed?**

- Zsh: `/usr/local/share/zsh/site-functions/` or similar
- Bash: `/etc/bash_completion.d/` or `~/.local/share/bash-completion/completions/`
- Fish: `~/.config/fish/completions/`

## Manual Installation

If the setup script doesn't work:

```bash
# Download directly
curl -fsSL https://raw.githubusercontent.com/danielmiessler/Fabric/main/completions/setup-completions.sh | sh
```

Or grab files manually from:
https://github.com/danielmiessler/Fabric/tree/main/completions

## Why This Folder Exists

Because you'll forget to set this up on new machines. Now you won't.

---

## Status

| Item | Status |
|------|--------|
| Research official completions | ✅ Done |
| Setup script | ✅ Done |
| macOS (Zsh) tested | ✅ Working |
| Debian (Bash) | ⏳ To test on Debian machine |

**This project is complete.** Run `setup.sh` on any new machine.
