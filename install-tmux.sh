#!/usr/bin/env bash

# Install TMUX
PACKAGE_NAME='tmux'
PACKAGE_NAME_VERSION='tmux'

# Install TPM
REPO_NAME="TMUX plugins manager - TPM"
REPO_PATH="$HOME/.tmux/plugins/tpm"
REPO_URL="https://github.com/tmux-plugins/tpm"
echo '$HOME'
clone_success=1

if ! command -v "$PACKAGE_NAME_VERSION" &>/dev/null; then
	echo "📥 ==> Installing '$PACKAGE_NAME' package..."
	if yay -S --noconfirm --needed "$PACKAGE_NAME"; then
		echo "✅ SUCCESS ==> '$PACKAGE_NAME' package installed with success !"
	else
		echo "❌ ERROR ==> Failed to install '$PACKAGE_NAME' package !!!"
		exit 1
	fi
else
	echo "⚠️ WARNING ==> '$PACKAGE_NAME' already installed, skipping installation"
fi

# 2) Install TPM
if [ -d "$REPO_PATH" ]; then
	echo "⚠️ WARNING ==> The '$REPO_NAME' folder exists already in '$REPO_PATH'. Skipping clone..."
	exit 0
else
	echo "📥 ==> Cloning the '$REPO_NAME' repo..."
	git clone "$REPO_URL" "$REPO_PATH"
	clone_success=$?
fi

if [ "$clone_success" -eq 0 ]; then
	echo "✅ SUCCESS ==> '$REPO_NAME' repo cloned with success !"
	echo "ℹ️ INFO ==> Inside '$REPO_NAME' CTRL-I to install the plugins specify in the config <== INFO ℹ️"
else
	echo "❌ ERROR ==> Failed to clone the repository."
	exit 1
fi
