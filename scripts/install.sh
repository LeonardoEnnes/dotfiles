#!/bin/bash
set -e

echo "Setting up dotfiles..."

# ─── ZSH Plugins ───────────────────────────────────────────
mkdir -p ~/.zsh/plugins

[ -d ~/.zsh/plugins/powerlevel10k ] || \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.zsh/plugins/powerlevel10k

[ -d ~/.zsh/plugins/zsh-autosuggestions ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions

[ -d ~/.zsh/plugins/zsh-syntax-highlighting ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting

# ─── System Tools ──────────────────────────────────────────
echo "Installing system tools..."
sudo apt update
sudo apt install -y \
  build-essential curl wget git unzip zip \
  htop net-tools jq ripgrep bat fzf \
  postgresql-client maven

# ─── Docker ────────────────────────────────────────────────
echo "Installing Docker..."
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# ─── SDKMAN + Java ─────────────────────────────────────────
echo "Installing SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21-tem

# ─── NVM + Node ────────────────────────────────────────────
echo "Installing NVM..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
source "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*

# ─── pnpm ──────────────────────────────────────────────────
echo "Installing pnpm..."
npm install -g pnpm

# ─── Symlinks ──────────────────────────────────────────────
echo "Creating symlinks..."
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

ln -sf "$DOTFILES_DIR/scripts/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/scripts/.p10k.zsh" ~/.p10k.zsh

# ─── WSL Config (WSL only) ─────────────────────────────────
if grep -qi microsoft /proc/version; then
  echo "WSL detected, linking wsl.conf..."
  sudo ln -sf "$DOTFILES_DIR/wsl/wsl.conf" /etc/wsl.conf
  echo " Don't forget to copy wsl/.wslconfig to C:\Users\YourUser\.wslconfig"
else
  echo "Not WSL, skipping wsl.conf..."
fi

echo "Done! Restart your terminal."