# ============================================================
# INSTANT PROMPT (must be near the very top)
# ============================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================================
# PLATFORM ENV (macOS)
# ============================================================
# export SSH_AUTH_SOCK=~/.bitwarden-ssh-agent.sock
# COSIGN_PASSWORD / OLLAMA_HOST come from the environment / .env (dotenv plugin).

# Homebrew (early, so brew paths resolve for completions/plugins).
# This sets HOMEBREW_PREFIX, used below instead of repeated `brew --prefix` forks.
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH additions
path=(
  "$HOME/.docker/bin"           # Docker Desktop (guarded below)
  "$HOME/.cargo/bin"            # Rust
  "$HOME/.lmstudio/bin"         # LM Studio
  "$HOME/.local/bin"
  "/opt/homebrew/opt/openjdk@11/bin"
  $path
)
[[ -d "/Applications/Docker.app" ]] || path[1]=()  # drop Docker entry if not installed

# ------------------------------------------------------------
# nvm — lazy-loaded.
# The default node is added to PATH immediately so node/npm/npx (and the
# p10k node segment) work with zero startup cost; the heavy nvm.sh is only
# sourced the first time `nvm` itself is invoked.
# ------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -d "$NVM_DIR" ]] || mkdir -p "$NVM_DIR"
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
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
  [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] &&
    source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# ------------------------------------------------------------
# Completions & line-editor plugin location (Homebrew)
# ------------------------------------------------------------
if type brew &>/dev/null; then
  fpath+=(
    "$HOMEBREW_PREFIX/share/zsh-completions"
    "$HOMEBREW_PREFIX/share/zsh/site-functions"
  )
fi
ZSH_PLUGIN_DIR="$HOMEBREW_PREFIX/share"

# ------------------------------------------------------------
# Oh My Zsh plugins (macOS adds `brew`)
# ------------------------------------------------------------
plugins=(
  git
  z
  brew
  direnv
  dotenv
  kubectl
  evalcache   # custom: installed by install.sh
)

# ------------------------------------------------------------
# Homebrew aliases
# ------------------------------------------------------------
if [[ -f ~/.config/Brewfile ]]; then
  alias brewup="brew cleanup && brew update && brew upgrade && brew bundle --file=~/.config/Brewfile"
else
  alias brewup="brew cleanup && brew update && brew upgrade"
fi
alias brewdown="brew uninstall --cask --force --zap"

# ============================================================
# SHARED CONFIG
# ============================================================
source ~/.config/zshrc/common.zsh

# macOS completions that depend on compinit (cached via evalcache)
if type bk &>/dev/null; then
  _evalcache bk completion zsh
fi
