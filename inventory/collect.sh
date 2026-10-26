#!/usr/bin/env bash
out=./omarchy-inventory-$(date +%F); mkdir -p "$out"
pacman -Qqe            > "$out/pkgs-explicit.txt"
pacman -Qqm            > "$out/pkgs-aur-foreign.txt"
find ~/.local/bin -type f | sort > "$out/local-bin.txt"
systemctl list-unit-files --state=enabled > "$out/units-system.txt"
systemctl --user list-unit-files --state=enabled > "$out/units-user.txt"
omarchy commands --json > "$out/omarchy-commands.json" 2>/dev/null
omarchy menu keybindings --print > "$out/keybindings.txt" 2>/dev/null
find ~/.config -type f | sort > "$out/config-files.txt"
find /etc -maxdepth 2 -type f | sort > "$out/system-config-files.txt"
cp -r ~/.config/omarchy "$out/omarchy-config" 2>/dev/null
id > "$out/id.txt"; ls /etc/sudoers.d > "$out/sudoers.txt"
