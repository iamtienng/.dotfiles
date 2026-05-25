# Dotfiles

Personal dotfiles for macOS and Arch Linux, managed with GNU Stow.

The repo is split into shared config and OS-specific config:

- `common/`: shared app config for Neovim, tmux, Ghostty themes, k9s, and Zed.
- `macos/`: macOS-only config and packages, including Homebrew, Aerospace, Karabiner, Ghostty, scripts, and zsh.
- `arch/`: Arch-only config and packages, including Hyprland, Ghostty, scripts, and zsh.

## Install

Run the installer from the repo root:

```sh
./install.sh
```

The installer detects the OS, installs packages, installs the Zsh tooling used by `.zshrc`, then stows `common/` plus the matching OS directory into `~/.config`.

Supported package paths:

- macOS: `brew bundle --file macos/Brewfile`
- Arch Linux: `sudo pacman -Syu --needed` using `arch/pkglist.txt`
- Arch AUR: uses `yay` or `paru` with `arch/pkglist-aur.txt` when one is available

Useful options:

```sh
./install.sh --dry-run
./install.sh --skip-packages
./install.sh --skip-zsh-tools
./install.sh --skip-stow
```

## Manual Stow

To link only dotfiles without installing packages:

```sh
cd common && stow --restow .
cd ../macos && stow --restow .
```

On Arch:

```sh
cd common && stow --restow .
cd ../arch && stow --restow .
```

Each stow package targets `~/.config` and uses `--no-folding` so shared and OS-specific directories can merge cleanly, for example `common/ghostty/themes` with `macos/ghostty/config`.

## Notes

Before stowing, the installer removes existing top-level config entries managed by this repo, such as `~/.config/nvim`, `~/.config/ghostty`, and `~/.config/zshrc`. Then it recreates them from `common/` and the detected OS package.

The Zsh setup installs or updates Oh My Zsh, Powerlevel10k, and evalcache under `~/.oh-my-zsh`.

The installer links `~/.zshrc` to `~/.config/zshrc/.zshrc` when `~/.zshrc` is missing or already a symlink. Existing regular `~/.zshrc` files are left untouched.
