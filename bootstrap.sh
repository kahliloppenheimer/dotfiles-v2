#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Dotfiles Bootstrap Script
# Run on a new machine to set everything up
# 
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/bootstrap.sh | bash
#    or: ./bootstrap.sh
# ─────────────────────────────────────────────────────────────

set -euo pipefail

# Configuration - CHANGE THESE
DOTFILES_REPO="${DOTFILES_REPO:-git@github.com:YOUR_USERNAME/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── Detect OS ────────────────────────────────────────────────
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
info "Detected OS: $OS"

# ── Install Dependencies ─────────────────────────────────────
install_deps() {
    info "Installing dependencies..."
    
    case "$OS" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y git stow zsh curl wget unzip
            ;;
        fedora)
            sudo dnf install -y git stow zsh curl wget unzip
            ;;
        arch)
            sudo pacman -Sy --noconfirm git stow zsh curl wget unzip
            ;;
        alpine)
            sudo apk add git stow zsh curl wget
            ;;
        macos)
            if ! command -v brew &> /dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install git stow zsh curl wget
            ;;
        *)
            warn "Unknown OS, assuming dependencies are installed"
            ;;
    esac
    
    success "Dependencies installed"
}

# ── Install Modern CLI Tools ─────────────────────────────────
install_tools() {
    info "Installing modern CLI tools..."
    
    case "$OS" in
        ubuntu|debian)
            # eza (modern ls)
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza bat ripgrep fd-find fzf
            
            # bat is installed as batcat on Debian/Ubuntu
            [ ! -f /usr/local/bin/bat ] && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat || true
            [ ! -f /usr/local/bin/fd ] && sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd || true
            ;;
        fedora)
            sudo dnf install -y eza bat ripgrep fd-find fzf
            ;;
        arch)
            sudo pacman -S --noconfirm eza bat ripgrep fd fzf
            ;;
        macos)
            brew install eza bat ripgrep fd fzf
            ;;
    esac
    
    # Install starship (cross-platform)
    if ! command -v starship &> /dev/null; then
        info "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Install zoxide (cross-platform)
    if ! command -v zoxide &> /dev/null; then
        info "Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    success "Tools installed"
}

# ── Clone Dotfiles ───────────────────────────────────────────
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        warn "Dotfiles directory already exists at $DOTFILES_DIR"
        read -p "Pull latest changes? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$DOTFILES_DIR"
            git pull
        fi
    else
        info "Cloning dotfiles..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    success "Dotfiles ready at $DOTFILES_DIR"
}

# ── Stow Packages ────────────────────────────────────────────
stow_packages() {
    info "Stowing packages..."
    cd "$DOTFILES_DIR"
    
    # Backup existing files
    backup_dir="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    
    for pkg in */; do
        pkg="${pkg%/}"
        
        # Skip non-stowable directories
        [[ "$pkg" == "scripts" ]] && continue
        [ -f "$pkg/.nostow" ] && continue
        
        info "Stowing $pkg..."
        
        # Try to stow, backup conflicts
        if ! stow -n "$pkg" 2>&1 | grep -q "existing target"; then
            stow "$pkg"
        else
            warn "Conflicts found for $pkg, backing up..."
            mkdir -p "$backup_dir"
            stow --adopt "$pkg"
            git -C "$DOTFILES_DIR" checkout -- "$pkg"
            stow "$pkg"
        fi
    done
    
    success "All packages stowed"
}

# ── Setup Shell ──────────────────────────────────────────────
setup_shell() {
    info "Setting up shell..."
    
    # Change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        info "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi
    
    # Install TPM for tmux
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        info "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi
    
    success "Shell setup complete"
}

# ── Setup Systemd Timer ──────────────────────────────────────
setup_sync_timer() {
    # Only on Linux with systemd
    if [ "$OS" != "macos" ] && command -v systemctl &> /dev/null; then
        info "Setting up auto-sync timer..."
        
        # Make sync script executable
        chmod +x "$DOTFILES_DIR/scripts/dotfiles-sync.sh"
        
        # Enable and start timer
        systemctl --user daemon-reload
        systemctl --user enable dotfiles-sync.timer
        systemctl --user start dotfiles-sync.timer
        
        success "Auto-sync timer enabled (runs every 30 minutes)"
    else
        warn "Skipping systemd timer (not available on this system)"
        info "Consider setting up a cron job instead:"
        echo "  */30 * * * * $DOTFILES_DIR/scripts/dotfiles-sync.sh"
    fi
}

# ── Install Nerd Font ────────────────────────────────────────
install_font() {
    info "Installing JetBrains Mono Nerd Font..."
    
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -o JetBrainsMono.zip -d "$FONT_DIR"
        rm JetBrainsMono.zip
        
        # Refresh font cache
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv
        fi
        
        success "Font installed"
    else
        success "Font already installed"
    fi
    
    info "Remember to set your terminal font to 'JetBrainsMono Nerd Font'"
}

# ── Main ─────────────────────────────────────────────────────
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║       Dotfiles Bootstrap Script       ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    
    install_deps
    install_tools
    clone_dotfiles
    stow_packages
    setup_shell
    setup_sync_timer
    install_font
    
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║           Setup Complete! 🎉          ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and back in (or run: exec zsh)"
    echo "  2. In tmux, press Ctrl-a + I to install plugins"
    echo "  3. Set your terminal font to 'JetBrainsMono Nerd Font'"
    echo ""
}

main "$@"
