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


# ── Custom Functions  ──────────────────────────────────────────────────
# -- p: Run command and copy formatted output --
# Usage: p ls -la
# Copies "$ ls -la\n<output>" to clipboard (works over SSH via OSC 52)
# -- p: Run command and copy formatted output --
# Usage: p ls -la
# Copies "$ ls -la\n<output>" to clipboard (works over SSH via OSC 52)
p() {
    local output cmd_string="$*"
    
    # Capture output, allowing alias expansion via eval
    output=$(eval "$cmd_string" 2>&1)
    local exit_code=$?
    
    local formatted="$ $cmd_string
$output"
    
    _copy_to_clipboard() {
        local text="$1"
        
        # OSC 52: works over SSH if terminal supports it (iTerm, kitty, etc.)
        if [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CONNECTION" ]]; then
            local encoded=$(printf '%s' "$text" | base64 | tr -d '\n')
            printf '\033]52;c;%s\a' "$encoded"
            return 0
        fi
        
        # Local clipboard tools
        if command -v pbcopy &> /dev/null; then
            printf '%s' "$text" | pbcopy
        elif command -v xclip &> /dev/null; then
            printf '%s' "$text" | xclip -selection clipboard
        elif command -v xsel &> /dev/null; then
            printf '%s' "$text" | xsel --clipboard --input
        elif [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy &> /dev/null; then
            printf '%s' "$text" | wl-copy
        else
            return 1
        fi
    }
    
    if _copy_to_clipboard "$formatted"; then
        echo "$output"
        echo "\n[copied to clipboard]" >&2
    else
        echo "$output"
        echo "\n[clipboard not available]" >&2
    fi
    
    return $exit_code
}

# ── Local Overrides ──────────────────────────────────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
