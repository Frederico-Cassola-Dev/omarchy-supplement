#!/usr/bin/env bash

# Install carapace

echo "#--- Carapace instalation ---#"

if ! command -v carapace &>/dev/null; then
  echo "Installing Carapace..."

  yay -S --noconfirm --needed carapace|| { echo "ERROR: --> Failed to install carapace"; exit 1; }
else
  echo "WARNING -> Carapace already installed, skipping installation"
fi
