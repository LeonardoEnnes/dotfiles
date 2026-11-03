
#!/usr/bin/env bash
# Atualiza componentes já instalados sem reinstalar o ambiente.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

log 'Atualizando pacotes do sistema'
sudo apt-get update
sudo apt-get upgrade -y

# SDKMAN: não é totalmente compatível com nounset.
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  set +u
  load_sdkman

  log 'Atualizando Java'
  install_java

  if [[ -d "$SDKMAN_DIR/candidates/maven/current" ]]; then
    log 'Atualizando Maven'
    sdk upgrade maven || warn 'Não foi possível atualizar Maven'
  fi

  set -u
else
  warn 'SDKMAN ausente; pulando Java/Maven'
fi

# Node.js
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  load_nvm

  log 'Atualizando Node'
  install_node

  if has npm && has pnpm; then
    log 'Atualizando pnpm'
    npm update -g pnpm
  fi
else
  warn 'NVM ausente; pulando Node/pnpm'
fi

# OpenSpec
if has openspec; then
  if has npm && npm list -g @fission-ai/openspec --depth=0 \
      >/dev/null 2>&1; then
    log 'Atualizando OpenSpec'
    npm install -g @fission-ai/openspec@latest
  else
    warn 'OpenSpec não gerenciado pelo npm; atualização ignorada'
  fi
else
  warn 'OpenSpec ausente; execute install.sh'
fi

# Python
if has uv; then
  log 'Atualizando uv'
  uv self update ||
    warn 'uv não atualizado (talvez instalado via gerenciador de pacotes)'
fi

# Plugins do Zsh
log 'Atualizando plugins Zsh'

for dir in "$HOME"/.zsh/plugins/*; do
  [[ -d "$dir/.git" ]] || continue

  if [[ -z "$(git -C "$dir" status --porcelain)" ]]; then
    git -C "$dir" pull --ff-only ||
      warn "Falha ao atualizar $dir"
  else
    warn "Alterações locais em $dir; pulando"
  fi
done

log 'Atualização concluída'
