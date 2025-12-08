#!/usr/bin/env bash

REPO_NAME='nextjs-redux-shadcn-todo-app'
REPO_URL='git@github.com:Frederico-Cassola-Dev/nextjs-redux-shadcn-todo-app.git'
TARGET_DIR='Work'

cd || exit 1
cd "$TARGET_DIR" || exit 1

clone_success=1

if [ -d "$REPO_NAME" ]; then
	echo "⚠️ WARNING ==> The '$REPO_NAME' folder exists already in ~/'$TARGET_DIR'. Skipping clone..."
	exit 1

else
	echo "📥 ==> Cloning the '$REPO_NAME' repo in ~/'$TARGET_DIR' ..."
	git clone "$REPO_URL"
	clone_success=$?
fi

if [ "$clone_success" -eq 0 ]; then
	echo "✅ SUCCESS ==> '$REPO_NAME' repo cloned with success in ~/'$TARGET_DIR' !"
else
	echo "❌ ERROR ==> Failed to clone the repository."
	exit 1
fi
