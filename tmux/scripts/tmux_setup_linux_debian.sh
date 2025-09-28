#!/usr/bin/env bash
set -euo pipefail

# Check if we're on Linux
if [[ "$(uname)" != "Linux" ]]; then
    echo "Error: This script is for Linux only. Use tmux_setup_mac.sh for macOS."
    exit 1
fi

# Check for Debian/Ubuntu
if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: This script requires apt-get (Debian/Ubuntu)."
    echo "For other Linux distributions, install tmux and git manually, then run scripts/link.sh"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run with sudo: sudo $0"
    exit 1
fi

echo "Installing tmux and dependencies on Debian/Ubuntu..."
echo "This will install: tmux, git, xclip, wl-clipboard"

apt-get update
apt-get install -y tmux git xclip wl-clipboard

su - "$SUDO_USER" -c '
  mkdir -p "$HOME/.tmux/plugins"
  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  else
    git -C "$HOME/.tmux/plugins/tpm" pull --ff-only || true
  fi
'

echo "Done. Have the user open tmux and press prefix + I to install plugins."