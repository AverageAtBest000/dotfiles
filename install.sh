#!/bin/bash
# Bootstrap these dotfiles on a fresh CachyOS (or Arch) install.
# Usage: git clone <this repo> ~/dotfiles && cd ~/dotfiles && ./install.sh

set -euo pipefail
cd "$(dirname "$0")"

echo ":: Installing repo packages"
sudo pacman -S --needed - < packages/pacman.txt

echo ":: Installing AUR packages"
if command -v paru >/dev/null; then
	paru -S --needed - < packages/aur.txt
elif command -v yay >/dev/null; then
	yay -S --needed - < packages/aur.txt
else
	echo "   no AUR helper found (sudo pacman -S paru), skipping"
fi

if command -v code >/dev/null && [ -s packages/vscode.txt ]; then
	echo ":: Installing VS Code extensions"
	xargs -n1 code --install-extension < packages/vscode.txt
fi

# CachyOS's Hyprland preset ships configs that collide with ours
if pacman -Qq cachyos-hyprland-settings >/dev/null 2>&1; then
	echo ":: Removing cachyos-hyprland-settings (conflicts with hypr/)"
	sudo pacman -Rns --noconfirm cachyos-hyprland-settings
fi

echo ":: Linking configs with stow"
STOW_PKGS=(hypr kitty nvim zsh rofi matugen caelestia git)
for pkg in "${STOW_PKGS[@]}"; do
	# Back up any real (non-symlink) files that would block stow
	while IFS= read -r -d '' f; do
		target="$HOME/${f#"$pkg"/}"
		if [ -e "$target" ] && [ ! -L "$target" ]; then
			echo "   backing up ~/${f#"$pkg"/} -> .pre-dotfiles"
			mv "$target" "$target.pre-dotfiles"
		fi
	done < <(find "$pkg" \( -type f -o -type l \) -print0)
	stow --target="$HOME" "$pkg"
done

if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
	echo ":: Setting zsh as login shell"
	chsh -s "$(command -v zsh)"
fi

echo ":: Done. Firefox user.js/chrome live in firefox/ — copy them into your profile folder manually."
