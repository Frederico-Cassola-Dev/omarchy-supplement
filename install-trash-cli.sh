#!/usr/bin/env bash

# Install zsh

echo "#--- Trash-cli instalation ---#"

 if ! command -v trash &>/dev/null; then
  echo "Installing trash-cli..."

   yay -S --noconfirm --needed trash-cli || { echo "ERROR: --> Failed to install trash-cli"; exit 1; }
 else
  echo "WARNING -> Trash-cli already installed, skipping installation"
 fi
