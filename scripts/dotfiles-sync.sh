#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Dotfiles Sync Script
# Pulls latest changes and restows packages
# ─────────────────────────────────────────────────────────────

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
LOG_FILE="${HOME}/.local/log/dotfiles-sync.log"
LOCK_FILE="/tmp/dotfiles-sync.lock"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    pid=$(cat "$LOCK_FILE")
    if kill -0 "$pid" 2>/dev/null; then
        log "Another sync is already running (PID: $pid)"
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Check if dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
    log "ERROR: Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# Fetch and check for changes
log "Checking for updates..."
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u})

if [ "$LOCAL" = "$REMOTE" ]; then
    log "Already up to date"
    exit 0
fi

# Pull changes
log "Updates found, pulling..."
if ! git pull --ff-only; then
    log "ERROR: Pull failed (conflicts?). Manual intervention required."
    exit 1
fi

# Re-stow packages
log "Re-stowing packages..."
for pkg in */; do
    pkg="${pkg%/}"
    if [ -f "$pkg/.nostow" ]; then
        log "Skipping $pkg (has .nostow)"
        continue
    fi
    
    log "Stowing $pkg..."
    stow -R "$pkg" 2>&1 | tee -a "$LOG_FILE" || {
        log "WARNING: Failed to stow $pkg"
    }
done

log "Sync complete!"

# Optional: notify on desktop (if notify-send available)
if command -v notify-send &> /dev/null; then
    notify-send "Dotfiles" "Synced successfully" --icon=dialog-information
fi
