#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Dotfiles Bootstrap
# 
# curl -fsSL https://raw.githubusercontent.com/YOURUSER/dotfiles/main/bootstrap.sh | bash
# ─────────────────────────────────────────────────────────────

set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/YOURUSER/dotfiles.git}"
DOTFILES_DIR="$HOME/.dotfiles"

# Colors
info() { echo -e "\033[0;34m::\033[0m $1"; }
success() { echo -e "\033[0;32m✓\033[0m $1"; }
warn() { echo -e "\033[1;33m!\033[0m $1"; }
error() { echo -e "\033[0;31m✗\033[0m $1"; exit 1; }

# ── Detect OS ────────────────────────────────────────────────
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
info "Detected: $OS"

# ── Install packages ─────────────────────────────────────────
install_packages() {
    info "Installing packages..."
    
    case "$OS" in
        macos)
            if ! command -v brew &> /dev/null; then
                info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install zsh eza bat git
            brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || true
            ;;
        ubuntu|debian)
            sudo apt update
            sudo apt install -y zsh git curl
            # eza
            if ! command -v eza &> /dev/null; then
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
                sudo apt update && sudo apt install -y eza 2>/dev/null || warn "Could not install eza"
            fi
            sudo apt install -y bat 2>/dev/null || sudo apt install -y batcat 2>/dev/null || true
            [ -f /usr/bin/batcat ] && sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
            sudo apt install -y xclip 2>/dev/null || true
            ;;
        fedora)
            sudo dnf install -y zsh git eza bat xclip
            ;;
        arch)
            sudo pacman -Sy --noconfirm zsh git eza bat xclip
            ;;
        alpine)
            sudo apk add zsh git bat
            ;;
        *)
            warn "Unknown OS, skipping package install"
            ;;
    esac
    
    success "Packages installed"
}

# ── Install oh-my-zsh ────────────────────────────────────────
install_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        info "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "oh-my-zsh installed"
    else
        success "oh-my-zsh already installed"
    fi
}

# ── Clone or update dotfiles ─────────────────────────────────
clone_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        info "Updating existing dotfiles..."
        git -C "$DOTFILES_DIR" pull --ff-only || warn "Could not pull, using existing"
    else
        info "Cloning dotfiles..."
        git clone "$REPO" "$DOTFILES_DIR"
    fi
    success "Dotfiles ready"
}

# ── Link configs ─────────────────────────────────────────────
link_configs() {
    info "Linking configs..."
    
    # zshrc
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        mv "$HOME/.zshrc" "$HOME/.zshrc.old"
        success "Backed up ~/.zshrc → ~/.zshrc.old"
    fi
    rm -f "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
    success "Linked ~/.zshrc"
    
    # tmux.conf
    if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.old"
        success "Backed up ~/.tmux.conf → ~/.tmux.conf.old"
    fi
    rm -f "$HOME/.tmux.conf"
    ln -sf "$DOTFILES_DIR/dotfiles/.tmux.conf" "$HOME/.tmux.conf"
    success "Linked ~/.tmux.conf"
    
    # Create local override files
    [ -f "$HOME/.zshrc.local" ] || touch "$HOME/.zshrc.local"
    [ -f "$HOME/.tmux.conf.local" ] || touch "$HOME/.tmux.conf.local"
}

# ── Set shell ────────────────────────────────────────────────
set_shell() {
    local zsh_path
    zsh_path=$(which zsh)
    
    if [ "$SHELL" != "$zsh_path" ]; then
        info "Setting zsh as default shell..."
        if grep -q "$zsh_path" /etc/shells 2>/dev/null; then
            chsh -s "$zsh_path" || warn "Could not change shell, run: chsh -s $zsh_path"
        else
            warn "Add zsh to /etc/shells: echo $zsh_path | sudo tee -a /etc/shells"
        fi
    else
        success "zsh is already default"
    fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
    echo ""
    echo "┌─────────────────────────────────┐"
    echo "│     Dotfiles Bootstrap          │"
    echo "└─────────────────────────────────┘"
    echo ""
    
    install_packages
    install_ohmyzsh
    clone_dotfiles
    link_configs
    set_shell
    
    echo ""
    echo "┌─────────────────────────────────┐"
    echo "│         Done! 🌸                │"
    echo "└─────────────────────────────────┘"
    echo ""
    echo "Restart your terminal or run: exec zsh"
    echo ""
    echo "Optional: Set font to 'JetBrains Mono Nerd Font'"
    echo "Optional: Import Rosé Pine theme → https://github.com/rose-pine"
    echo ""
}

main "$@"
