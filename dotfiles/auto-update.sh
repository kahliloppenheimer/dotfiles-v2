# ── Dotfiles Auto-Update ────────────────────────────────────
# Sources from .zshrc - pulls latest dotfiles and optionally re-bootstraps
# Runs in background to not block shell startup

_dotfiles_auto_update() {
    local dotfiles_dir="$HOME/.dotfiles"
    local cache_file="$HOME/.dotfiles_last_update"
    local update_interval="${DOTFILES_UPDATE_INTERVAL:-3600}"  # Default: 1 hour

    # Skip if not a git repo
    [[ -d "$dotfiles_dir/.git" ]] || return 0

    # Rate limit: check timestamp
    if [[ -f "$cache_file" ]]; then
        local last_update=$(cat "$cache_file" 2>/dev/null || echo 0)
        local now=$(date +%s)
        local elapsed=$((now - last_update))
        [[ $elapsed -lt $update_interval ]] && return 0
    fi

    # Update timestamp immediately (prevents parallel runs)
    date +%s > "$cache_file"

    # Fetch and check for changes
    cd "$dotfiles_dir" || return 0
    git fetch --quiet 2>/dev/null || return 0

    local local_head=$(git rev-parse HEAD 2>/dev/null)
    local remote_head=$(git rev-parse @{u} 2>/dev/null)

    # Nothing to do if already up to date
    [[ "$local_head" == "$remote_head" ]] && return 0

    # Pull changes
    if git pull --ff-only --quiet 2>/dev/null; then
        # Re-run bootstrap if it exists (handles new packages, aliases, etc.)
        if [[ -x "$dotfiles_dir/bootstrap.sh" ]]; then
            # Run bootstrap in quiet mode
            DOTFILES_QUIET=1 "$dotfiles_dir/bootstrap.sh" &>/dev/null || true
        fi

        # Notify user
        echo "\n\033[0;32m✓\033[0m Dotfiles updated! Restart shell to apply changes." >&2
    fi
}

# Run in background subshell (won't block shell startup)
(_dotfiles_auto_update &) 2>/dev/null
