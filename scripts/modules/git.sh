#!/usr/bin/env bash

git_install() {
  log 'Configurando Git'

  link "$DOTFILES_DIR/config/git/.gitconfig" "$HOME/.gitconfig"

  if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    warn "Identidade Git não configurada. Crie ~/.gitconfig.local"
  fi
}