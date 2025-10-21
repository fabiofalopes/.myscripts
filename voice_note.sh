#!/usr/bin/env bash

# ---------------------------------------------
# voice_note.sh - Full lifecycle voice note script
# Supports optional initial text input for VoiceNode
# ---------------------------------------------

set -euo pipefail

# ------------------------
# Detect fabric command
# ------------------------
if command -v fabric-ai &> /dev/null; then
    FABRIC_CMD="fabric-ai"
elif command -v fabric &> /dev/null; then
    FABRIC_CMD="fabric"
else
    echo "Error: Neither 'fabric' nor 'fabric-ai' command found."
    echo "Please install fabric: https://github.com/danielmiessler/fabric"
    exit 1
fi

# ------------------------
# Configuration
# ------------------------
PROJECT_DIR="$HOME/Documents/projetos/hub/voice_note"
TRANSCRIPTS_DIR="$PROJECT_DIR/transcripts"

# ------------------------
# Parse optional text input
# ------------------------
# If provided as first argument, use it
USER_INPUT="${1:-}"

# ------------------------
# Ensure directories exist
# ------------------------
mkdir -p "$TRANSCRIPTS_DIR"

# ------------------------
# Move into project & activate venv
# ------------------------
cd "$PROJECT_DIR" || { echo "Cannot cd into $PROJECT_DIR"; exit 1; }
source venv/bin/activate || { echo "Cannot activate virtualenv"; exit 1; }

# ------------------------
# Run interactive recording and transcription
# ------------------------
echo "=== Starting interactive recording via transcribe.py ==="
echo "Speak into the mic. Stop the recording when finished."
python transcribe.py

# ------------------------
# Capture transcription from clipboard
# ------------------------
TRANSCRIPTION=$(pbpaste)

if [[ -z "$TRANSCRIPTION" ]]; then
  echo "No transcription detected in clipboard!"
  exit 1
fi

# ------------------------
# Merge optional user input
# ------------------------
if [[ -n "$USER_INPUT" ]]; then
  COMBINED_TEXT="$USER_INPUT"$'\n'"$TRANSCRIPTION"
else
  COMBINED_TEXT="$TRANSCRIPTION"
fi

# ------------------------
# Generate timestamped JSON filename
# ------------------------
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
JSON_FILE="$TRANSCRIPTS_DIR/recording_${TIMESTAMP}.json"

# ------------------------
# Save initial JSON with raw transcription (and optional user input)
# ------------------------
jq -n --arg raw "$COMBINED_TEXT" '{raw_transcription: $raw}' > "$JSON_FILE"

# ------------------------
# Run Fabric AI pipeline
# ------------------------
echo "=== Running Fabric AI pipeline ==="
ANALYZED=$(echo "$COMBINED_TEXT" | "$FABRIC_CMD" -p transcript-analyzer)
REFINED=$(echo -e "$ANALYZED\n$COMBINED_TEXT" | "$FABRIC_CMD" -p transcript-refiner)

# ------------------------
# Save full JSON lifecycle
# ------------------------
jq -n \
  --arg raw "$COMBINED_TEXT" \
  --arg analyzer "$ANALYZED" \
  --arg refiner "$REFINED" \
  '{
    raw_transcription: $raw,
    analyzer_output: $analyzer,
    refiner_output: $refiner
  }' > "$JSON_FILE"

# ------------------------
# Copy final refined text to clipboard
# ------------------------
echo "$REFINED" | pbcopy

# ------------------------
# Summary
# ------------------------
echo "=== Done! ==="
echo "JSON file:  $JSON_FILE"
echo "Refined transcription copied to clipboard."

