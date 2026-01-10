# dotfiles

Minimal zsh + tmux setup with Rosé Pine theme.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/kahliloppenheimer/dotfiles-v2/refs/heads/main/bootstrap.sh | bash
```

Or manually:

```bash
git clone https://github.com/kahliloppenheimer/dotfiles-v2.git ~/.dotfiles
~/.dotfiles/bootstrap.sh
```

## What's included

- **zsh** with oh-my-zsh, custom Rosé Pine prompt, history settings
- **tmux** with Rosé Pine status bar, vim keybindings, `C-a` prefix
- **eza** and **bat** aliases (if installed)
- **`p` command** — run any command and copy formatted output to clipboard

## Structure

```
~/.dotfiles/
├── bootstrap.sh      # installer
├── dotfiles/
│   ├── .zshrc
│   └── .tmux.conf
└── README.md
```

## Local overrides

Machine-specific config goes in:
- `~/.zshrc.local`
- `~/.tmux.conf.local`

## Theme

[Rosé Pine](https://rosepinetheme.com) — install for your terminal:
- [iTerm2](https://github.com/rose-pine/iterm)
- [Alacritty](https://github.com/rose-pine/alacritty)
- [Windows Terminal](https://github.com/rose-pine/windows-terminal)

Font: [JetBrains Mono Nerd Font](https://www.nerdfonts.com/)
