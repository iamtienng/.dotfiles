# Dotfiles

Personal dotfiles for macOS and Arch Linux, managed with GNU Stow.

The repo is split into shared config and OS-specific config:

- `common/`: shared app config.
- `macos/`: macOS-only config and packages.
- `arch/`: Arch-only config and packages.

## Install

Run the installer from the repo root:

```sh
./install.sh
```

For WSL
```
wsl --install archlinux
exit
wsl --set-default archlinux
wsl
pacman -Sy --needed --noconfirm git sudo nvim zsh
nvim /etc/locale.gen
# uncomment en_US.UTF-8 UTF-8
locale-gen
useradd -m -G wheel -s /bin/zsh iamtienng
passwd iamtienng
passwd root
EDITOR=nvim visudo
# uncomment %wheel ALL=(ALL:ALL) ALL
cat >/etc/wsl.conf <<EOF
[user]
default=iamtienng
EOF
exit
wsl --shutdown
wsl
mkdir -p ~/project/personal/dev
cd ~/project/personal/dev
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
cd ~/project/personal/dev
git clone https://github.com/iamtienng/.dotfiles.git
cd .dotfiles
./install.sh
git remote set-url origin git@github.com:iamtienng/.dotfiles.git
git config --global user.name "Tien Nguyen"
git config --global user.email "iamtienng@gmail.com"
git config --global user.signingkey "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMIpJ9w+cEX0g3X5SvhbihI+R0LtG3KEkari4tyahPtN"
sudo pacman -S dbus socat
sudo mkdir -p "/run/user/$(id -u)"
sudo chown "$(id -u):$(id -g)" "/run/user/$(id -u)"
chmod 700 "/run/user/$(id -u)"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID
exit
wsl --shutdown
wsl
tmux
cd ~/project/personal/dev/.dotfiles
git pull
sudo pacman -S dbus socat
v
exit
wsl --shutdown
wsl
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
