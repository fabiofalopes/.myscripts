#!/bin/bash
# Wrapper to handle fabric/fabric-ai alias
if command -v fabric-ai &> /dev/null; then
    fabric-ai "$@"
elif command -v fabric &> /dev/null; then
    fabric "$@"
else
    echo "Error: fabric not found" >&2
    exit 1
fi
