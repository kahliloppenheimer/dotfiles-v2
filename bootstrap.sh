#!/bin/bash
# ─────────────────────────────────────────────────────────────
# Dotfiles Bootstrap
# 
# curl -fsSL https://raw.githubusercontent.com/kahliloppenheimer/dotfiles-v2/refs/heads/main/bootstrap.sh | bash
# ─────────────────────────────────────────────────────────────

set -euo pipefail

REPO="${DOTFILES_REPO:-https://github.com/kahliloppenheimer/dotfiles-v2.git}"
DOTFILES_DIR="$HOME/.dotfiles"

# Quiet mode (for auto-update)
QUIET="${DOTFILES_QUIET:-0}"

# Colors
info() { [[ "$QUIET" == "1" ]] || echo -e "\033[0;34m::\033[0m $1"; }
success() { [[ "$QUIET" == "1" ]] || echo -e "\033[0;32m✓\033[0m $1"; }
warn() { [[ "$QUIET" == "1" ]] || echo -e "\033[1;33m!\033[0m $1"; }
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

# ── Check if packages are installed ──────────────────────────
packages_installed() {
    command -v zsh &> /dev/null && command -v git &> /dev/null
}

# ── Install packages ─────────────────────────────────────────
install_packages() {
    if packages_installed; then
        success "Required packages already installed"
        return 0
    fi

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
            ;;
        fedora)
            sudo dnf install -y zsh git eza bat
            ;;
        arch)
            sudo pacman -Sy --noconfirm zsh git eza bat
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

    # vimrc
    if [ -f "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then
        mv "$HOME/.vimrc" "$HOME/.vimrc.old"
        success "Backed up ~/.vimrc → ~/.vimrc.old"
    fi
    rm -f "$HOME/.vimrc"
    ln -sf "$DOTFILES_DIR/dotfiles/.vimrc" "$HOME/.vimrc"
    success "Linked ~/.vimrc"

    # Create local override files
    [ -f "$HOME/.zshrc.local" ] || touch "$HOME/.zshrc.local"
    [ -f "$HOME/.tmux.conf.local" ] || touch "$HOME/.tmux.conf.local"
}

# ── Set shell ────────────────────────────────────────────────
set_shell() {
    local zsh_path
    zsh_path=$(which zsh)

    # Add zsh to /etc/shells if not present
    if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
        info "Adding zsh to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        success "Added $zsh_path to /etc/shells"
    fi

    # Change default shell to zsh
    if [ "$SHELL" != "$zsh_path" ]; then
        info "Changing default shell to zsh..."
        chsh -s "$zsh_path"
        success "Default shell changed to zsh (re-login to take effect)"
    else
        success "zsh is already default shell"
    fi
}

# ── Setup clipboard tool (Linux) ─────────────────────────────
setup_clipboard() {
    if [[ "$OS" == "macos" ]]; then
        success "pbcopy/pbpaste already available on macOS"
        return 0
    fi

    # Install rcp if not present
    if ! command -v rcp &> /dev/null; then
        info "Installing rcp for clipboard functionality..."
        local tmp_rcp="/tmp/rcp-linux-amd64"
        if curl -fsSL -o "$tmp_rcp" https://github.com/re-verse/rcp/releases/latest/download/rcp-linux-amd64; then
            chmod +x "$tmp_rcp"
            sudo mv "$tmp_rcp" /usr/local/bin/rcp
            success "rcp installed"
        else
            warn "Could not install rcp, skipping clipboard aliases"
            return 0
        fi
    else
        success "rcp already installed"
    fi

    # Add or update aliases in .zshrc.local
    if ! grep -q "alias pbcopy='rcp'" "$HOME/.zshrc.local" 2>/dev/null; then
        # Remove old pbcopy/pbpaste aliases if they exist
        if grep -q "alias pbcopy" "$HOME/.zshrc.local" 2>/dev/null; then
            sed -i.bak '/# Clipboard aliases/d; /alias pbcopy/d; /alias pbpaste/d' "$HOME/.zshrc.local"
        fi

        cat >> "$HOME/.zshrc.local" << 'EOF'

# Clipboard aliases (Linux compatibility with macOS pbcopy/pbpaste)
alias pbcopy='rcp'
alias pbpaste='rcp --paste'
EOF
        success "Added pbcopy/pbpaste aliases to ~/.zshrc.local"
    else
        success "pbcopy/pbpaste aliases already configured"
    fi
}

# ── Main ─────────────────────────────────────────────────────
main() {
    if [[ "$QUIET" != "1" ]]; then
        echo ""
        echo "┌─────────────────────────────────┐"
        echo "│     Dotfiles Bootstrap          │"
        echo "└─────────────────────────────────┘"
        echo ""
    fi

    install_packages
    install_ohmyzsh
    clone_dotfiles
    link_configs
    set_shell
    setup_clipboard

    if [[ "$QUIET" != "1" ]]; then
        echo ""
        echo "┌─────────────────────────────────┐"
        echo "│         Done! 🌸                │"
        echo "└─────────────────────────────────┘"
        echo ""
        echo "Run this to start using zsh now:"
        echo "  export SHELL=\$(which zsh) && exec zsh"
        echo ""
        echo "Optional: Set font to 'JetBrains Mono Nerd Font'"
        echo "Optional: Import Rosé Pine theme → https://github.com/rose-pine"
        echo ""
    fi
}

main "$@"
