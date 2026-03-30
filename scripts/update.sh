#!/bin/bash
set -e

echo "Updating dotfiles..."

# Sistema
sudo apt update && sudo apt upgrade -y

# SDKMAN
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk update

# NVM
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# pnpm
npm install -g pnpm

# Plugins zsh
git -C ~/.zsh/plugins/powerlevel10k pull
git -C ~/.zsh/plugins/zsh-autosuggestions pull
git -C ~/.zsh/plugins/zsh-syntax-highlighting pull

echo "Update finished!"