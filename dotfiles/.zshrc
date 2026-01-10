export ZSH="$HOME/.oh-my-zsh"

# ── Theme · Rosé Pine ────────────────────────────────────────
# Palette: pine=#31748f, rose=#ebbcba, gold=#f6c177, iris=#c4a7e7, foam=#9ccfd8
# Prompt: hostname (muted) · directory (foam) · git (iris/rose) · arrow (gold)
PROMPT='%F{#6e6a86}%m%f %F{#9ccfd8}%c%f $(git_prompt_info)%F{#f6c177}→%f '

# ── ZSH Settings ──────────────────────────────────────────────────
ZSH_THEME_GIT_PROMPT_PREFIX="%F{#c4a7e7}git:(%F{#ebbcba}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{#c4a7e7}) %F{#f6c177}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{#c4a7e7})"

plugins=(git)

# Allow autocomplete to pick up dotfiles
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' file-patterns '.*:all-files' '*:all-files'

source $ZSH/oh-my-zsh.sh

# ── History ──────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_SPACE         # Don't record lines starting with space
setopt SHARE_HISTORY             # Share history between sessions

# ── Environment ──────────────────────────────────────────────
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export LANG='en_US.UTF-8'

# ── Aliases ──────────────────────────────────────────────────
alias df='df -h'
alias du='du -h'

# Modern replacements (if installed)
if command -v eza &> /dev/null; then
    alias ls='eza --group-directories-first'
    alias ll='eza -la --group-directories-first --git'
    alias lt='eza -la --tree --level=2'
fi

if command -v bat &> /dev/null; then
    alias cat='bat --paging=never --style=plain'
    export BAT_THEME="rose-pine"
fi

# ── Local Overrides ──────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
