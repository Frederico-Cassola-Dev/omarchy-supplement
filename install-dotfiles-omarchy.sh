#!/usr/bin/env bash

ORIGINAL_DIR=$(pwd)
REPO_URL="git@github.com:frederico-cassola-dev/dotfiles-omarchy.git"
REPO_NAME="dotfiles-omarchy"

is_stow_installed() {
	pacman -Qi "stow" &>/dev/null
}

if ! is_stow_installed; then
	echo "Install stow first"
	exit 1
fi

cd || exit 1

clone_success=1 # Default to success if repo already exists

# Check if the repository already exists
if [ -d "$REPO_NAME" ]; then
	echo "⚠️ WARNING ==> The '$REPO_NAME' folder exists already. Skipping clone..."
	exit 1
else
	echo "📥 ==> Cloning the '$REPO_NAME' repo..."
	git clone "$REPO_URL"
	clone_success=$?
fi

# Proceed only if cloning succeeded or repo existed
if [ $clone_success -eq 0 ]; then
	echo "==> Removing old configs..."

	trash-put ~/.bashrc
	trash-put ~/.bash_profile
	trash-put ~/.zshrc
	trash-put ~/.config/ghostty/config
	trash-put ~/.config/starship.toml
	trash-put ~/.config/nvim
	trash-put ~/.local/share/nvim
	trash-put ~/.cache/nvim
	trash-put ~/.config/hypr

	cd "$REPO_NAME" || exit 1
	stow bashrc
	stow zshrc
	stow ghostty
	stow starship
	stow nvim
	stow hypr
	stow startup-omarchy

	echo "✅ SUCCESS ==> '$REPO_NAME' configs STOW with success !"
else
	echo "❌ ERROR ==> Failed to clone the '$REPO_NAME' repository."
	exit 1
fi
