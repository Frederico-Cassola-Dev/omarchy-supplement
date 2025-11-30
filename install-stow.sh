#!/usr/bin/env bash

# Install stow
PACKAGE_NAME='stow'

if ! command -v "$PACKAGE_NAME" &>/dev/null; then
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
