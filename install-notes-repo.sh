#!/usr/bin/env bash

ORIGINAL_DIR=$(pwd)
REPO_URL="git@github.com:frederico-cassola-dev/notes.git"
REPO_NAME="notes"

cd || exit 1

clone_success=1

if [ -d "$REPO_NAME" ]; then
	echo "⚠️ WARNING ==> The '$REPO_NAME' folder exists already. Skipping clone..."
	exit 1

else
	echo "📥 ==> Cloning the '$REPO_NAME' repo..."
	git clone "$REPO_URL"
	clone_success=$?
fi

if [ "$clone_success" -eq 0 ]; then
	echo "✅ SUCCESS ==> '$REPO_NAME' repo cloned with success !"
else
	echo "❌ ERROR ==> Failed to clone the repository."
	exit 1
fi
