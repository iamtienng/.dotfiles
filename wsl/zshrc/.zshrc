# ============================================================
# INSTANT PROMPT (must be near the very top)
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================
# PLATFORM ENV (WSL / Arch)
# ============================================================
# COSIGN_PASSWORD / OLLAMA_HOST come from the environment / .env (dotenv plugin).

# Bitwarden SSH agent bridged from Windows via npiperelay
export SSH_AUTH_SOCK="$HOME/.ssh/bitwarden-ssh-agent.sock"
start_bitwarden_ssh_agent() {
  local npiperelay="/mnt/c/ProgramData/chocolatey/bin/npiperelay.exe"

  if [ ! -x "$npiperelay" ]; then
    echo "npiperelay not found or not executable: $npiperelay"
    return 1
  fi

  if ! ss -lx | grep -q "$SSH_AUTH_SOCK"; then
    rm -f "$SSH_AUTH_SOCK"
    setsid socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:"$npiperelay -ei -s //./pipe/openssh-ssh-agent",nofork >/dev/null 2>&1 &
  fi
}
start_bitwarden_ssh_agent

# WSL runtime dir + D-Bus session (needed by gsettings etc.)
if grep -qi microsoft /proc/version; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"

  if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    sudo mkdir -p "$XDG_RUNTIME_DIR"
    sudo chown "$(id -u):$(id -g)" "$XDG_RUNTIME_DIR"
    sudo chmod 700 "$XDG_RUNTIME_DIR"
  fi

  if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax)"
  fi
fi

# Mirror the Windows light/dark theme into GNOME settings.
# Launching powershell.exe is slow (hundreds of ms), so run it in the
# background so it never blocks the prompt.
sync_windows_theme_to_gsettings() {
  local win_theme

  win_theme="$(powershell.exe -NoProfile -Command \
    '(Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize).AppsUseLightTheme' \
    2>/dev/null | tr -d '\r')"

  case "$win_theme" in
    0)
      gsettings set org.gnome.desktop.interface color-scheme prefer-dark
      ;;
    1)
      gsettings set org.gnome.desktop.interface color-scheme prefer-light
      ;;
  esac
}
sync_windows_theme_to_gsettings &!

# PATH additions
path=(
  "$HOME/.docker/bin"           # Docker (guarded below)
  "$HOME/.cargo/bin"            # Rust
  "$HOME/.lmstudio/bin"         # LM Studio
  $path
)
[[ -d "$HOME/.docker/bin" ]] || path[1]=()  # drop Docker entry if not installed

# ------------------------------------------------------------
# nvm — lazy-loaded.
# The default node is added to PATH immediately so node/npm/npx (and the
# p10k node segment) work with zero startup cost; init-nvm.sh is only
# sourced the first time `nvm` itself is invoked.
# ------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/alias/default" ]]; then
  _nvm_def="$(<"$NVM_DIR/alias/default")"
  for _nvm_bin in \
    "$NVM_DIR/versions/node/v${_nvm_def}"*/bin(/N) \
    "$NVM_DIR/versions/node/${_nvm_def}"*/bin(/N); do
    path=("$_nvm_bin" $path)
    break
  done
  unset _nvm_def _nvm_bin
fi
nvm() {
  unset -f nvm
  [[ -s /usr/share/nvm/init-nvm.sh ]] && source /usr/share/nvm/init-nvm.sh
  nvm "$@"
}

# ------------------------------------------------------------
# Completions & line-editor plugin location
# (trailing (N) drops paths that don't exist, so a missing package
#  never leaves a broken fpath entry / triggers an insecure-dir prompt)
# ------------------------------------------------------------
fpath+=(
  /usr/share/zsh/site-functions(N)
  /usr/share/zsh/plugins/zsh-completions/src(N)
)
ZSH_PLUGIN_DIR="/usr/share/zsh/plugins"

# ------------------------------------------------------------
# Oh My Zsh plugins
# ------------------------------------------------------------
plugins=(
  git
  z
  direnv
  dotenv
  kubectl
  evalcache   # custom: installed by install.sh
)

# ------------------------------------------------------------
# Package-manager helpers
# ------------------------------------------------------------
_pkglist() {
  [[ -f "$1" ]] && grep -vE '^\s*#|^\s*$' "$1"
}
pacmanup() {
  if [[ -f ~/.config/pkglist.txt ]]; then
    sudo pacman -Syu --needed --noconfirm $(_pkglist ~/.config/pkglist.txt)
  else
    sudo pacman -Syu --noconfirm
  fi
}
yayup() {
  if [[ -f ~/.config/pkglist-aur.txt ]]; then
    yay -Syu --needed --noconfirm $(_pkglist ~/.config/pkglist-aur.txt)
  else
    yay -Syu --noconfirm
  fi
}
systemup() {
  yay -Syu --noconfirm
  [[ -f ~/.config/pkglist.txt ]] && \
    sudo pacman -S --needed --noconfirm $(_pkglist ~/.config/pkglist.txt)
  [[ -f ~/.config/pkglist-aur.txt ]] && \
    yay -S --needed --noconfirm $(_pkglist ~/.config/pkglist-aur.txt)
}

# ============================================================
# SHARED CONFIG
# ============================================================
source ~/.config/zshrc/common.zsh
