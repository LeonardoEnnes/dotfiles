#!/usr/bin/env bash
git_install() {
  log 'Configurando Git'
  link "$DOTFILES_DIR/scripts/.gitconfig" "$HOME/.gitconfig"
  link "$DOTFILES_DIR/scripts/.gitignore_global" "$HOME/.gitignore_global"
}
