#!/bin/bash
# Launch OpenCode Observability Monitoring Dashboard
# Creates a tmux session with explicit window names for monitoring OpenCode AI usage
# Session persists through reboots via tmux-resurrect/continuum

set -e

SESSION_NAME="opencode-observability-monitoring"

# Check if ocmonitor is available
OCMONITOR_CMD="ocmonitor"

if ! command -v ocmonitor &> /dev/null; then
    # Try to find it in known location
    KNOWN_PATH="$HOME/projetos/hub/ocmonitor-share/venv/bin/ocmonitor"
    if [ -f "$KNOWN_PATH" ]; then
        OCMONITOR_CMD="$KNOWN_PATH"
    else
        echo "❌ Error: ocmonitor not found in PATH or at $KNOWN_PATH"
        echo "Install from: https://github.com/Shlomob/ocmonitor-share"
        exit 1
    fi
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "✓ Session '$SESSION_NAME' already exists"
    if [ -n "$TMUX" ]; then
        echo "🔄 Switching to existing session (parallel)..."
        tmux switch-client -t "$SESSION_NAME"
    else
        echo "Attaching to existing session..."
        tmux attach-session -t "$SESSION_NAME"
    fi
    exit 0
fi

echo "=== Starting OpenCode Observability Monitoring Dashboard ==="
echo ""

# Create new session (detached)
# Note: This creates the first window. We don't assume index 0 or 1.
tmux new-session -d -s "$SESSION_NAME" -n "ocmonitor-live-feed"

# Window: Live monitoring feed (Targeting the window we just created by name)
echo "Configuring window: ocmonitor-live-feed"
tmux send-keys -t "$SESSION_NAME:ocmonitor-live-feed" "$OCMONITOR_CMD live" C-m

# Window: Daily costs with breakdown
echo "Creating window: ocmonitor-daily-costs"
tmux new-window -t "$SESSION_NAME:" -n "ocmonitor-daily-costs"
tmux send-keys -t "$SESSION_NAME:ocmonitor-daily-costs" "watch -n 60 --color '$OCMONITOR_CMD daily --breakdown'" C-m

# Window: Model usage breakdown
echo "Creating window: ocmonitor-model-breakdown"
tmux new-window -t "$SESSION_NAME:" -n "ocmonitor-model-breakdown"
tmux send-keys -t "$SESSION_NAME:ocmonitor-model-breakdown" "watch -n 300 --color '$OCMONITOR_CMD models'" C-m

# Window: Session history browser
echo "Creating window: ocmonitor-session-history"
tmux new-window -t "$SESSION_NAME:" -n "ocmonitor-session-history"
tmux send-keys -t "$SESSION_NAME:ocmonitor-session-history" "$OCMONITOR_CMD sessions" C-m

# Window: OpenCode logs (tail)
echo "Creating window: opencode-logs-tail"
tmux new-window -t "$SESSION_NAME:" -n "opencode-logs-tail"
LOG_DIR="$HOME/.local/share/opencode/log"
if [ -d "$LOG_DIR" ]; then
    # Use ccze for colored logs if available, otherwise plain tail
    if command -v ccze &> /dev/null; then
        tmux send-keys -t "$SESSION_NAME:opencode-logs-tail" "tail -f $LOG_DIR/*.log | ccze -A" C-m
    else
        tmux send-keys -t "$SESSION_NAME:opencode-logs-tail" "tail -f $LOG_DIR/*.log" C-m
    fi
else
    tmux send-keys -t "$SESSION_NAME:opencode-logs-tail" "echo 'OpenCode log directory not found: $LOG_DIR'" C-m
fi

# Window: Workspace for ad-hoc commands
echo "Creating window: workspace"
tmux new-window -t "$SESSION_NAME:" -n "workspace"
tmux send-keys -t "$SESSION_NAME:workspace" "cd ~/.myscripts" C-m
tmux send-keys -t "$SESSION_NAME:workspace" "echo 'OpenCode Observability Workspace'" C-m
tmux send-keys -t "$SESSION_NAME:workspace" "echo 'Available commands: ocmonitor sessions, ocmonitor export, etc.'" C-m

# Select the live feed window
tmux select-window -t "$SESSION_NAME:ocmonitor-live-feed"

echo ""
echo "✅ Dashboard created successfully!"
echo "Session: $SESSION_NAME"

if [ -n "$TMUX" ]; then
    echo "🔄 Switching to new session (parallel)..."
    tmux switch-client -t "$SESSION_NAME"
else
    echo "Attaching to session..."
    tmux attach-session -t "$SESSION_NAME"
fi
