#!/usr/bin/env bash
set -euo pipefail

# Fabric Shell Completions Setup
# This script installs fabric-ai shell completions using the official installer.
#
# Why this exists:
# - fabric-ai has official completions, but they're not installed by default
# - This reminds you to set them up on new machines
# - One command to run, done forever on that machine

echo "==================================="
echo "Fabric Shell Completions Setup"
echo "==================================="
echo ""

# Check if fabric-ai or fabric exists
if command -v fabric-ai >/dev/null 2>&1; then
    FABRIC_CMD="fabric-ai"
elif command -v fabric >/dev/null 2>&1; then
    FABRIC_CMD="fabric"
else
    echo "Error: Neither 'fabric-ai' nor 'fabric' found in PATH."
    echo "Install fabric first: https://github.com/danielmiessler/fabric"
    exit 1
fi

echo "Found: $FABRIC_CMD"
echo "Shell: $SHELL"
echo ""

# Check if completions might already be working
echo "Testing current completion status..."
if [ -n "${ZSH_VERSION:-}" ] || [[ "$SHELL" == *"zsh"* ]]; then
    # Check common zsh completion locations
    for dir in /usr/local/share/zsh/site-functions /opt/homebrew/share/zsh/site-functions ~/.local/share/zsh/site-functions; do
        if [ -f "$dir/_fabric-ai" ] || [ -f "$dir/_fabric" ]; then
            echo "Zsh completions already installed at: $dir"
            echo ""
            echo "If completions aren't working, try:"
            echo "  autoload -U compinit && compinit"
            echo "  # or restart your shell"
            echo ""
            read -r -p "Reinstall anyway? [y/N] " ans
            case "${ans:-N}" in y|Y) ;; *) echo "Done."; exit 0;; esac
            break
        fi
    done
elif [ -n "${BASH_VERSION:-}" ] || [[ "$SHELL" == *"bash"* ]]; then
    # Check common bash completion locations
    for dir in /etc/bash_completion.d /usr/local/etc/bash_completion.d /opt/homebrew/etc/bash_completion.d ~/.local/share/bash-completion/completions; do
        if [ -f "$dir/fabric-ai.bash" ] || [ -f "$dir/fabric.bash" ]; then
            echo "Bash completions already installed at: $dir"
            echo ""
            echo "If completions aren't working, try:"
            echo "  source ~/.bashrc"
            echo "  # or restart your shell"
            echo ""
            read -r -p "Reinstall anyway? [y/N] " ans
            case "${ans:-N}" in y|Y) ;; *) echo "Done."; exit 0;; esac
            break
        fi
    done
fi

echo ""
echo "Installing completions using official fabric setup script..."
echo ""

# Use the official setup script from fabric repository
# This handles all the complexity of detecting shell, finding right directory, etc.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://raw.githubusercontent.com/danielmiessler/Fabric/main/completions/setup-completions.sh | sh
elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://raw.githubusercontent.com/danielmiessler/Fabric/main/completions/setup-completions.sh | sh
else
    echo "Error: Neither curl nor wget found."
    echo ""
    echo "Manual installation:"
    echo "  1. Download: https://github.com/danielmiessler/Fabric/tree/main/completions"
    echo "  2. Follow instructions in those files"
    exit 1
fi

echo ""
echo "==================================="
echo "Setup complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "  1. Restart your shell (or open a new terminal)"
echo "  2. Try: $FABRIC_CMD -p <TAB>"
echo ""
echo "If completions don't work after restart:"
echo "  - Zsh: run 'autoload -U compinit && compinit'"
echo "  - Bash: run 'source ~/.bashrc'"
