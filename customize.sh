#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Get the absolute path of the directory where customize.sh is located
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$BASE_DIR/scripts"

# Helper function to log and source a script using absolute paths
run_script() {
    local script_name="$1"
    local script_path="$SCRIPT_DIR/$script_name"
    
    echo "=== Executing: $script_name ==="
    . "$script_path"
    echo "--- Finished: $script_name ---"
    echo "" 
}

# Execute each script by name only
run_script "install-zsh.sh"
run_script "install-tmux.sh"
run_script "install-yazi.sh"
run_script "install-stow.sh"
run_script "install-dotfiles.sh"
run_script "install-hyprland-overrides.sh"
run_script "set-shell.sh"

echo "--- Customization Complete! ---"
