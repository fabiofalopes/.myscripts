#!/bin/bash
# Wrapper to handle fabric/fabric-ai alias with model selection

# Function to call fabric with optional model
fabric_call() {
    local cmd=""
    
    # Determine which fabric command is available
    if command -v fabric-ai &> /dev/null; then
        cmd="fabric-ai"
    elif command -v fabric &> /dev/null; then
        cmd="fabric"
    else
        echo "Error: fabric not found" >&2
        return 1
    fi
    
    # Add model if FABRIC_MODEL is set
    if [ -n "$FABRIC_MODEL" ]; then
        $cmd --model "$FABRIC_MODEL" "$@"
    else
        $cmd "$@"
    fi
}

# If called directly (not sourced), execute
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    fabric_call "$@"
fi
