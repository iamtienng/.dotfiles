#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STOW_TARGET="$CONFIG_HOME"

DRY_RUN=0
SKIP_PACKAGES=0
SKIP_ZSH_TOOLS=0
SKIP_STOW=0
REPLACE_EXISTING=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Options:
  --dry-run           Show what would be done without changing files.
  --skip-packages     Skip Homebrew/pacman package installation.
  --skip-zsh-tools    Skip Oh My Zsh, Powerlevel10k, and evalcache setup.
  --skip-stow         Skip GNU Stow linking.
  --replace-existing  DANGEROUS: remove existing ~/.config entries instead of backing them up.
  -h, --help          Show this help.
USAGE
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

die() {
  printf '[dotfiles] error: %s\n' "$*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --dry-run) DRY_RUN=1 ;;
  --skip-packages) SKIP_PACKAGES=1 ;;
  --skip-zsh-tools) SKIP_ZSH_TOOLS=1 ;;
  --skip-stow) SKIP_STOW=1 ;;
  --replace-existing) REPLACE_EXISTING=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    die "unknown option: $1"
    ;;
  esac
  shift
done

detect_platform() {
  case "$(uname -s)" in
  Darwin) printf 'macos' ;;
  Linux)
    if [ -f /etc/arch-release ]; then
      printf 'arch'
    else
      die "unsupported Linux distribution; this repo currently has package lists for Arch only"
    fi
    ;;
  *) die "unsupported OS: $(uname -s)" ;;
  esac
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if command -v brew >/dev/null 2>&1; then
    return
  fi

  log "Homebrew not found; installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_macos_packages() {
  ensure_homebrew
  log "Installing macOS packages from macos/Brewfile"
  brew bundle --file="$DOTFILES_DIR/macos/Brewfile"
}

read_package_list() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$file"
}

install_arch_packages() {
  local pacman_packages=()
  local aur_packages=()

  while IFS= read -r package; do
    pacman_packages+=("$package")
  done < <(read_package_list "$DOTFILES_DIR/arch/pkglist.txt")

  while IFS= read -r package; do
    aur_packages+=("$package")
  done < <(read_package_list "$DOTFILES_DIR/arch/pkglist-aur.txt")

  if [ "${#pacman_packages[@]}" -gt 0 ]; then
    log "Installing Arch packages from arch/pkglist.txt"
    sudo pacman -Syu --needed --noconfirm "${pacman_packages[@]}"
  fi

  if [ "${#aur_packages[@]}" -eq 0 ]; then
    return
  fi

  if command -v yay >/dev/null 2>&1; then
    log "Installing AUR packages from arch/pkglist-aur.txt with yay"
    yay -S --needed --noconfirm "${aur_packages[@]}"
  elif command -v paru >/dev/null 2>&1; then
    log "Installing AUR packages from arch/pkglist-aur.txt with paru"
    paru -S --needed --noconfirm "${aur_packages[@]}"
  else
    log "No AUR helper found; skipping AUR packages: ${aur_packages[*]}"
  fi
}

install_packages() {
  case "$1" in
  macos) install_macos_packages ;;
  arch) install_arch_packages ;;
  esac
}

install_or_update_git_repo() {
  local repo="$1"
  local target="$2"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would clone/update $repo -> $target"
    return
  fi

  if [ -d "$target/.git" ]; then
    log "Updating $target"
    git -C "$target" pull --ff-only
    return
  fi

  if [ -e "$target" ]; then
    log "Leaving existing non-git path in place: $target"
    return
  fi

  log "Cloning $repo -> $target"
  mkdir -p "$(dirname -- "$target")"
  git clone --depth=1 "$repo" "$target"
}

install_zsh_tools() {
  local oh_my_zsh_dir="$HOME/.oh-my-zsh"
  local zsh_custom_dir="$oh_my_zsh_dir/custom"

  command -v git >/dev/null 2>&1 || die "git is required to install Oh My Zsh tools"

  install_or_update_git_repo \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "$oh_my_zsh_dir"

  install_or_update_git_repo \
    "https://github.com/romkatv/powerlevel10k.git" \
    "$zsh_custom_dir/themes/powerlevel10k"

  install_or_update_git_repo \
    "https://github.com/mroth/evalcache.git" \
    "$zsh_custom_dir/plugins/evalcache"
}

config_entries() {
  local package_dir
  local entry

  for package_dir in "$@"; do
    [ -d "$package_dir" ] || continue

    find "$package_dir" -mindepth 1 -maxdepth 1 \
      ! -name '.stowrc' \
      ! -name '.DS_Store' \
      ! -name '.gitignore' \
      ! -name 'README*.md' \
      -print
  done | while IFS= read -r entry; do
    basename "$entry"
  done | sort -u
}

is_stow_symlink() {
  local target="$1"

  [ -L "$target" ] || return 1

  local resolved
  resolved="$(readlink "$target")"

  case "$resolved" in
  "$DOTFILES_DIR"/* | ../* | ../../*) return 0 ;;
  *) return 1 ;;
  esac
}

prepare_config_entry() {
  local name="$1"
  local target="$CONFIG_HOME/$name"

  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    return
  fi

  if is_stow_symlink "$target"; then
    log "Existing stow symlink is okay: $target"
    return
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ "$REPLACE_EXISTING" -eq 1 ]; then
      log "Would remove existing config: $target"
    else
      log "Would backup existing config: $target"
    fi
    return
  fi

  if [ "$REPLACE_EXISTING" -eq 1 ]; then
    log "Removing existing config: $target"
    rm -rf -- "$target"
  else
    local backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    log "Backing up existing config: $target -> $backup"
    mv -- "$target" "$backup"
  fi
}

prepare_config_entries() {
  local name

  while IFS= read -r name; do
    prepare_config_entry "$name"
  done < <(config_entries "$@")
}

stow_package() {
  local package_dir="$1"
  local stow_args=(--target "$STOW_TARGET" --restow .)

  [ -d "$package_dir" ] || die "missing package directory: $package_dir"
  command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed"

  if [ "$DRY_RUN" -eq 1 ]; then
    stow_args=(--simulate --verbose "${stow_args[@]}")
  fi

  log "Stowing $(basename "$package_dir") into $CONFIG_HOME"
  mkdir -p "$CONFIG_HOME"
  (cd "$package_dir" && stow "${stow_args[@]}")
}

link_zshrc() {
  local source="$CONFIG_HOME/zshrc/.zshrc"
  local target="$HOME/.zshrc"

  if [ "$DRY_RUN" -eq 1 ]; then
    log "Would link $target -> $source"
    return
  fi

  if [ -L "$target" ] || [ ! -e "$target" ]; then
    ln -sfn "$source" "$target"
    log "Linked $target -> $source"
  else
    local backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    log "Backing up existing $target -> $backup"
    mv -- "$target" "$backup"
    ln -sfn "$source" "$target"
    log "Linked $target -> $source"
  fi
}

stow_dotfiles() {
  local platform="$1"

  command -v stow >/dev/null 2>&1 || die "GNU Stow is not installed"

  mkdir -p "$CONFIG_HOME"

  prepare_config_entries "$DOTFILES_DIR/common" "$DOTFILES_DIR/$platform"

  stow_package "$DOTFILES_DIR/common"
  stow_package "$DOTFILES_DIR/$platform"

  link_zshrc
}

main() {
  local platform
  platform="$(detect_platform)"

  log "Detected platform: $platform"

  if [ "$SKIP_PACKAGES" -eq 0 ]; then
    install_packages "$platform"
  else
    log "Skipping package installation"
  fi

  if [ "$SKIP_ZSH_TOOLS" -eq 0 ]; then
    install_zsh_tools
  else
    log "Skipping Zsh tool installation"
  fi

  if [ "$SKIP_STOW" -eq 0 ]; then
    stow_dotfiles "$platform"
  else
    log "Skipping stow linking"
  fi

  log "Done"
}

main "$@"
