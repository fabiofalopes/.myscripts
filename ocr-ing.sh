#!/bin/bash

# Check if ocrmypdf is installed
command -v ocrmypdf >/dev/null 2>&1 || { echo >&2 "ocrmypdf is not installed. Aborting."; exit 1; }

# Function to perform OCR on PDF
perform_ocr() {
    input_pdf="$1"
    output_pdf="${input_pdf%.pdf}_ocr.pdf"  # Output PDF with OCR text layer

    echo "Performing OCR on $input_pdf..."

    # Run ocrmypdf to perform OCR with --force-ocr option
    #ocrmypdf --force-ocr "$input_pdf" "$output_pdf"
    ocrmypdf --skip-text "$input_pdf" "$output_pdf"

    if [ $? -eq 0 ]; then
        echo "OCR completed successfully."
        echo "Output PDF with OCR: $output_pdf"
    else
        echo "OCR process failed. Please check the input PDF and try again."
    fi
}

# Main script
if [ $# -ne 1 ]; then
    echo "Usage: $0 input_pdf_file"
    exit 1
fi

input_pdf="$1"

# Check if input PDF file exists
if [ ! -f "$input_pdf" ]; then
    echo "Error: Input PDF file '$input_pdf' not found."
    exit 1
fi

# Perform OCR on the input PDF
perform_ocr "$input_pdf"

