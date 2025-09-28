#!/usr/bin/env bash
set -euo pipefail

echo "Updating dot-tmux configuration..."

# Update TPM if it exists
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Updating TPM..."
    git -C "$HOME/.tmux/plugins/tpm" pull --ff-only || {
        echo "Warning: Could not update TPM automatically"
    }
else
    echo "TPM not found, installing..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Re-link configuration files (in case repo moved)
echo "Re-linking configuration files..."
bash "$(dirname "${BASH_SOURCE[0]}")/link.sh"

echo "Update complete!"
echo "If tmux is running, restart it or run: tmux source-file ~/.tmux.conf"
echo "Then press prefix + U to update plugins"