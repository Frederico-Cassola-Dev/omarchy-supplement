#!/usr/bin/env bash

# Install stow

echo "#--- Stow instalation ---#"

if ! command -v stow &>/dev/null; then
  echo "Installing stow..."

yay -S --noconfirm --needed stow || { echo "ERROR: --> Failed to install stow"; exit 1; }
else
  echo "WARNING -> Stow already installed, skipping installation"
fi
