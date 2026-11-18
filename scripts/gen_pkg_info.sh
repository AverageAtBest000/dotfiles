#!/bin/bash
# Regenerate package lists from the running system.
# Base system / kernel / bootloader packages are filtered out because the
# CachyOS installer provides its own (linux-cachyos, limine, etc.).

set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)/packages"
EXCLUDE='^(base|base-devel|linux|linux-cachyos.*|linux-firmware.*|linux-headers|grub|grub-btrfs|limine.*|efibootmgr|mkinitcpio.*|intel-ucode|amd-ucode|sudo|wpa_supplicant|.*-debug)$'

pacman -Qqen | grep -Ev "$EXCLUDE" > "$PACKAGE_DIR/pacman.txt"
pacman -Qqem | grep -Ev "$EXCLUDE|^(yay|paru)(-bin)?$" > "$PACKAGE_DIR/aur.txt"

if command -v code >/dev/null; then
	code --list-extensions > "$PACKAGE_DIR/vscode.txt"
fi
