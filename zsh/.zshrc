# ─────────────────────────────────────────────────────────────
# Kahlil's ZSH Configuration
# ─────────────────────────────────────────────────────────────

# ── History ──────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_VERIFY               # Show command before executing from history
setopt SHARE_HISTORY             # Share history between sessions

# ── Directory Navigation ─────────────────────────────────────
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories to stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print stack after pushd/popd

# ── Completion ───────────────────────────────────────────────
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select                    # Arrow key menu
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # Case insensitive
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # Colored completions
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'

# ── Key Bindings ─────────────────────────────────────────────
bindkey -e                       # Emacs keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# ── Aliases ──────────────────────────────────────────────────
# Modern replacements (install: eza, bat, ripgrep, fd, zoxide)
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias lt='eza -la --icons --tree --level=2'
else
    alias ls='ls --color=auto'
    alias ll='ls -la'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    alias less='bat'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# Git shortcuts
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gp='git push'
alias gpu='git pull'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gb='git branch'

# Common operations
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Homelab specific
alias dc='docker compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'
alias k='kubectl'
alias tf='terraform'
alias pm='podman'

# Quick edits
alias zshrc='${EDITOR:-vim} ~/.zshrc && source ~/.zshrc'
alias tmuxrc='${EDITOR:-vim} ~/.tmux.conf && tmux source-file ~/.tmux.conf'

# ── Environment ──────────────────────────────────────────────
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export LANG='en_US.UTF-8'

# Better less defaults
export LESS='-R --mouse --wheel-lines=3'

# FZF configuration (if installed)
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="
        --height=40%
        --layout=reverse
        --border=rounded
        --margin=1
        --padding=1
        --info=inline
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
    "
    # Use fd if available
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    fi
fi

# Zoxide (better cd) - must be at end
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ── Starship Prompt ──────────────────────────────────────────
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ── Local Overrides ──────────────────────────────────────────
# Machine-specific config (not tracked in git)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
