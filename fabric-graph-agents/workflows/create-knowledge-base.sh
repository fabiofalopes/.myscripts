#!/bin/bash
# Simple one-command knowledge base creator

INPUT_FILE="$1"
OUTPUT_DIR="${2:-./kb-$(date +%Y%m%d-%H%M%S)}"

# Model selection: use environment variable or default
MODEL="${FABRIC_MODEL:-}"

if [ -z "$INPUT_FILE" ]; then
    echo "Usage: $0 <input_file> [output_dir]"
    echo ""
    echo "Example:"
    echo "  $0 my-rambling.txt"
    echo "  $0 my-notes.md ./my-kb"
    echo ""
    echo "Model Selection:"
    echo "  FABRIC_MODEL=openai/gpt-4o $0 my-rambling.txt"
    echo "  FABRIC_MODEL=anthropic/claude-3.5-sonnet $0 my-rambling.txt"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File not found: $INPUT_FILE"
    exit 1
fi

echo "🚀 Creating Knowledge Base from: $INPUT_FILE"
if [ -n "$MODEL" ]; then
    echo "📡 Using model: $MODEL"
fi
echo ""

mkdir -p "$OUTPUT_DIR"

# Build fabric command with optional model
FABRIC_CMD="fabric-ai --pattern dimension_extractor_ultra"
if [ -n "$MODEL" ]; then
    FABRIC_CMD="fabric-ai --model $MODEL --pattern dimension_extractor_ultra"
fi

# Extract dimensions and create files in one go
cat "$INPUT_FILE" | $FABRIC_CMD | \
    sed -n '/^```json/,/^```$/p' | sed '1d;$d' | \
    jq -r '.dimensions[] | "\(.filename)|\(.type)|\(.weight)|\(.content)"' | \
    while IFS='|' read -r filename type weight content; do
        echo "  ✅ Creating: $filename"
        {
            echo "# $(echo $filename | sed 's/.md//' | sed 's/-/ /g')"
            echo ""
            echo "**Type**: $type"
            echo "**Weight**: $weight"
            echo ""
            echo "---"
            echo ""
            echo "$content"
        } > "$OUTPUT_DIR/$filename"
    done

echo ""
echo "✅ Done! Knowledge base created in: $OUTPUT_DIR"
echo ""
echo "📂 View files:"
echo "   ls -la $OUTPUT_DIR"
echo ""
echo "📖 Read a file:"
echo "   cat $OUTPUT_DIR/*.md"
