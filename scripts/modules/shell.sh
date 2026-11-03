#!/usr/bin/env bash
clone_zsh_plugin() {
  local repo="$1" name="$2" dest="$HOME/.zsh/plugins/$2"
  if [[ ! -d "$dest/.git" ]]; then
    if [[ -e "$dest" ]]; then
      warn "Plugin $name já existe sem .git; verifique manualmente: $dest"
      return 0
    fi
    git clone --depth=1 "https://github.com/${repo}.git" "$dest"
  fi
}

shell_install() {
  log 'Instalando plugins do Zsh'
  mkdir -p "$HOME/.zsh/plugins"
  clone_zsh_plugin romkatv/powerlevel10k powerlevel10k
  clone_zsh_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions
  clone_zsh_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
  clone_zsh_plugin zsh-users/zsh-completions zsh-completions
  link "$DOTFILES_DIR/config/zsh/.zshrc" \
     "$HOME/.zshrc"
  link "$DOTFILES_DIR/config/zsh/.p10k.zsh" \
      "$HOME/.p10k.zsh"
}
