#!/usr/bin/env bash
git_install() {
  log 'Configurando Git'
  link "$DOTFILES_DIR/config/git/.gitconfig"
}
