#!/bin/bash

# Check if input directory is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_directory>"
    exit 1
fi

input_dir="$1"

# Ensure the input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' not found."
    exit 1
fi

# Create mp3_output directory inside the input directory
output_dir="${input_dir}/mp3_output"
mkdir -p "$output_dir"

# Loop through all FLAC files in the input directory
for flac_file in "${input_dir}"/*.flac; do
  if [ -f "$flac_file" ]; then
    # Get the filename without extension
    filename=$(basename -- "$flac_file")
    filename="${filename%.*}"

    # Convert FLAC to MP3 at 320kbps and save in mp3_output directory
    ffmpeg -i "$flac_file" -ab 320k -map_metadata 0 -id3v2_version 3 "${output_dir}/${filename}.mp3"
  fi
done

