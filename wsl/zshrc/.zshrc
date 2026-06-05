# ============================================================
# INSTANT PROMPT (must be near the very top)
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================
# ENVIRONMENT & PATH (before plugins)
# ============================================================
export LANG=en_US.UTF-8
export DIRENV_LOG_FORMAT=""
export EDITOR='nvim'
export ENV="local"
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
export COSIGN_PASSWORD=$COSIGN_PASSWORD
export OLLAMA_HOST=$OLLAMA_HOST

# XDG-style config paths
export K9S_CONFIG_DIR=".config/k9s"
export TMS_CONFIG_FILE="~/.config/tms/config.toml"
export ZSH_EVALCACHE_DIR="$HOME/.local/.zsh-evalcache"

# PATH additions
path=(
  "$HOME/.docker/bin"           # Docker Desktop (guarded below)
  "$HOME/.cargo/bin"            # Rust
  "$HOME/.lmstudio/bin"         # LM Studio
  $path
)
[[ -d "/Applications/Docker.app" ]] || path[1]=()  # drop Docker entry if not installed

# ============================================================
# OH-MY-ZSH
# ============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

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

sync_windows_theme_to_gsettings

# zsh-syntax-highlighting config (before OMZ source)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')

DISABLE_MAGIC_FUNCTIONS="true"
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

plugins=(
  git
  z
  direnv
  dotenv
  kubectl
  evalcache   # custom: install separately
)

source "$ZSH/oh-my-zsh.sh"

# ============================================================
# EDITOR (SSH-aware override)
# ============================================================
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'

alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# ============================================================
# HISTORY
# ============================================================
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_SPACE HIST_IGNORE_DUPS SHARE_HISTORY

# ============================================================
# COMPLETIONS & PROMPT
# ============================================================
fpath+=(
  "usr/share/zsh/plugins/zsh-completions"
  "/usr/share/zsh/plugins/zsh/site-functions"
)
autoload -Uz compinit promptinit
compinit -u
promptinit
zstyle ':completion:*' menu select

# ============================================================
# PLUGINS (after compinit)
# ============================================================
source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"

# ============================================================
# LAZY / CACHED COMPLETIONS
# ============================================================
if type kubectl &>/dev/null; then
  _evalcache kubectl completion zsh
fi

# ============================================================
# ALIASES
# ============================================================
# Package Manager
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

# Utils
alias btop='btop -c "${HOME}/.config/btop/btop_$(tmux show -gqv @background 2>/dev/null || echo dark).conf"'
alias hc="history -c"
alias hg="history | rg "
alias expand_path='realpath'
alias nvimclean="rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim"

# Kubernetes
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
alias kdebug='
  if kubectl get pod debug-shell &>/dev/null; then
    echo "Connecting to existing debug-shell pod..."
    kubectl exec -it debug-shell -- bash
  else
    echo "Creating a new debug-shell pod..."
    kubectl run debug-shell --rm -i --tty --image iamtienng/ubuntu-utils:latest \
      --overrides="{\"spec\":{\"tolerations\":[{\"operator\":\"Exists\"}]}}" \
      -- bash
  fi
'

# Terragrunt
alias tfclean='
  find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
  find . -name ".terraform.lock.hcl" -type f -delete
  find . -name "terragrunt-debug.tfvars.json" -type f -delete
'

# ============================================================
# SCRIPT PERMISSIONS (idempotent, run once ideally via install)
# ============================================================
for script in ghostty-tmux-initializer tmux-sessionizer; do
  [[ -f ~/.config/scripts/$script ]] && chmod +x ~/.config/scripts/$script
done

# ============================================================
# P10K (must be last)
# ============================================================
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -f ~/.config/zshrc/.p10k.zsh ]] && source ~/.config/zshrc/.p10k.zsh
