#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

SCRIPT_DIR="scripts"

# Verify the scripts directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Error: '$SCRIPT_DIR' directory not found."
    exit 1
fi

# Helper function to log and source a script
run_script() {
    local script_path="$1"
    local script_name
    script_name=$(basename "$script_path")
    
    echo "=== Executing: $script_name ==="
    . "$script_path"
    echo "--- Finished: $script_name ---"
    echo "" # Adds a blank line for better readability
}

# Execute each script using the helper function
run_script ./"$SCRIPT_DIR"/install-zsh.sh
run_script ./"$SCRIPT_DIR"/install-tmux.sh
run_script ./"$SCRIPT_DIR"/install-yazi.sh
run_script ./"$SCRIPT_DIR"/install-stow.sh
run_script ./"$SCRIPT_DIR"/install-dotfiles.sh
run_script ./ "$SCRIPT_DIR"/install-hyprland-overrides.sh
run_script ./"$SCRIPT_DIR"/set-shell.sh

echo "--- Customization Complete! ---"
