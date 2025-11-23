#!/usr/bin/env bash

# Install ghostty terminal emulator

echo "#--- Ghostty instalation ---#"

if ! command -v ghostty &>/dev/null; then
  echo "Installing ghostty shell..."
yay -S --noconfirm --needed ghostty || { echo "ERROR: --> Failed to install ghostty"; exit 1; }
else
  echo "WARNING -> Ghostty already installed, skipping installation"
fi
