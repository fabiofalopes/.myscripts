#!/bin/bash
# Script to apply custom branding to JumpServer

SOURCE_DIR="$(dirname "$0")"
TARGET_DIR="$SOURCE_DIR/../data/static/img"

echo "Applying custom branding..."

# Copy files if they exist
for file in logo.png logo_text.png logo_white.png login_image.png facio.ico; do
    if [ -f "$SOURCE_DIR/$file" ]; then
        cp "$SOURCE_DIR/$file" "$TARGET_DIR/$file"
        echo "Updated: $file"
    else
        echo "Skipped: $file (Not found in custom_branding folder)"
    fi
done

echo "Done! Clear your browser cache and refresh."
