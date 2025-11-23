#!/usr/bin/env bash

# Install all packages in order

./install-ghostty.sh
./install-zsh.sh
./install-ghostty.sh
./install-trash-cli.sh
./install-carapace.sh
./install-stow.sh
./install-dotfiles-omarchy.sh

./set-shell.sh
