# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's Included

| Package   | Description                                      |
|-----------|--------------------------------------------------|
| `zsh`     | ZSH config with aliases, history, completions    |
| `starship`| Minimal, fast prompt with Catppuccin theme       |
| `tmux`    | Terminal multiplexer with Catppuccin theme       |
| `systemd` | Auto-sync timer (pulls updates every 30 min)     |
| `scripts` | Utility scripts (sync, etc.)                     |

## Quick Start

### New Machine

```bash
# One-liner (after customizing DOTFILES_REPO in bootstrap.sh)
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/bootstrap.sh | bash

# Or clone and run
git clone git@github.com:YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

### Manual Setup

```bash
# Install stow
sudo apt install stow  # or: brew install stow

# Clone
git clone git@github.com:YOUR_USER/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Stow individual packages
stow zsh
stow tmux
stow starship
stow systemd

# Or stow everything
for d in */; do stow "${d%/}"; done
```

## Structure

```
~/.dotfiles/
├── zsh/
│   └── .zshrc              → ~/.zshrc
├── tmux/
│   └── .tmux.conf          → ~/.tmux.conf
├── starship/
│   └── .config/
│       └── starship.toml   → ~/.config/starship.toml
├── systemd/
│   └── .config/
│       └── systemd/
│           └── user/
│               ├── dotfiles-sync.service
│               └── dotfiles-sync.timer
├── scripts/
│   └── dotfiles-sync.sh
├── bootstrap.sh
└── README.md
```

## Auto-Sync

The systemd timer automatically pulls dotfiles updates every 30 minutes.

```bash
# Check timer status
systemctl --user status dotfiles-sync.timer

# View sync logs
cat ~/.local/log/dotfiles-sync.log

# Manual sync
~/.dotfiles/scripts/dotfiles-sync.sh

# Disable auto-sync
systemctl --user disable dotfiles-sync.timer
```

### For systems without systemd (macOS, Alpine)

Add to crontab:

```bash
crontab -e
# Add: */30 * * * * ~/.dotfiles/scripts/dotfiles-sync.sh
```

## Dependencies

These tools are installed by bootstrap.sh:

- **[Starship](https://starship.rs/)** - Prompt
- **[eza](https://eza.rocks/)** - Modern `ls`
- **[bat](https://github.com/sharkdp/bat)** - Modern `cat`
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** - Modern `grep`
- **[fd](https://github.com/sharkdp/fd)** - Modern `find`
- **[fzf](https://github.com/junegunn/fzf)** - Fuzzy finder
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** - Smarter `cd`
- **[JetBrains Mono Nerd Font](https://www.nerdfonts.com/)** - Terminal font

## Machine-Specific Config

Create `~/.zshrc.local` for machine-specific settings (not tracked):

```bash
# ~/.zshrc.local
export EDITOR='nvim'
alias work='cd ~/work/myproject'
```

## Updating

```bash
cd ~/.dotfiles
git pull
# Re-stow if structure changed
stow -R zsh tmux starship
```

## Tmux Keybindings

| Key | Action |
|-----|--------|
| `C-a` | Prefix (instead of C-b) |
| `C-a \|` | Split vertical |
| `C-a -` | Split horizontal |
| `C-a hjkl` | Navigate panes |
| `M-1..9` | Switch to window N |
| `C-a r` | Reload config |
| `C-a I` | Install plugins (TPM) |
| `C-a s` | Session picker |

## Theme

Everything uses [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) for consistency.
Set your terminal theme to Catppuccin Mocha for best results:
- [iTerm2](https://github.com/catppuccin/iterm)
- [Windows Terminal](https://github.com/catppuccin/windows-terminal)
- [Alacritty](https://github.com/catppuccin/alacritty)
- [Kitty](https://github.com/catppuccin/kitty)
