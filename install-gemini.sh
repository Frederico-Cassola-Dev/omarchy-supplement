#!/usr/bin/env bash

# Install gemini-cli
PACKAGE_NAME='gemini-cli'

if ! command -v gemini &>/dev/null; then
	echo "📥 ==> Installing '$PACKAGE_NAME' package..."
	if npm install -g @google/"$PACKAGE_NAME"; then
		echo "✅ SUCCESS ==> '$PACKAGE_NAME' package installed with success !"
	else
		echo "❌ ERROR ==> Failed to install '$PACKAGE_NAME' package !!!"
		exit 1
	fi
else
	echo "⚠️ WARNING ==> '$PACKAGE_NAME' already installed, skipping installation"
fi
