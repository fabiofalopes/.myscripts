#!/bin/bash
# Deploy ocmonitor configuration from myscripts to system config
# Source: ~/.myscripts/tmux/configs/ocmonitor.config.toml
# Target: ~/.config/ocmonitor/config.toml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIG="$HOME/.myscripts/tmux/configs/ocmonitor.config.toml"
TARGET_DIR="$HOME/.config/ocmonitor"
TARGET_CONFIG="$TARGET_DIR/config.toml"

echo "=== OpenCode Monitor Config Deployment ==="
echo ""

# Check if source exists
if [ ! -f "$SOURCE_CONFIG" ]; then
    echo "❌ Error: Source config not found at $SOURCE_CONFIG"
    exit 1
fi

echo "✓ Source config found: $SOURCE_CONFIG"

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "📁 Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# Backup existing config if it exists
if [ -f "$TARGET_CONFIG" ]; then
    BACKUP="$TARGET_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    echo "📦 Backing up existing config to: $BACKUP"
    cp "$TARGET_CONFIG" "$BACKUP"
fi

# Deploy config (symlink for live updates)
echo "🔗 Symlinking config to target location..."
ln -sf "$SOURCE_CONFIG" "$TARGET_CONFIG"

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Configuration locations:"
echo "  Source (edit here): $SOURCE_CONFIG"
echo "  Target (used by ocmonitor): $TARGET_CONFIG"
echo ""
echo "To verify: ocmonitor config show"
