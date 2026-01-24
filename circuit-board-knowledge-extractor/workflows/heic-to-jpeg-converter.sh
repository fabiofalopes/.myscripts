#!/usr/bin/env bash
# heic-to-jpeg-converter.sh - Convert HEIC images to JPEG for circuit board analysis
# Part of Circuit Board Knowledge Extractor project

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <source_dir> [output_dir]

Convert HEIC images to high-quality JPEG format.

Arguments:
  source_dir    Directory containing HEIC images
  output_dir    Output directory (default: <source_dir>/converted)

Options:
  -q, --quality NUM   JPEG quality 1-100 (default: 95)
  -r, --recursive     Process subdirectories
  -s, --skip-existing Skip if JPEG already exists
  -v, --verbose       Verbose output
  -h, --help          Show this help

Examples:
  $(basename "$0") ~/photos/circuit-boards
  $(basename "$0") -q 90 -s ~/photos/circuit-boards ./output
  $(basename "$0") --recursive ~/drive-download

Requires: ImageMagick (magick) or heif-convert
EOF
}

# Default options
QUALITY=95
RECURSIVE=false
SKIP_EXISTING=false
VERBOSE=false

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quality)
            QUALITY="$2"
            shift 2
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -s|--skip-existing)
            SKIP_EXISTING=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}" >&2
            print_usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Validate arguments
if [[ $# -lt 1 ]]; then
    echo -e "${RED}Error: Source directory required${NC}" >&2
    print_usage
    exit 1
fi

SOURCE_DIR="${1%/}"
OUTPUT_DIR="${2:-${SOURCE_DIR}/converted}"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo -e "${RED}Error: Source directory not found: $SOURCE_DIR${NC}" >&2
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Detect conversion tool
if command -v magick &>/dev/null; then
    CONVERTER="magick"
    convert_heic() {
        magick "$1" -quality "$QUALITY" "$2"
    }
elif command -v heif-convert &>/dev/null; then
    CONVERTER="heif-convert"
    convert_heic() {
        heif-convert -q "$QUALITY" "$1" "$2"
    }
else
    echo -e "${RED}Error: No HEIC converter found. Install ImageMagick or libheif-tools${NC}" >&2
    echo "  Ubuntu/Debian: sudo apt install imagemagick libheif-tools"
    echo "  Fedora: sudo dnf install ImageMagick libheif-tools"
    exit 1
fi

echo -e "${BLUE}Using converter: ${CONVERTER}${NC}"
echo -e "${BLUE}Quality: ${QUALITY}%${NC}"
echo -e "${BLUE}Source: ${SOURCE_DIR}${NC}"
echo -e "${BLUE}Output: ${OUTPUT_DIR}${NC}"
echo ""

# Find HEIC files
if $RECURSIVE; then
    find_cmd="find \"$SOURCE_DIR\" -type f \( -iname '*.heic' -o -iname '*.HEIC' \)"
else
    find_cmd="find \"$SOURCE_DIR\" -maxdepth 1 -type f \( -iname '*.heic' -o -iname '*.HEIC' \)"
fi

# Count files
total_files=$(eval "$find_cmd" | wc -l)
if [[ $total_files -eq 0 ]]; then
    echo -e "${YELLOW}No HEIC files found in $SOURCE_DIR${NC}"
    exit 0
fi

echo -e "${GREEN}Found $total_files HEIC file(s) to convert${NC}"
echo ""

# Convert files
converted=0
skipped=0
failed=0

while IFS= read -r heic_file; do
    filename=$(basename "$heic_file")
    base="${filename%.*}"
    output_file="${OUTPUT_DIR}/${base}.jpg"
    
    # Skip if exists
    if $SKIP_EXISTING && [[ -f "$output_file" ]]; then
        if $VERBOSE; then
            echo -e "${YELLOW}SKIP${NC} $filename (exists)"
        fi
        ((skipped++))
        continue
    fi
    
    # Convert
    if $VERBOSE; then
        echo -n "Converting $filename... "
    fi
    
    if convert_heic "$heic_file" "$output_file" 2>/dev/null; then
        ((converted++))
        if $VERBOSE; then
            size=$(du -h "$output_file" | cut -f1)
            echo -e "${GREEN}OK${NC} ($size)"
        else
            echo -e "${GREEN}✓${NC} $filename"
        fi
    else
        ((failed++))
        echo -e "${RED}✗${NC} $filename (conversion failed)"
    fi
done < <(eval "$find_cmd")

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Converted: $converted${NC}"
if [[ $skipped -gt 0 ]]; then
    echo -e "${YELLOW}Skipped:   $skipped${NC}"
fi
if [[ $failed -gt 0 ]]; then
    echo -e "${RED}Failed:    $failed${NC}"
fi
echo -e "${BLUE}Output:    $OUTPUT_DIR${NC}"

# List output files
if $VERBOSE && [[ $converted -gt 0 ]]; then
    echo ""
    echo "Output files:"
    ls -lh "$OUTPUT_DIR"/*.jpg 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}'
fi

exit $([[ $failed -eq 0 ]] && echo 0 || echo 1)
