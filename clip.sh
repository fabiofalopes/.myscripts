#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: clip [OPTIONS] <filename>"
    echo "Description: Copies the contents of a file to the clipboard"
    echo "Options:"
    echo "  -h    Display this help message."
}

# Function to copy a file's content to the clipboard
clip() {
    if [ "$#" -eq 0 ]; then
        echo "Error: No filename provided."
        show_help
        return 1
    fi

    if [ "$1" == "-h" ]; then
        show_help
        return 0
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File '$1' not found."
        return 1
    fi

    cat "$1" | xclip -selection clipboard
    echo "Content of '$1' copied to clipboard."
}

# Main function
main() {
    if [ "$#" -eq 0 ]; then
        echo "Error: No filename provided."
        show_help
        return 1
    fi

    if [ "$1" == "-h" ]; then
        show_help
        return 0
    fi

    clip "$@"
}

# Execute main function
main "$@"


