#!/usr/bin/env bash
set -euo pipefail

# Check if we're in the right directory
if [ ! -f "tmux/tmux.conf" ]; then
    echo "Error: tmux/tmux.conf not found. Run this script from the dot-tmux repository root."
    exit 1
fi

ts() { date +"%Y%m%d-%H%M%S"; }
backup() {
  local dst="$1"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv -v "$dst" "${dst}.bak.$(ts)"
  elif [ -L "$dst" ]; then
    # If symlink points elsewhere, back it up
    local target
    target="$(readlink "$dst")" || true
    if [ "${target:-}" != "$2" ]; then
      mv -v "$dst" "${dst}.bak.$(ts)"
    fi
  fi
}

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$HOME/.tmux"

# Link configuration files
files=(
    "$repo_dir/tmux/tmux.conf:$HOME/.tmux.conf"
    "$repo_dir/tmux/mac.conf:$HOME/.tmux/mac.conf"
    "$repo_dir/tmux/linux.conf:$HOME/.tmux/linux.conf"
)

for mapping in "${files[@]}"; do
    src="${mapping%:*}"
    dst="${mapping#*:}"
    backup "$dst" "$src"
    ln -sfn "$src" "$dst"
    echo "Linked: $dst -> $src"
done

echo "Done. You can now start tmux and run: prefix + I (to install plugins)."