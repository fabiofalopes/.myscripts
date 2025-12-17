#!/usr/bin/env bash
set -euo pipefail

# Shell Enhancement Setup for macOS
# Adds Kali-like autosuggestions and syntax highlighting to oh-my-zsh

echo "==================================="
echo "Shell Enhancement Setup (macOS)"
echo "==================================="
echo ""

# Check we're on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is for macOS only."
    echo "Use setup-debian.sh for Debian/Ubuntu."
    exit 1
fi

# Check for oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Warning: oh-my-zsh not detected at ~/.oh-my-zsh"
    echo ""
    echo "You can either:"
    echo "  1. Install oh-my-zsh: https://ohmyz.sh/"
    echo "  2. Use standalone installation (see README.md)"
    echo ""
    read -r -p "Continue with standalone installation? [y/N] " ans
    case "${ans:-N}" in
        y|Y) STANDALONE=true ;;
        *) echo "Aborted."; exit 1 ;;
    esac
else
    STANDALONE=false
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "Installing plugins..."
echo ""

# Install zsh-autosuggestions
AUTOSUGG_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
if [[ -d "$AUTOSUGG_DIR" ]]; then
    echo "zsh-autosuggestions already installed, updating..."
    git -C "$AUTOSUGG_DIR" pull --ff-only 2>/dev/null || true
else
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$AUTOSUGG_DIR"
fi

# Install zsh-syntax-highlighting
HIGHLIGHT_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
if [[ -d "$HIGHLIGHT_DIR" ]]; then
    echo "zsh-syntax-highlighting already installed, updating..."
    git -C "$HIGHLIGHT_DIR" pull --ff-only 2>/dev/null || true
else
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HIGHLIGHT_DIR"
fi

echo ""
echo "Plugins installed!"
echo ""

# Check if plugins are already in .zshrc
if grep -q "zsh-autosuggestions" "$HOME/.zshrc" 2>/dev/null; then
    echo "zsh-autosuggestions already in .zshrc"
else
    echo "ACTION REQUIRED: Add plugins to your ~/.zshrc"
    echo ""
    echo "Find your plugins=(...) line and update it to:"
    echo ""
    echo '  plugins=(git ... zsh-autosuggestions zsh-syntax-highlighting)'
    echo ""
    echo "IMPORTANT: zsh-syntax-highlighting must be LAST!"
fi

# Get script directory to find config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNIPPET_FILE="$SCRIPT_DIR/../config/.zshrc.snippet"

if [[ -f "$SNIPPET_FILE" ]]; then
    # Check if snippet is already sourced
    if grep -q "shell-enhancement" "$HOME/.zshrc" 2>/dev/null; then
        echo ""
        echo "Config snippet already sourced in .zshrc"
    else
        echo ""
        echo "Optional: Source the config snippet for enhanced completion styles."
        echo ""
        echo "Add this line to the END of your ~/.zshrc:"
        echo ""
        echo "  # Shell enhancement config"
        echo "  [ -f \"$SNIPPET_FILE\" ] && source \"$SNIPPET_FILE\""
    fi
fi

echo ""
echo "==================================="
echo "Setup complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "  1. Edit ~/.zshrc to enable plugins (see above)"
echo "  2. Restart your terminal"
echo "  3. Test: type 'git pu' and see suggestion appear"
echo ""
echo "If it doesn't work, run: exec zsh"
