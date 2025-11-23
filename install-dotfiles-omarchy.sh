#!/usr/bin/env bash

ORIGINAL_DIR=$(pwd)
REPO_URL="https://github.com/frederico-cassola-dev/dotfiles-omarchy"
REPO_NAME="dotfiles-omarchy"

is_stow_installed() {
  pacman -Qi "stow" &>/dev/null
}

if ! is_stow_installed; then
  echo "Install stow first"
  exit 1
fi

cd ~

clone_success=1 # Default to success if repo already exists

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
  echo "Repository '$REPO_NAME' already exists. Skipping clone"
else
  git clone "$REPO_URL"
  clone_success=$?
fi

# Proceed only if cloning succeeded or repo existed
if [ $clone_success -eq 0 ]; then
  echo "removing old configs"
  # To uncomment when everything is done:
  trash-put ~/.bashrc
  trash-put ~/.bash_profile
  trash-put ~/.zshrc
  trash-put ~/.config/ghostty/config
  trash-put ~/.config/starship.toml
  trash-put ~/.config/nvim
  trash-put ~/.local/share/nvim/
  trash-put ~/.cache/nvim/
  trash-put ~/.config/hypr/bindings.conf
  trash-put ~/.config/hypr/looknfeel.conf
  trash-put ~/.config/hypr/monitors.conf

  cd "$REPO_NAME"
  stow bashrc
  stow zshrc
  stow ghostty
  stow hypr
  stow startup-omarchy
  stow nvim
  stow starship
else
  echo "Failed to clone the repository."
  exit 1
fi
