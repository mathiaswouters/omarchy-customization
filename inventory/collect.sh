#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Omarchy baseline inventory
# --------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Default output:
# inventory/baseline-YYYY-MM-DD
#
# Optional custom output:
# ./collect.sh /path/to/output

OUT="${1:-"$SCRIPT_DIR/baseline-$(date +%F)"}"

PACKAGES="$OUT/packages"
APPLICATIONS="$OUT/applications"
CONFIGURATION="$OUT/configuration"
SYSTEM="$OUT/system"

# --------------------------------------------------
# Create directories
# --------------------------------------------------

mkdir -p \
    "$PACKAGES" \
    "$APPLICATIONS" \
    "$CONFIGURATION" \
    "$SYSTEM"

echo "Collecting Omarchy baseline..."
echo "Output: $OUT"


# --------------------------------------------------
# Packages
# --------------------------------------------------

echo "Collecting packages..."

# Helper for package queries that may return no results
collect_optional() {
    local output="$1"
    shift

    if "$@" > "$output"; then
        return 0
    else
        local status=$?

        if [[ "$status" -eq 1 ]]; then
            # No matching packages
            : > "$output"
            return 0
        fi

        echo "WARNING: Command failed: $*" >&2
        echo "Exit status: $status" >&2

        return "$status"
    fi
}

# All installed packages
pacman -Qq \
    > "$PACKAGES/packages-all.txt"

# Explicitly installed packages
pacman -Qqe \
    > "$PACKAGES/packages-explicit.txt"

# Explicitly installed native packages
pacman -Qqen \
    > "$PACKAGES/packages-explicit-native.txt"

# Explicitly installed foreign packages
collect_optional \
    "$PACKAGES/packages-foreign.txt" \
    pacman -Qqm

# Dependency-installed packages
collect_optional \
    "$PACKAGES/packages-dependencies.txt" \
    pacman -Qqd

echo "Package collection completed."

# --------------------------------------------------
# Applications
# --------------------------------------------------

echo "Collecting applications..."

# Desktop application launchers
find /usr/share/applications \
    -maxdepth 1 \
    -type f \
    -name '*.desktop' \
    | sort \
    > "$APPLICATIONS/desktop-launchers.txt"

# User-local executable files
if [[ -d "$HOME/.local/bin" ]]; then
    find "$HOME/.local/bin" \
        -maxdepth 1 \
        -type f \
        | sort \
        > "$APPLICATIONS/local-bin.txt"
else
    touch "$APPLICATIONS/local-bin.txt"
fi

# Omarchy commands
if command -v omarchy >/dev/null 2>&1; then
    omarchy commands --json \
        > "$APPLICATIONS/omarchy-commands.json" \
        2>/dev/null || true
else
    echo "Omarchy command not found." \
        > "$APPLICATIONS/omarchy-commands.txt"
fi

# --------------------------------------------------
# Configuration
# --------------------------------------------------

echo "Collecting configuration..."

# User configuration files
if [[ -d "$HOME/.config" ]]; then
    find "$HOME/.config" \
        -type f \
        | sort \
        > "$CONFIGURATION/config-files.txt"
else
    touch "$CONFIGURATION/config-files.txt"
fi

# System configuration files
find /etc \
    -maxdepth 2 \
    -type f \
    | sort \
    > "$CONFIGURATION/system-config-files.txt"

# Omarchy keybindings
if command -v omarchy >/dev/null 2>&1; then
    omarchy menu keybindings --print \
        > "$CONFIGURATION/keybindings.txt" \
        2>/dev/null || true
fi

# Enabled system services
systemctl list-unit-files \
    --state=enabled \
    > "$CONFIGURATION/units-system.txt"

# Enabled user services
systemctl --user list-unit-files \
    --state=enabled \
    > "$CONFIGURATION/units-user.txt" \
    2>/dev/null || true

# User identity and groups
id \
    > "$CONFIGURATION/id.txt"

# Sudoers configuration inventory
if [[ -d /etc/sudoers.d ]]; then
    find /etc/sudoers.d \
        -maxdepth 1 \
        -type f \
        | sort \
        > "$CONFIGURATION/sudoers.txt"
else
    touch "$CONFIGURATION/sudoers.txt"
fi

# --------------------------------------------------
# Omarchy configuration backup
# --------------------------------------------------

echo "Backing up Omarchy configuration..."

if [[ -d "$HOME/.config/omarchy" ]]; then
    cp -a \
        "$HOME/.config/omarchy" \
        "$CONFIGURATION/omarchy-config"
fi

# --------------------------------------------------
# System information
# --------------------------------------------------

echo "Collecting system information..."

# Omarchy version
if command -v omarchy-version >/dev/null 2>&1; then
    omarchy-version \
        > "$SYSTEM/omarchy-version.txt" \
        2>/dev/null || true
fi

# OS information
if [[ -f /etc/os-release ]]; then
    cp /etc/os-release "$SYSTEM/os-release.txt"
fi

# Kernel
uname -a \
    > "$SYSTEM/kernel.txt"

# Pacman version
pacman --version \
    > "$SYSTEM/pacman-version.txt"

# --------------------------------------------------
# Finished
# --------------------------------------------------

echo
echo "Omarchy baseline collection completed."
echo
echo "Output directory:"
echo "$OUT"
