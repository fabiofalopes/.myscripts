#!/bin/bash

# Session Name
SESSION="main"

# Start new session with our name
tmux new-session -d -s $SESSION

# ------

# Window 1: System monitoring with 3 panes
tmux rename-window -t $SESSION:1 'system'

# Start with a clean window and send neofetch to first pane
tmux send-keys -t $SESSION:1 'clear; neofetch' C-m

# Create right split (this becomes pane 2)
tmux split-window -h -t $SESSION:1
# Make the right split smaller
tmux resize-pane -t $SESSION:1.2 -x 60

# Split the right pane vertically (this becomes pane 3)
tmux split-window -v -t $SESSION:1.2

# Now send commands to specific panes
tmux send-keys -t $SESSION:1.2 'htop' C-m
tmux send-keys -t $SESSION:1.3 'watch -n 2 "df -h / && echo -e \"\nMemory Usage:\" && free -h && echo -e \"\nLoad Average:\" && uptime"' C-m

# Select the main left pane
tmux select-pane -t $SESSION:1.1

# ------

# ------

# Window 2: Voice Note project
tmux new-window -t $SESSION:2 -n 'voice-note'
tmux send-keys -t $SESSION:2 'cd ~/projetos/hub/voice_note/' C-m

# ------

# ------

# Window 3: Configs with four-way split
tmux new-window -t $SESSION:3 -n 'configs'

# First pane (top-left): ~/.myscripts
tmux send-keys -t $SESSION:3 'cd ~/.myscripts' C-m

# Create second pane (top-right): ~/.myservices
tmux split-window -h -t $SESSION:3
tmux send-keys -t $SESSION:3.2 'cd ~/.myservices' C-m

# Create third pane (bottom-left): ~/
tmux split-window -v -t $SESSION:3.1
tmux send-keys -t $SESSION:3.3 'cd ~' C-m

# Create fourth pane (bottom-right): ~/.config
tmux split-window -v -t $SESSION:3.2
tmux send-keys -t $SESSION:3.4 'cd ~/.config' C-m

# Optional: Make all panes equal size
tmux select-layout -t $SESSION:3 tiled

# ------

# Select the first pane
tmux select-pane -t $SESSION:3.1

# Select window number 
tmux select-window -t $SESSION:2

# Attach to session
tmux attach-session -t $SESSION
