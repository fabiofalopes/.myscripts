#!/usr/bin/env bash
set -euo pipefail

echo "Testing tmux configuration..."

# Test 1: Check if tmux is installed
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found in PATH"
    exit 1
fi
echo "✅ tmux found: $(tmux -V)"

# Test 2: Check configuration files exist
for file in ~/.tmux.conf ~/.tmux/mac.conf ~/.tmux/linux.conf; do
    if [ -L "$file" ]; then
        echo "✅ $file (symlink)"
    elif [ -f "$file" ]; then
        echo "⚠️  $file (regular file, not symlink)"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Test 3: Test configuration syntax
echo "Testing configuration syntax..."
if tmux -f ~/.tmux.conf -L test new-session -d \; kill-session 2>/dev/null; then
    echo "✅ Configuration syntax valid"
else
    echo "❌ Configuration syntax error"
    exit 1
fi

# Test 4: Check TPM installation
if [ -d ~/.tmux/plugins/tpm ]; then
    echo "✅ TPM installed"
else
    echo "⚠️  TPM not found (run setup script first)"
fi

# Test 5: Check for common plugins
for plugin in tmux-sensible tmux-resurrect tmux-continuum; do
    if [ -d ~/.tmux/plugins/$plugin ]; then
        echo "✅ Plugin: $plugin"
    else
        echo "⚠️  Plugin missing: $plugin (press prefix + I in tmux)"
    fi
done

echo ""
echo "Test complete! If you see warnings, run the appropriate setup script."
echo "To install plugins: start tmux and press prefix + I"