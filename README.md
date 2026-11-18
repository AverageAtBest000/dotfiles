# dotfiles (CachyOS)

Hyprland (Lua config) + Caelestia shell + matugen theming, managed with GNU Stow.

## Fresh install

1. Install CachyOS (Desktop Edition ISO). In the installer, choose the **No Desktop** option.
2. Then:

```bash
sudo pacman -S --needed git
git clone git@github.com:AverageAtBest000/dotfiles-cachyos ~/dotfiles
cd ~/dotfiles && ./install.sh
```

`install.sh` installs `packages/pacman.txt` + `packages/aur.txt`, backs up any
clashing files to `*.pre-dotfiles`, stows every config, and switches the login
shell to zsh. Apps listed in `packages/optional.txt` are installed by hand.

## Keeping package lists current

```bash
~/dotfiles/scripts/gen_pkg_info.sh
```

Kernel/bootloader/base packages are filtered out automatically.

## Keybinds worth remembering

| Keys | Action |
|---|---|
| Super + F | Fullscreen toggle |
| Super + V | Float toggle |
| Super + ` | Show/hide scratchpad (`special:magic`) |
| Super + Shift + S | Send window to scratchpad |
| Super + T | Show/hide Planify todo panel |
| Super + I | Neovim in kitty |
