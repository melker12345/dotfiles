#!/usr/bin/env bash
set -euo pipefail

# Config
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
SWITCH_TO_ZSH="${SWITCH_TO_ZSH:-0}"  # set to 1 to switch to zsh at the end

require() { command -v "$1" >/dev/null 2>&1; }

install_pacman() {
  if require pacman; then
    sudo pacman -Syu --needed --noconfirm "$@"
  else
    echo "pacman not found. Skipping package installation: $*"
  fi
}

echo "==> Ensuring required packages"
install_pacman git stow neovim zsh

echo "==> Verifying dotfiles directory: $DOTFILES_DIR"
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "Dotfiles repo not found at $DOTFILES_DIR"; exit 1
fi
cd "$DOTFILES_DIR"

echo "==> Stowing user packages to $HOME (with --adopt to take over existing defaults)"
for pkg in */; do
  pkg="${pkg%/}"
  [ "$pkg" = "system" ] && continue
  stow -Rvt "$HOME" --adopt "$pkg"
done

echo "==> Neovim plugin manager (packer.nvim)"
PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"
if [ ! -d "$PACKER_DIR" ]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim "$PACKER_DIR"
fi

echo "==> Neovim plugin sync (headless)"
if require nvim; then
  nvim --headless "+PackerSync" "+qall" || true
fi

echo "==> Reloading desktop components if available"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && require hyprctl; then
  hyprctl reload || true
fi
if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar || true
  nohup waybar >/dev/null 2>&1 & disown || true
fi

echo "==> Shell setup"
if require zsh && [ -x /bin/zsh ]; then
  if [ "${SHELL:-}" != "/bin/zsh" ]; then
    chsh -s /bin/zsh || true
  fi
  if [ "$SWITCH_TO_ZSH" = "1" ]; then
    exec zsh -l
  fi
fi

echo "==> Done. Your configs are now active."
echo "Tip: open a new terminal or run 'exec zsh' to load shell changes."