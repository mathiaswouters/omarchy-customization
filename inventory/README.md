# Omarchy baseline inventory guide

This document explains where to start when reviewing the baseline captured from the fresh Omarchy installation on **2026-10-26**.

The raw inventory is useful as evidence, but it is not a ready-made list of packages to reinstall or remove. Use this guide to understand what each file tells us and what to investigate next.

## Start here

If you only have a few minutes, open these files in order:

1. [System version](baseline-2026-10-26/system/os-release.txt) — identifies the captured Omarchy release.
2. [Explicit package list](baseline-2026-10-26/packages/packages-explicit.txt) — a manageable starting point for reviewing installed software.
3. [Desktop launchers](baseline-2026-10-26/applications/desktop-launchers.txt) — shows launchers available in the desktop application menu.
4. [Omarchy keybindings](baseline-2026-10-26/configuration/keybindings.txt) — a readable list of keyboard shortcuts.
5. [Omarchy shell configuration](baseline-2026-10-26/configuration/omarchy-config/shell.json) — shows the top bar layout and idle timers.
6. [Enabled system services](baseline-2026-10-26/configuration/units-system.txt) and [enabled user services](baseline-2026-10-26/configuration/units-user.txt) — shows what is configured to start automatically.

You generally do **not** need to read the full package list, all 224 keybinding entries, or the entire configuration file inventory line by line.

## What this baseline contains

The captured inventory reports:

| Item | Count / result | How to interpret it |
|---|---:|---|
| Installed packages | 1,018 | All package names reported by `pacman -Qq`, including dependencies |
| Explicitly installed packages | 163 | Packages pacman marks as explicitly installed; this does not prove who installed each package |
| Dependency-installed packages | 855 | Packages pacman marks as dependency-installed |
| Foreign packages | 0 | No packages were reported by `pacman -Qqm` in this capture |
| Desktop launcher files | 63 | Includes application launchers, helper launchers, and URL handlers—not 63 distinct end-user apps |
| Files under `~/.local/bin` | 15 | User-local command-line executables |
| Keybinding entries | 224 | Omarchy's printed keybinding list |
| Enabled system unit files | 27 | Unit files marked enabled; this is not a list of currently running services |
| Enabled user unit files | 13 | User unit files marked enabled; this is not a list of currently running services |

The explicit package list and the explicit-native list currently match. The foreign package list is empty. Counts are specific to this captured machine and date; they will change as packages and Omarchy versions change.

## Folder guide

### `packages/`

| File | What it contains | When to use it |
|---|---|---|
| `packages-all.txt` | Every installed package name | Full inventory and comparisons between machines |
| `packages-explicit.txt` | Packages marked explicitly installed | Best first list for reviewing applications and tools |
| `packages-explicit-native.txt` | Explicit packages classified as native/repository packages by pacman | Compare with the foreign package list |
| `packages-foreign.txt` | Explicitly installed packages not found in configured sync databases | Investigate locally built or AUR packages; empty here |
| `packages-dependencies.txt` | Packages marked as dependency-installed | Usually lower priority when deciding what software you want |
| `packages-summary.txt` | Counts for the package lists | Quick overview |

**Important:** “Explicitly installed” does not mean “installed by me,” and it does not mean “Omarchy default.” Omarchy's installer may explicitly install packages. Conversely, a package in the dependency list may still be important to an application you want to keep.

Do not create a removal list simply by subtracting packages you do not recognize. First identify Omarchy's official package manifests for the exact installed release, then compare those manifests with this inventory.

### `applications/`

- **`desktop-launchers.txt`** — paths to `.desktop` files in `/usr/share/applications`. Several entries are helpers, previewers, settings tools, or URL handlers.
- **`local-bin.txt`** — executable file paths found directly under `~/.local/bin`. This capture includes command names such as `claude`, `codex`, `gemini`, `opencode`, `gh`, and `playwright`. Their presence does not tell us how they were installed or whether they are package-managed.
- **`omarchy-commands.json`** — a large machine-readable list of Omarchy commands. Search it for a command name when needed rather than reading it all at once.

A launcher is not necessarily a separate package, and a package does not necessarily provide a desktop launcher. Use the package list and launcher list together.

### `configuration/`

- **`keybindings.txt`** — human-readable shortcuts. Search for the action or key combination you want to change.
- **`config-files.txt`** — paths of files found under `~/.config`. This is an inventory of paths, **not a backup of all those files**. It includes application-generated data and browser profile/cache files as well as settings, so it is noisy and can change frequently.
- **`system-config-files.txt`** — accessible file paths under `/etc`, limited to two levels deep. It does not contain the file contents.
- **`system-config-errors.txt`** and **`sudoers-errors.txt`** — permission errors encountered while enumerating protected system directories. These warnings are expected when collecting as a regular user.
- **`units-system.txt`** and **`units-user.txt`** — system and user unit files marked enabled by systemd. Enabled does not necessarily mean currently running.
- **`id.txt`** — the current user's UID, GID, and group memberships.
- **`omarchy-config/`** — an actual copy of `~/.config/omarchy` from the capture. This is more useful for studying Omarchy settings and hooks than the general file-path list.
- **`sudoers.txt`** — the listing of files found under `/etc/sudoers.d`; the corresponding error file explains when access was denied. It is not a backup of sudoers contents.

### `system/`

- **`os-release.txt`** — identifies this capture as Omarchy **4.0.6**.
- **`kernel.txt`** — records the running kernel: `7.2.8-9-omarchy` in this capture.
- **`pacman-version.txt`** — records the pacman version.
- **`omarchy-version.txt`** — records the version reported by the Omarchy version command.

Keep this information with the baseline: it helps ensure that package manifests and configuration are compared against the correct Omarchy release.

## What stands out in this capture

These are useful areas to review, not automatic recommendations to remove anything:

- **Development and container tools:** the explicit list includes Docker, Docker Buildx/Compose, Git, Clang/LLVM, .NET runtime, Ruby, LuaRocks, and `mise-bin`.
- **Desktop and media applications:** it includes Chromium, Obsidian, LibreOffice, Kdenlive, OBS Studio, Moonlight, Pinta, Xournal++, and several media/image utilities.
- **Omarchy components:** packages such as `omarchy`, `omarchy-settings`, `omarchy-nvim`, `omarchy-keyring`, `quickshell`, `hyprland`, and `uwsm` are part of the environment to understand before changing or removing anything.
- **System and hardware-specific components:** the capture includes NVIDIA 580-series packages, the Omarchy kernel, firmware, Bluetooth, printing, firewall, and power-management components. Review these in the context of the hardware and features you use.
- **User-local command-line tools:** the local bin inventory includes several coding/AI CLI tools. Determine which ones you intentionally want on a fresh install and how each should be installed before automating them.

These observations are based on package names and inventory entries only; they are not a claim that every listed item is an Omarchy default.

## How to decide what belongs in your customization

For each package or setting you are considering, classify it as one of:

- **Keep as Omarchy default** — provided by the official installation for this exact release.
- **My addition** — something you deliberately want to install on every machine.
- **Change configuration** — installed already, but needs your preferred settings.
- **Remove/disable** — something you have decided you do not want, after checking dependencies and Omarchy integration.
- **Investigate** — unclear ownership or purpose; do not automate removal yet.

A practical next workflow:

1. Find the official Omarchy package manifests for the captured release.
2. Compare the official manifests against `packages-explicit.txt` and `packages-all.txt`.
3. Review the explicit list and mark the applications/tools you personally want.
4. Use the launcher list to confirm desktop-facing applications and the local-bin list for user-installed commands.
5. Review keybindings and `omarchy-config/` for settings you want to override.
6. Only then create maintained lists such as your own packages-to-install and packages-to-remove.

For package details on the installed machine, use:

```bash
pacman -Qi PACKAGE_NAME
pacman -Qii PACKAGE_NAME
```

The first command shows package metadata, including its install reason. The second includes backup-file information. To see which package owns a file:

```bash
pacman -Qo /path/to/file
```

## Privacy note before keeping inventories in Git

This repository is public. The raw inventory includes the local home-directory path, user/group information, application and tool names, system configuration paths, and a copy of Omarchy configuration. Before keeping future captures in a public repository, review them for personal information, host details, tokens, private URLs, or other sensitive values.

Consider keeping raw machine-specific baselines out of the public repository and committing a sanitized summary instead. If the raw inventory is useful only locally, add the baseline directory to `.gitignore` and retain a separate redacted report for documentation.

## Scope and limitations

This inventory is a snapshot, not a complete backup or an authoritative definition of Omarchy defaults:

- It records package names and paths; it does not capture every installed file or every configuration file's contents.
- The general `~/.config` inventory includes generated application data, not just settings.
- The `/etc` listing is shallow and skips files/directories that the current user cannot access.
- Service lists show enabled unit files, not runtime status.
- Package explicit/dependency reasons are pacman's current classifications and do not identify who originally installed a package.
- The results describe one machine on 2026-10-26. Re-run the collector after major changes and store each baseline separately when you need a historical comparison.
