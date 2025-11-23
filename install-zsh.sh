#!/usr/bin/env bash

# Install zsh

echo "#--- Zsh instalation ---#"

if ! command -v zsh &>/dev/null; then
  echo "Installing zsh shell..."

  yay -S --noconfirm --needed zsh || { echo "ERROR: --> Failed to install zsh"; exit 1; }
else
  echo "WARNING -> Zsh already installed, skipping installation"
fi

