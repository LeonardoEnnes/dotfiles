#!/usr/bin/env bash
# Atualiza componentes já instalados, sem reinstalar o ambiente inteiro.
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR
# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"
for module in base shell git java node python docker ai wsl; do
  # shellcheck disable=SC1090
  source "$DOTFILES_DIR/scripts/modules/${module}.sh"
done

log 'Atualizando pacotes do sistema'
sudo apt-get update
sudo apt-get upgrade -y

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  load_sdkman
  log 'Atualizando Java (linha configurada)'
  install_java
  if [[ -d "$SDKMAN_DIR/candidates/maven/current" ]]; then
    sdk upgrade maven || warn 'Não foi possível atualizar Maven'
  fi
else
  warn 'SDKMAN ausente; pulando Java/Maven'
fi

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  load_nvm
  log 'Atualizando Node'
  install_node
  if has npm && has pnpm; then npm update -g pnpm; fi
else
  warn 'NVM ausente; pulando Node/pnpm'
fi

if has uv; then
  log 'Atualizando uv'
  uv self update || warn 'uv não atualizado (talvez instalado via gerenciador de pacotes)'
fi

log 'Atualizando plugins Zsh'
for dir in "$HOME"/.zsh/plugins/*; do
  [[ -d "$dir/.git" ]] || continue
  if [[ -z "$(git -C "$dir" status --porcelain)" ]]; then
    git -C "$dir" pull --ff-only || warn "Falha ao atualizar $dir"
  else
    warn "Alterações locais em $dir; pulando"
  fi
done
log 'Atualização concluída'
