#!/usr/bin/env bash
set -euo pipefail

echo "Installing tmux and TPM on macOS..."

# Check if we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only. Use tmux_setup_linux_debian.sh for Linux."
    exit 1
fi

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
    echo "Error: Homebrew not found."
    echo "Install Homebrew first: https://brew.sh"
    echo "Then run this script again."
    exit 1
fi

# Check if git is available
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git not found. Install git first:"
    echo "  brew install git"
    exit 1
fi

echo "Prerequisites check passed."
read -r -p "Proceed with installation? [y/N] " ans
case "${ans:-N}" in y|Y) ;; *) echo "Aborted."; exit 1;; esac

brew install tmux

mkdir -p "$HOME/.tmux/plugins"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
else
  git -C "$HOME/.tmux/plugins/tpm" pull --ff-only || true
fi

echo "Done. Open tmux and press prefix + I to install plugins."