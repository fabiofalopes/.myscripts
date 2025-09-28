#!/usr/bin/env bash
set -euo pipefail

banner() { printf "\n==== %s ====\n" "$*"; }

banner "System"
uname -a || true
sw_vers 2>/dev/null || true
lsb_release -a 2>/dev/null || true

banner "Shell"
echo "SHELL: ${SHELL:-}"
command -v dscl >/dev/null 2>&1 && dscl . -read ~ UserShell 2>/dev/null | awk '{print "LoginShell:", $2}'
echo "User: $(id -un) (uid: $(id -u))"

banner "Terminal and Colors"
echo "TERM: ${TERM:-}"
echo "TERM_PROGRAM: ${TERM_PROGRAM:-}"
echo "COLORTERM: ${COLORTERM:-}"
tput colors 2>/dev/null || true

banner "Package manager"
if command -v brew >/dev/null 2>&1; then
  echo "brew $(brew --version | head -n1)"
elif command -v apt-get >/dev/null 2>&1; then
  echo "apt-get present"
else
  echo "Unknown"
fi

banner "tmux"
if command -v tmux >/dev/null 2>&1; then
  which tmux
  tmux -V || true
else
  echo "tmux not found in PATH"
fi

banner "Config files"
ls -la "$HOME/.tmux.conf" 2>/dev/null || true
ls -la "$HOME/.config/tmux/tmux.conf" 2>/dev/null || true
ls -la "$HOME/.tmux" 2>/dev/null || true
ls -la "$HOME/.tmux"/*.conf 2>/dev/null || true

banner "TPM and Plugins"
ls -la "$HOME/.tmux/plugins" 2>/dev/null || true
ls -la "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
if [ -d "$HOME/.tmux/plugins" ]; then
  echo "Plugins:"
  ls -1 "$HOME/.tmux/plugins" 2>/dev/null || true
fi

banner "Clipboard"
if command -v pbcopy >/dev/null 2>&1 && command -v pbpaste >/dev/null 2>&1; then
  printf "ok" | pbcopy
  echo "pbcopy/pbpaste test: $(pbpaste)"
else
  echo "pbcopy/pbpaste not found (ok on Linux/mac without GUI)"
fi
command -v xclip >/dev/null 2>&1 && echo "xclip present" || echo "xclip absent"
command -v wl-copy >/dev/null 2>&1 && echo "wl-copy present" || echo "wl-copy absent"
command -v reattach-to-user-namespace >/dev/null 2>&1 && echo "reattach-to-user-namespace present" || echo "reattach-to-user-namespace absent"

banner "Terminfo"
if infocmp -x tmux-256color >/dev/null 2>&1; then
  echo "tmux-256color available"
else
  echo "tmux-256color NOT available"
fi
if infocmp -x screen-256color >/dev/null 2>&1; then
  echo "screen-256color available"
else
  echo "screen-256color NOT available"
fi

banner "tmux Server"
tmux ls 2>/dev/null || echo "no tmux sessions"

banner "Locale"
locale || true

banner "PATH"
echo "$PATH"