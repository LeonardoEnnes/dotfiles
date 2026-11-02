#!/usr/bin/env bash
node_install() {
  if [[ ! -f "$HOME/.nvm/nvm.sh" ]]; then
    log 'Instalando NVM'
    curl -fsSL 'https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh' | PROFILE=/dev/null bash
  fi
  load_nvm
  install_node
  command -v pnpm >/dev/null 2>&1 || npm install -g pnpm
}
