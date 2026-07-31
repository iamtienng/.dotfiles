# Dotfiles

Personal dotfiles for macOS, Arch Linux, and WSL (Arch), managed with GNU Stow.

The repo is split into shared config and OS-specific config:

- `common/`: shared app config (stowed to `~/.config`).
- `macos/`: macOS-only config and packages (stowed to `~/.config`).
- `arch/`: Arch-only config and packages (stowed to `~/.config`).
- `wsl/`: WSL (Arch) config and packages (stowed to `~/.config`).
- `claude/`: shared Claude Code config, stowed to `~/.claude` (not `~/.config`).

## Install

Run the installer from the repo root:

```sh
./install.sh
```

For WSL
```
choco install npiperelay
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
# Git identity lives in an untracked local include (template: common/git/config.local.example):
cp ~/.config/git/config.local.example ~/.config/git/config.local
# then edit ~/.config/git/config.local with your name + email.
# For work repos, add a gitdir-scoped includeIf pointing at an untracked
# ~/.config/git/config.work that holds the work email + signing key (see the template).
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
./install.sh --dry-run           # preview every action; touches nothing
./install.sh --skip-packages     # skip Homebrew/pacman package install
./install.sh --skip-zsh-tools    # skip Oh My Zsh / Powerlevel10k / evalcache
./install.sh --skip-stow         # skip linking
./install.sh --replace-existing  # DANGEROUS: delete existing configs instead of backing them up
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

## Claude Code config

The `claude/` package is shared across all platforms and stows into `~/.claude`
(Claude Code reads its config there, not from XDG). The installer stows it
unconditionally, alongside `common/`. It ships `statusline-command.sh` (referenced
by `~/.claude/settings.json`), plus `agents/`, `commands/`, and `skills/`.

`~/.claude/settings.json` is intentionally **not** stowed — it holds
environment-specific endpoints and tokens. Only files safe to share live in `claude/`.

## Notes

Each OS `.zshrc` (`macos/`, `arch/`, `wsl/`) holds only platform-specific setup (Homebrew vs pacman, nvm location, OS plugins) and sources the shared body at `common/zshrc/common.zsh` for everything common (Oh My Zsh, history, aliases, completions, prompt). Edit shared behavior once in `common.zsh`; edit platform quirks in the matching OS file. `nvm` is lazy-loaded — `node`/`npm`/`npx` work immediately via the default version, and `nvm.sh` is sourced only on first `nvm` use.

Before stowing, the installer inspects each top-level config entry it is about to create (for example `~/.config/nvim`, `~/.config/ghostty`, `~/.config/zshrc`). Entries already managed by this repo (symlinks pointing back into it) are left as-is. Any other pre-existing entry is **backed up** to `<name>.backup.<timestamp>` before stowing — nothing is deleted by default. Pass `--replace-existing` to delete those entries instead of backing them up (DANGEROUS). The same backup-first rule applies to `~/.zshrc`: a real file is backed up, and an existing symlink into this repo is left untouched.

The Zsh setup installs or updates Oh My Zsh, Powerlevel10k, and evalcache under `~/.oh-my-zsh`.

The installer links `~/.zshrc` to `~/.config/zshrc/.zshrc` when `~/.zshrc` is missing or already a symlink. Existing regular `~/.zshrc` files are left untouched.
