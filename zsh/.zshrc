if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

# p10k config
ZSH_THEME="powerlevel10k/powerlevel10k"
[[ ! -f $ZDOTDIR/.p10k.zsh ]] || source $ZDOTDIR/.p10k.zsh

plugins=(
  git
  1password
  z
  brew
  direnv
  dotenv
  kubectl
)

source $ZSH/oh-my-zsh.sh

# zsh config
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')
DISABLE_MAGIC_FUNCTIONS="true"
# Auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7

# zsh plugins from Brew
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
# Set to vi mode
# set -o vi

# history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# path
export K9S_CONFIG_DIR=".config/k9s"
if [ -d "/Applications/Docker.app" ]; then
  path+=("$HOME/.docker/bin")
fi

# aliases
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias hc="history -c"
alias hg="history | grep "
alias expand_path='realpath'
alias k='kubectl'
alias kx=kubectx
alias kn=kubens
alias kdebug='
  if kubectl get pod debug-shell &> /dev/null; then
    echo "Connecting to existing debug-shell pod..."
    kubectl exec -it debug-shell -- bash
  else
    echo "Creating a new debug-shell pod..."
    kubectl run debug-shell --rm -i --tty --image iamtienng/ubuntu-utils -- bash
  fi
'
if [ -f ~/.dotfiles/Brewfile ]; then
  alias brewup="brew bundle --file=~/.dotfiles/Brewfile"
fi

