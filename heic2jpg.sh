#!/bin/bash
#
# heic2jpg.sh - Bulk convert HEIC images to JPG
#
# PURPOSE:
#   Converts all HEIC (High Efficiency Image Format) files in a directory
#   to JPG format while preserving image quality and EXIF metadata.
#   Useful for processing iPhone/iPad photos for broader compatibility.
#
# USAGE:
#   heic2jpg.sh <input_directory> [quality]
#
# ARGUMENTS:
#   input_directory  Directory containing HEIC files
#   quality          JPG quality 1-100 (default: 90)
#
# EXAMPLES:
#   heic2jpg.sh ~/Pictures/iPhone_Photos        # Default quality (90%)
#   heic2jpg.sh ~/Pictures/iPhone_Photos 95     # High quality
#   heic2jpg.sh ~/Pictures/iPhone_Photos 70     # Smaller files
#
# OUTPUT:
#   Creates jpg_output/ subdirectory with converted JPG files
#   Preserves original filenames (with .jpg extension)
#   Preserves EXIF metadata (date, location, camera info)
#   Creates conversion_errors.log if any files fail
#
# DEPENDENCIES:
#   Requires one of:
#   - ImageMagick 7+ (magick command) with libheif support
#   - ImageMagick 6  (convert command) with libheif support
#   - heif-convert   (from libheif-examples package)
#
# INSTALLATION:
#   Debian/Ubuntu:
#     sudo apt install imagemagick libheif-dev libheif-examples
#   Fedora:
#     sudo dnf install ImageMagick libheif-tools
#   macOS:
#     brew install imagemagick libheif
#
# NOTES:
#   - Original HEIC files are NOT modified
#   - HEIC files detected case-insensitively (.heic, .HEIC, .Heic)
#   - Failed conversions logged but don't stop the process
#   - Output directory reused if it already exists
#
# VERSION: 1.0.0
# AUTHOR:  Part of .myscripts collection
#

set -euo pipefail

# Default settings
DEFAULT_QUALITY=90

# Colors (auto-disable if not a terminal)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

# Usage function
usage() {
    cat <<EOF
Usage: $(basename "$0") <input_directory> [quality]

Bulk convert HEIC images to JPG format.

Arguments:
  input_directory  Directory containing HEIC files
  quality          JPG quality 1-100 (default: $DEFAULT_QUALITY)

Examples:
  $(basename "$0") ~/Pictures/iPhone_Photos
  $(basename "$0") ~/Pictures/iPhone_Photos 95
  $(basename "$0") . 80

Output:
  Creates jpg_output/ subdirectory with converted JPG files
  Original files are preserved

EOF
    exit 1
}

# Error logging function
log_error() {
    local filename="$1"
    local error_msg="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $filename: $error_msg" >> "$error_log"
}

# Show installation instructions
show_install_instructions() {
    cat <<EOF
Error: No HEIC conversion tool found.

Please install one of the following:

Option 1: ImageMagick (Recommended)
  Debian/Ubuntu: sudo apt install imagemagick libheif-dev
  macOS:        brew install imagemagick libheif

Option 2: heif-convert
  Debian/Ubuntu: sudo apt install libheif-examples
  macOS:        brew install libheif

EOF
    exit 1
}

# Detect available conversion tool
detect_conversion_tool() {
    # Check ImageMagick
    if command -v magick &> /dev/null; then
        # ImageMagick 7+ uses 'magick' command
        if magick identify -list format 2>/dev/null | grep -qi "heic"; then
            echo "magick"
            return 0
        fi
    elif command -v convert &> /dev/null; then
        # ImageMagick 6 uses 'convert' command
        if convert -list format 2>/dev/null | grep -qi "heic"; then
            echo "imagemagick"
            return 0
        fi
    fi
    
    # Check heif-convert
    if command -v heif-convert &> /dev/null; then
        echo "heif-convert"
        return 0
    fi
    
    # No tool found
    echo "none"
    return 1
}

# Conversion function for ImageMagick 7+ (magick command)
convert_with_magick() {
    local input_file="$1"
    local output_file="$2"
    local quality="$3"
    
    magick "$input_file" -quality "$quality" "$output_file" 2>&1
}

# Conversion function for ImageMagick 6 (convert command)
convert_with_imagemagick() {
    local input_file="$1"
    local output_file="$2"
    local quality="$3"
    
    convert "$input_file" -quality "$quality" "$output_file" 2>&1
}

# Conversion function for heif-convert
convert_with_heif() {
    local input_file="$1"
    local output_file="$2"
    local quality="$3"
    
    heif-convert -q "$quality" "$input_file" "$output_file" 2>&1
}

# ============================================================
# Argument parsing
# ============================================================

if [ "$#" -lt 1 ]; then
    echo -e "${RED}Error:${NC} Input directory required"
    usage
fi

input_dir="$1"
quality="${2:-$DEFAULT_QUALITY}"

# Validate quality
if ! [[ "$quality" =~ ^[0-9]+$ ]] || [ "$quality" -lt 1 ] || [ "$quality" -gt 100 ]; then
    echo -e "${RED}Error:${NC} Quality must be between 1 and 100"
    exit 1
fi

# ============================================================
# Tool detection
# ============================================================

CONVERSION_TOOL=$(detect_conversion_tool || true)
if [ "$CONVERSION_TOOL" = "none" ] || [ -z "$CONVERSION_TOOL" ]; then
    show_install_instructions
fi

echo -e "${BOLD}heic2jpg${NC} - HEIC to JPG Converter"
echo "================================"
echo -e "Using conversion tool: ${BLUE}$CONVERSION_TOOL${NC}"

# ============================================================
# Input validation
# ============================================================

if [ ! -d "$input_dir" ]; then
    echo -e "${RED}Error:${NC} Directory '$input_dir' not found"
    exit 1
fi

# Convert to absolute path
input_dir=$(cd "$input_dir" && pwd)

# Count HEIC files (case-insensitive)
shopt -s nocaseglob nullglob
heic_files=("$input_dir"/*.heic)
shopt -u nocaseglob nullglob

if [ ${#heic_files[@]} -eq 0 ]; then
    echo -e "${RED}Error:${NC} No HEIC files found in '$input_dir'"
    exit 1
fi

total_files=${#heic_files[@]}
echo -e "Found ${BOLD}$total_files${NC} HEIC file(s) to convert"
echo -e "Quality: ${BOLD}$quality%${NC}"
echo ""

# ============================================================
# Output directory setup
# ============================================================

output_dir="${input_dir}/jpg_output"
mkdir -p "$output_dir"

error_log="${output_dir}/conversion_errors.log"

# Clear previous error log if exists
> "$error_log"

echo -e "Output: ${BLUE}$output_dir${NC}"
echo "Starting conversion..."
echo ""

# ============================================================
# Main conversion loop
# ============================================================

converted=0
failed=0
current=0

shopt -s nocaseglob
for heic_file in "${input_dir}"/*.heic; do
    # Get filename without extension
    filename=$(basename "$heic_file")
    base_filename="${filename%.*}"
    
    # Progress counter
    ((++current))
    echo -e "Converting ${BOLD}$current/$total_files${NC}: $filename"
    
    # Output file path
    output_file="${output_dir}/${base_filename}.jpg"
    
    # Convert based on detected tool
    set +e  # Don't exit on error during conversion
    case "$CONVERSION_TOOL" in
        "magick")
            error_output=$(convert_with_magick "$heic_file" "$output_file" "$quality" 2>&1)
            ;;
        "imagemagick")
            error_output=$(convert_with_imagemagick "$heic_file" "$output_file" "$quality" 2>&1)
            ;;
        "heif-convert")
            error_output=$(convert_with_heif "$heic_file" "$output_file" "$quality" 2>&1)
            ;;
    esac
    conversion_result=$?
    set -e  # Re-enable exit on error
    
    # Check if conversion succeeded
    if [ $conversion_result -eq 0 ] && [ -f "$output_file" ]; then
        echo -e "  ${GREEN}✓${NC} Success"
        converted=$((converted + 1))
    else
        echo -e "  ${RED}✗${NC} Failed (see error log)"
        failed=$((failed + 1))
        log_error "$filename" "${error_output:-Unknown error}"
    fi
done
shopt -u nocaseglob

# ============================================================
# Summary report
# ============================================================

echo ""
echo -e "${BOLD}======================================${NC}"
echo -e "${BOLD}Conversion Complete!${NC}"
echo -e "${BOLD}======================================${NC}"
echo -e "Total files:     ${BOLD}$total_files${NC}"
echo -e "Converted:       ${GREEN}$converted${NC}"
echo -e "Failed:          ${RED}$failed${NC}"
echo ""
echo -e "Output: ${BLUE}$output_dir${NC}"

if [ $failed -gt 0 ]; then
    echo -e "Errors: ${YELLOW}$error_log${NC}"
    echo ""
    echo -e "${YELLOW}⚠ Some files failed to convert. Check error log for details.${NC}"
else
    echo ""
    echo -e "${GREEN}✓ All files converted successfully!${NC}"
    # Remove empty error log
    rm -f "$error_log"
fi
