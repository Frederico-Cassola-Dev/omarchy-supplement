#!/bin/bash

# Install zsh
 if ! command -v zsh &>/dev/null; then
   yay -S --noconfirm --needed zsh
 fi

