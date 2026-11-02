#!/usr/bin/env bash
base_install() {
  log 'Instalando pacotes do sistema'
  mkdir -p "$HOME/.local/bin"
  sudo apt-get update
  sudo apt-get install -y \
    build-essential ca-certificates curl wget gnupg git zsh \
    unzip zip htop net-tools jq ripgrep bat fzf \
    postgresql-client zoxide eza git-delta direnv tldr lsof

  if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
  if ! command -v yq >/dev/null 2>&1; then
    install_yq
  fi
}
