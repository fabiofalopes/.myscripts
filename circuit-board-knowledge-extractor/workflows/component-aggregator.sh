#!/bin/bash
# component-aggregator.sh
# Aggregates components from Pass 1 JSON files into a consolidated database

set -e

BASE_DIR="$HOME/.myscripts/circuit-board-knowledge-extractor"
DATA_DIR="$BASE_DIR/data/pass1"
OUTPUT_DIR="$BASE_DIR/data/pass2"
LIB_DIR="$BASE_DIR/lib"

mkdir -p "$OUTPUT_DIR"

echo "Extracting components from $DATA_DIR..."

TEMP_FILE=$(mktemp)
# Initialize JSON array
echo "[" > "$TEMP_FILE"
FIRST=true

# Check if there are any JSON files
shopt -s nullglob
files=("$DATA_DIR"/*.json)
if [ ${#files[@]} -eq 0 ]; then
    echo "No JSON files found in $DATA_DIR"
    exit 1
fi

for json_file in "${files[@]}"; do
    filename=$(basename "$json_file")
    
    # Run jq script and read output line by line
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                echo "," >> "$TEMP_FILE"
            fi
            
            # Escape backslashes and quotes for JSON
            safe_line=$(echo "$line" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
            echo "{\"text\": \"$safe_line\", \"source\": \"$filename\"}" >> "$TEMP_FILE"
        fi
    done < <(jq -r -f "$LIB_DIR/extract-components.jq" "$json_file")
done

echo "]" >> "$TEMP_FILE"

echo "Grouping components..."
python3 "$LIB_DIR/similarity_matcher.py" "$TEMP_FILE" > "$OUTPUT_DIR/component-database.json"

echo "Done. Database saved to $OUTPUT_DIR/component-database.json"
rm "$TEMP_FILE"
