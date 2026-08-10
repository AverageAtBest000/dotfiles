#!/bin/bash

set -euo pipefail

PACKAGE_DIR=~/dotfiles/packages

pacman -Qqen > "$PACKAGE_DIR/pacman.txt"
pacman -Qqem > "$PACKAGE_DIR/aur.txt"


code --list-extensions > "$PACKAGE_DIR/vscode.txt"
