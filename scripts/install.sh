#!/usr/bin/env bash
# Instalação modular dos dotfiles para Ubuntu/WSL.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

for module in base shell git java node python docker ai wsl; do
  # shellcheck disable=SC1090
  source "$DOTFILES_DIR/scripts/modules/${module}.sh"
done

base_install
shell_install
git_install
java_install
node_install
python_install
docker_install
wsl_install

if [[ "$(basename "${SHELL:-/bin/bash}")" != zsh ]]; then
  warn "Seu shell padrão não é zsh. Rode: chsh -s \"$(command -v zsh)\""
fi
log 'Pronto! Reinicie o terminal (ou o WSL) para aplicar tudo.'
