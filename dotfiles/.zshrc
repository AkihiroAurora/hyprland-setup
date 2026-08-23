# ============================================
# ZINIT - Plugin Manager
# ============================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================
# COMPLETIONS
# ============================================
autoload -Uz compinit && compinit
zinit cdreplay -q

# ============================================
# PLUGINS
# ============================================
zinit ice wait"0" lucid
zinit light zsh-users/zsh-syntax-highlighting

zinit ice wait"0" lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait"0" lucid
zinit light zsh-users/zsh-completions

zinit ice wait"0" lucid
zinit light Aloxaf/fzf-tab

# ============================================
# SNIPPETS
# ============================================
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux

# ============================================
# PROMPT
# ============================================
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
fi

# ============================================
# KEYBINDINGS
# ============================================
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# ============================================
# HISTORY
# ============================================
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_expire_dups_first

# ============================================
# COMPLETION STYLING
# ============================================
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# ============================================
# ALIASES
# ============================================
alias ls='ls --color=auto'
alias vim='nvim'
alias cls='clear'
alias doc="cd ~/Documents"
alias down="cd ~/Downloads"
alias pic="cd ~/Pictures"
alias dot="cd ~/dotfiles"

# ============================================
# SHELL INTEGRATIONS
# ============================================
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# ============================================
# CUSTOM FUNCTIONS
# ============================================
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
