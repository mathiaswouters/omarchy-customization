#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="scripts"

# Verify the scripts directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Error: '$SCRIPT_DIR' directory not found."
    exit 1
fi

echo "--- Phase 1: Running Installation Scripts ---"
# Loop only through top-level files in the scripts folder
for script in "$SCRIPT_DIR"/*; do
    # Ensure it is a file, executable, and contains 'install' in the name
    if [ -f "$script" ] && [ -x "$script" ] && [[ "$(basename "$script")" == *install* ]]; then
        echo "Executing: $script"
        "$script"
    fi
done

echo "--- Phase 2: Running Remaining Configuration Scripts ---"
for script in "$SCRIPT_DIR"/*; do
    # Ensure it is a file, executable, and does NOT contain 'install' in the name
    if [ -f "$script" ] && [ -x "$script" ] && [[ "$(basename "$script")" != *install* ]]; then
        echo "Executing: $script"
        "$script"
    fi
done

echo "--- Customization Complete! ---"
