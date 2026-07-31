# ============================================================
# common.zsh — shared zsh config
# ============================================================
# Sourced at the END of each platform .zshrc (macos/arch/wsl).
# The platform file is responsible, BEFORE sourcing this, for:
#   - the Powerlevel10k instant-prompt block (must be first of all)
#   - PATH / Homebrew / nvm setup
#   - fpath additions for completions
#   - $ZSH_PLUGIN_DIR  (base dir holding the zsh-* line-editor plugins)
#   - plugins=(...)    (the Oh My Zsh plugin list for this platform)
#   - any platform-only package-manager aliases (brew* / pacman*)

# ------------------------------------------------------------
# Environment
# ------------------------------------------------------------
export LANG=en_US.UTF-8
export DIRENV_LOG_FORMAT=""
export EDITOR='nvim'
export ENV="local"
export GPG_TTY=$(tty)

# XDG-style config paths (absolute; ~ does not expand inside quotes)
export K9S_CONFIG_DIR="$HOME/.config/k9s"
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"
export ZSH_EVALCACHE_DIR="$HOME/.local/.zsh-evalcache"

# ------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-syntax-highlighting (configure before the plugin loads)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor line)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')

DISABLE_MAGIC_FUNCTIONS="true"
ZSH_DISABLE_COMPFIX="true"   # skip the slow compaudit security scan; fpath is trusted
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# plugins=(...) is defined by the platform file before this point.
# Oh My Zsh runs compinit itself; we deliberately do not call compinit
# (or promptinit — p10k is the prompt) a second time.
source "$ZSH/oh-my-zsh.sh"

zstyle ':completion:*' menu select

# ------------------------------------------------------------
# Editor (SSH-aware) + editor aliases
# ------------------------------------------------------------
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim'
alias v="nvim"
alias vi="nvim"
alias vim="nvim"

# ------------------------------------------------------------
# History
# ------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_SPACE HIST_IGNORE_DUPS SHARE_HISTORY

# ------------------------------------------------------------
# Line-editor plugins (path comes from the platform via $ZSH_PLUGIN_DIR)
# syntax-highlighting must load before history-substring-search.
# ------------------------------------------------------------
if [[ -n "$ZSH_PLUGIN_DIR" ]]; then
  [[ -r "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
    source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
    source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [[ -r "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]] &&
    source "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
fi

# ------------------------------------------------------------
# fzf — fuzzy finder shell integration (Ctrl-R / Ctrl-T / Alt-C)
# fd/bat power the file source and preview; guarded so a missing
# fzf (or an older one without --zsh) never breaks shell startup.
# ------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :200 {}'"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  source <(fzf --zsh 2>/dev/null)
fi

# ------------------------------------------------------------
# Cached completions
# ------------------------------------------------------------
if type kubectl &>/dev/null; then
  _evalcache kubectl completion zsh
fi

# ------------------------------------------------------------
# Aliases — utils
# ------------------------------------------------------------
alias btop='btop -c "${HOME}/.config/btop/btop_$(tmux show -gqv @background 2>/dev/null || echo dark).conf"'
alias hc="history -c"
alias hg="history | rg "
alias expand_path='realpath'
alias nvimclean="rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim"

# eza / lazygit / lazydocker (additive — ls/cat/find left unchanged)
alias ll='eza -l --git --icons'
alias la='eza -la --git --icons'
alias lt='eza --tree --level=2'
alias lg='lazygit'
alias lzd='lazydocker'

# ------------------------------------------------------------
# Aliases — Kubernetes
# ------------------------------------------------------------
alias k='kubectl'
alias kx='kubectx'
alias kn='kubens'
kdebug() {
  local ns
  ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
  ns=${ns:-default}

  if kubectl get pod debug-shell -n "$ns" >/dev/null 2>&1; then
    echo "Connecting to existing debug-shell pod in namespace: $ns"
    kubectl exec -it -n "$ns" debug-shell -- bash
  else
    echo "Creating a new debug-shell pod in namespace: $ns"
    kubectl run debug-shell \
      -n "$ns" \
      --rm -it \
      --restart=Never \
      --image=iamtienng/ubuntu-utils:latest \
      --overrides='{"spec":{"tolerations":[{"operator":"Exists"}]}}' \
      -- bash
  fi
}

# ------------------------------------------------------------
# Aliases — Terragrunt
# ------------------------------------------------------------
alias tfclean='
  find . -type d -name ".terragrunt-cache" -prune -exec rm -rf {} \;
  find . -name ".terraform.lock.hcl" -type f -delete
  find . -name "terragrunt-debug.tfvars.json" -type f -delete
'

# ------------------------------------------------------------
# Powerlevel10k (must be last)
# ------------------------------------------------------------
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ -f ~/.config/zshrc/.p10k.zsh ]] && source ~/.config/zshrc/.p10k.zsh
