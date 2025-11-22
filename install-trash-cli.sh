#!/usr/bin/env bash

# Install zsh
 if ! command -v zsh &>/dev/null; then
   yay -S --noconfirm --needed trash-cli
 fi
