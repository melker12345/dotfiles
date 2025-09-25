# Dotfiles

My personal dotfiles managed with GNU Stow.

## Quick Setup

```bash
# 1. Clone the repository
git clone git@github.com:melker12345/dotfiles.git ~/dotfiles

# 2. Generate SSH keys (optional, if you need new ones)
cd ~/dotfiles
./ssh/generate_keys.sh

# 3. Stow all configs
cd ~/dotfiles
stow */  # This stows everything at once
```

## What's Included

- `git/` - Git configuration and aliases
- `hypr/` - Hyprland window manager config
- `ssh/` - SSH config and key generation script
- `wallpapers/` - System wallpapers
- `waybar/` - Waybar status bar config
- `wofi/` - Wofi application launcher
- `zsh/` - Zsh shell configuration with powerlevel10k

## Dependencies

Make sure these are installed:
- `stow`
- `git`
- `zsh`
- `hyprland`
- `waybar`
- `wofi`

## Notes

- The SSH config assumes two keys:
  - `~/.ssh/GitHub` for GitHub
  - `~/.ssh/GHC-melker` for local Git server
- Run `./ssh/generate_keys.sh` to create new SSH keys
- Use `stow -nv */` to see what would be linked without making changes
