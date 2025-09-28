#!/usr/bin/env bash
set -euo pipefail

# Script to integrate this tmux configuration into .myscripts repository

MYSCRIPTS_DIR="$HOME/Documents/projetos/hub/.myscripts"
TARGET_DIR="$MYSCRIPTS_DIR/tmux"

echo "Integrating tmux configuration into .myscripts..."

# Check if .myscripts exists
if [ ! -d "$MYSCRIPTS_DIR" ]; then
    echo "Error: $MYSCRIPTS_DIR not found."
    echo "Please ensure your .myscripts repository is cloned to $MYSCRIPTS_DIR"
    exit 1
fi

# Check if target directory already exists
if [ -d "$TARGET_DIR" ]; then
    echo "Warning: $TARGET_DIR already exists."
    read -r -p "Replace existing tmux configuration? [y/N] " ans
    case "${ans:-N}" in 
        y|Y) 
            echo "Backing up existing configuration..."
            mv "$TARGET_DIR" "${TARGET_DIR}.bak.$(date +%Y%m%d-%H%M%S)"
            ;;
        *) 
            echo "Aborted."
            exit 1
            ;;
    esac
fi

# Copy the entire configuration
echo "Copying tmux configuration to $TARGET_DIR..."
cp -r "$(dirname "${BASH_SOURCE[0]}")/.." "$TARGET_DIR"

# Remove git-specific files and temporary items
rm -rf "$TARGET_DIR/.git" "$TARGET_DIR/sources" "$TARGET_DIR/.gitignore" 2>/dev/null || true

# Make scripts executable
chmod +x "$TARGET_DIR"/scripts/*.sh

echo "✅ Integration complete!"
echo ""
echo "Next steps:"
echo "1. cd $MYSCRIPTS_DIR"
echo "2. git add tmux/"
echo "3. git commit -m 'Add portable tmux configuration'"
echo "4. Test installation: cd tmux && bash scripts/link.sh"
echo ""
echo "The tmux configuration is now part of your .myscripts repository!"