#!/bin/bash

set -euo pipefail

# ==================================================
# Omarchy baseline inventory
#
# Collects:
#   - Installed packages
#   - Applications
#   - User and system configuration
#   - Omarchy configuration
#   - Services
#   - System information
#
# Usage:
#   ./inventory/collect.sh
#
# Optional custom output:
#   ./inventory/collect.sh /path/to/output
# ==================================================


# --------------------------------------------------
# Paths
# --------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

DATE="$(date +%F)"

OUT="${1:-"$SCRIPT_DIR/baseline-$DATE"}"

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


# --------------------------------------------------
# Collection status
# --------------------------------------------------

WARNINGS=0

warning() {
    echo "WARNING: $*" >&2
    WARNINGS=$((WARNINGS + 1))
}

section() {
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

# Execute an optional command.
#
# Exit status 1 is treated as an empty result.
# Other failures are recorded as warnings.
#
# Usage:
#   collect_optional output-file command arguments...

collect_optional() {
    local output="$1"
    shift

    if "$@" > "$output"; then
        return 0
    else
        local status=$?

        if [[ "$status" -eq 1 ]]; then
            : > "$output"
            return 0
        fi

        warning "Command failed: $* (exit status: $status)"

        return 0
    fi
}

# Collect a find-based inventory.
#
# Permission errors are written to a separate file.
# Partial results are preserved.
#
# Usage:
#   collect_find output-file error-file find-arguments...

collect_find() {
    local output="$1"
    local errors="$2"

    shift 2

    local status=0

    if find "$@" \
        > "$output" \
        2> "$errors"
    then
        status=0
    else
        status=$?
    fi

    if [[ "$status" -ne 0 ]]; then
        warning "find completed with errors. See: $errors"
    fi

    # Sort the collected results.
    if [[ -f "$output" ]]; then
        sort -o "$output" "$output"
    fi

    # Remove empty error files.
    if [[ ! -s "$errors" ]]; then
        rm -f "$errors"
    fi

    return 0
}


# --------------------------------------------------
# Start
# --------------------------------------------------

section "Omarchy baseline inventory"

echo "Date:   $DATE"
echo "Output: $OUT"

echo
echo "Starting collection..."


# --------------------------------------------------
# 1. Packages
# --------------------------------------------------

section "1/4 Collecting packages"

echo "Collecting all installed packages..."

pacman -Qq \
    > "$PACKAGES/packages-all.txt"

echo "Collecting explicitly installed packages..."

pacman -Qqe \
    > "$PACKAGES/packages-explicit.txt"

echo "Collecting explicitly installed native packages..."

pacman -Qqen \
    > "$PACKAGES/packages-explicit-native.txt"

echo "Collecting foreign packages..."

collect_optional \
    "$PACKAGES/packages-foreign.txt" \
    pacman -Qqm

echo "Collecting dependency-installed packages..."

collect_optional \
    "$PACKAGES/packages-dependencies.txt" \
    pacman -Qqd

echo "Collecting package collection summary..."

{
    echo "All installed packages:"

    wc -l < "$PACKAGES/packages-all.txt"

    echo

    echo "Explicit packages:"

    wc -l < "$PACKAGES/packages-explicit.txt"

    echo

    echo "Foreign packages:"

    wc -l < "$PACKAGES/packages-foreign.txt"

    echo

    echo "Dependency packages:"

    wc -l < "$PACKAGES/packages-dependencies.txt"

} > "$PACKAGES/packages-summary.txt"

echo "Package collection completed."


# --------------------------------------------------
# 2. Applications
# --------------------------------------------------

section "2/4 Collecting applications"

echo "Collecting desktop launchers..."

collect_find \
    "$APPLICATIONS/desktop-launchers.txt" \
    "$APPLICATIONS/desktop-launchers-errors.txt" \
    /usr/share/applications \
    -maxdepth 1 \
    -type f \
    -name '*.desktop' \
    -print

echo "Collecting user-local binaries..."

if [[ -d "$HOME/.local/bin" ]]; then

    collect_find \
        "$APPLICATIONS/local-bin.txt" \
        "$APPLICATIONS/local-bin-errors.txt" \
        "$HOME/.local/bin" \
        -maxdepth 1 \
        -type f \
        -print

else

    touch "$APPLICATIONS/local-bin.txt"

fi


# Omarchy commands

echo "Collecting Omarchy commands..."

if command -v omarchy >/dev/null 2>&1; then

    collect_optional \
        "$APPLICATIONS/omarchy-commands.json" \
        omarchy commands --json

else

    echo "Omarchy command not found." \
        > "$APPLICATIONS/omarchy-commands.txt"

    warning "Omarchy command is unavailable."

fi


# --------------------------------------------------
# 3. Configuration
# --------------------------------------------------

section "3/4 Collecting configuration"

echo "Collecting user configuration files..."

if [[ -d "$HOME/.config" ]]; then

    collect_find \
        "$CONFIGURATION/config-files.txt" \
        "$CONFIGURATION/config-files-errors.txt" \
        "$HOME/.config" \
        -type f \
        -print

else

    touch "$CONFIGURATION/config-files.txt"

    warning "User configuration directory not found."

fi


# System configuration files

echo "Collecting system configuration files..."

collect_find \
    "$CONFIGURATION/system-config-files.txt" \
    "$CONFIGURATION/system-config-errors.txt" \
    /etc \
    -maxdepth 2 \
    -type f \
    -print


# Omarchy keybindings

echo "Collecting Omarchy keybindings..."

if command -v omarchy >/dev/null 2>&1; then

    collect_optional \
        "$CONFIGURATION/keybindings.txt" \
        omarchy menu keybindings --print

else

    echo "Omarchy command not found." \
        > "$CONFIGURATION/keybindings.txt"

fi


# Enabled system services

echo "Collecting enabled system services..."

if systemctl list-unit-files \
    --state=enabled \
    > "$CONFIGURATION/units-system.txt" \
    2> "$CONFIGURATION/units-system-errors.txt"
then

    echo "System services collected."

else

    warning "System service collection returned an error."

fi

if [[ ! -s "$CONFIGURATION/units-system-errors.txt" ]]; then
    rm -f "$CONFIGURATION/units-system-errors.txt"
fi


# Enabled user services

echo "Collecting enabled user services..."

if systemctl --user list-unit-files \
    --state=enabled \
    > "$CONFIGURATION/units-user.txt" \
    2> "$CONFIGURATION/units-user-errors.txt"
then

    echo "User services collected."

else

    warning "User service collection returned an error."

fi

if [[ ! -s "$CONFIGURATION/units-user-errors.txt" ]]; then
    rm -f "$CONFIGURATION/units-user-errors.txt"
fi


# User identity

echo "Collecting user identity..."

id \
    > "$CONFIGURATION/id.txt"


# Sudoers inventory

echo "Collecting sudoers inventory..."

if [[ -d /etc/sudoers.d ]]; then

    collect_find \
        "$CONFIGURATION/sudoers.txt" \
        "$CONFIGURATION/sudoers-errors.txt" \
        /etc/sudoers.d \
        -maxdepth 1 \
        -type f \
        -print

else

    echo "/etc/sudoers.d does not exist." \
        > "$CONFIGURATION/sudoers.txt"

fi


# Omarchy configuration backup

echo "Backing up Omarchy configuration..."

if [[ -d "$HOME/.config/omarchy" ]]; then

    cp -a \
        "$HOME/.config/omarchy" \
        "$CONFIGURATION/omarchy-config"

else

    echo "Omarchy configuration directory not found." \
        > "$CONFIGURATION/omarchy-config-not-found.txt"

    warning "Omarchy configuration directory not found."

fi


# --------------------------------------------------
# 4. System information
# --------------------------------------------------

section "4/4 Collecting system information"


# Omarchy version

echo "Collecting Omarchy version..."

if command -v omarchy-version >/dev/null 2>&1; then

    collect_optional \
        "$SYSTEM/omarchy-version.txt" \
        omarchy-version

else

    echo "omarchy-version command not found." \
        > "$SYSTEM/omarchy-version.txt"

fi


# OS information

echo "Collecting OS information..."

if [[ -f /etc/os-release ]]; then

    cp \
        /etc/os-release \
        "$SYSTEM/os-release.txt"

else

    warning "/etc/os-release not found."

fi


# Kernel

echo "Collecting kernel information..."

uname -a \
    > "$SYSTEM/kernel.txt"


# Pacman version

echo "Collecting pacman version..."

pacman --version \
    > "$SYSTEM/pacman-version.txt"


# --------------------------------------------------
# Completion
# --------------------------------------------------

section "Inventory completed"

echo "Output directory:"
echo "$OUT"

echo

echo "Collected files:"

find "$OUT" \
    -type f \
    | sort

echo

if [[ "$WARNINGS" -gt 0 ]]; then

    echo "Completed with $WARNINGS warning(s)."

else

    echo "Completed without warnings."

fi

echo

echo "Omarchy baseline collection finished."
