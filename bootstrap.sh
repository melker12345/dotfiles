#!/usr/bin/env bash
set -euo pipefail

# Config — change if needed
GITHUB_USER="melker12345"
REPO_NAME="dotfiles"
REPO_HTTPS="https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
REPO_SSH="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
DOTFILES_DIR="$HOME/dotfiles"
SSH_KEY_PATH="$HOME/.ssh/GitHub"
NVIM_PACKER_DIR="$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim"

# Optional: set USE_ADOPT=1 to adopt existing files into dotfiles when stowing
STOW_FLAGS="${STOW_FLAGS:-}"
if [[ "${USE_ADOPT:-0}" == "1" ]]; then
  STOW_FLAGS="--adopt"
fi

require() {
  command -v "$1" >/dev/null 2>&1
}

install_pacman() {
  if require pacman; then
    sudo pacman -Syu --needed --noconfirm "$@"
  else
    echo "pacman not found. Are you on Arch? Install packages manually: $*"
  fi
}

echo "==> Installing base packages"
install_pacman git stow neovim zsh

# Optional: install desktop bits used by your configs (uncomment if wanted)
# install_pacman hyprland waybar wofi wl-clipboard

echo "==> Ensuring ~/.ssh exists with correct perms"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

echo "==> Cloning dotfiles (HTTPS first for bootstrap)"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "Dotfiles already present at $DOTFILES_DIR"
else
  git clone "$REPO_HTTPS" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"

echo "==> Stowing user packages to \$HOME"
for pkg in */; do
  pkg="${pkg%/}"
  [[ "$pkg" == "system" ]] && continue
  stow -Rvt "$HOME" $STOW_FLAGS "$pkg"
done

echo "==> Generating GitHub SSH key if missing"
if [[ ! -f "$SSH_KEY_PATH" ]]; then
  # Remove -N "" if you want to set a passphrase interactively
  ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -C "${GITHUB_USER}@users.noreply.github.com"
fi

echo "==> Starting ssh-agent and adding key"
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
  eval "$(ssh-agent -s)"
else
  eval "$(ssh-agent -s)" >/dev/null
fi
ssh-add "$SSH_KEY_PATH"

echo "==> Print public key — add this to GitHub (Settings -> SSH and GPG keys)"
echo "-----------------------------------------------------------------------"
cat "${SSH_KEY_PATH}.pub"
echo "-----------------------------------------------------------------------"

echo "==> Switching dotfiles remote to SSH"
git remote set-url origin "$REPO_SSH"
git remote -v

echo "==> Installing packer.nvim for Neovim if missing"
if [[ ! -d "$NVIM_PACKER_DIR" ]]; then
  git clone --depth 1 https://github.com/wbthomason/packer.nvim "$NVIM_PACKER_DIR"
fi

echo "==> Syncing Neovim plugins"
nvim "+PackerSync" "+qall" || true

echo "==> Optional: make zsh your default shell"
if [[ "$SHELL" != "/bin/zsh" && -x /bin/zsh ]]; then
  chsh -s /bin/zsh || true
fi

echo "==> Done!"
echo "- If you just added your SSH key to GitHub, test: ssh -T git@github.com"
echo "- Push your repo: git -C \"$DOTFILES_DIR\" push -u origin master"