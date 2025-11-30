#!/usr/bin/env bash

# Check if zsh is installed
#
SHELL_NAME='zsh'
# echo "#--- Set ZSH as default shell ---#"

if ! command -v "$SHELL_NAME" &>/dev/null; then
	echo "⚠️ WARNING ==> '$SHELL_NAME'  is not installed. Please run ./install-all.sh first."
	exit 1
fi

# Get the path to zsh
ZSH_PATH=$(which zsh)

# Check if zsh is already the default shell
if [ "$SHELL" = "$ZSH_PATH" ]; then
	echo "✅ SUCCESS ==> '$SHELL_NAME' is already your default shell !"
	exit 0
fi

# Add zsh to /etc/shells if not already there
if ! grep -q "^$ZSH_PATH$" /etc/shells; then
	echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

# Change the default shell to zsh
chsh -s "$ZSH_PATH"

echo "✅ SUCCESS ==> Default shell changed to '$SHELL_NAME' !"
echo "⚠️  IMPORTANT ==> Please log out and log back in for the change to take effect !!!"
