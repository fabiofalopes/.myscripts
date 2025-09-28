#!/usr/bin/env bash
set -euo pipefail

echo "Uninstalling dot-tmux configuration..."

# Remove symlinks
echo "Removing symlinks..."
for file in ~/.tmux.conf ~/.tmux/mac.conf ~/.tmux/linux.conf; do
    if [ -L "$file" ]; then
        echo "Removing symlink: $file"
        rm -f "$file"
    elif [ -f "$file" ]; then
        echo "Warning: $file exists but is not a symlink (skipping)"
    fi
done

# Restore backups if they exist
echo "Looking for backups to restore..."
for backup in ~/.tmux.conf.bak.* ~/.tmux/mac.conf.bak.* ~/.tmux/linux.conf.bak.*; do
    if [ -f "$backup" ]; then
        original="${backup%.bak.*}"
        echo "Restoring backup: $backup -> $original"
        mv "$backup" "$original"
    fi
done

echo "Uninstall complete."
echo "Note: TPM and plugins in ~/.tmux/plugins/ were left intact."
echo "To remove them: rm -rf ~/.tmux/plugins/"