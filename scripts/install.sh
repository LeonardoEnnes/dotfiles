#!/usr/bin/env bash
# Instalação modular dos dotfiles para Ubuntu/WSL.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR

# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

# --- Gerenciamento de Configuração (.env) ---
ENV_FILE="$DOTFILES_DIR/.env"
ENV_EXAMPLE="$DOTFILES_DIR/.env.example"

if [[ ! -f "$ENV_FILE" ]]; then
    if [[ -f "$ENV_EXAMPLE" ]]; then
        warn "Arquivo .env não encontrado. Criando um a partir do .env.example..."
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        fail "Por favor, edite o arquivo '$ENV_FILE' com seus dados reais (Git user/email) e execute o instalador novamente."
    else
        fail "Nem .env nem .env.example foram encontrados!"
    fi
fi

# Carrega as variáveis do .env de forma segura
set -a
# shellcheck source=/dev/null
source "$ENV_FILE"
set +a
# --------------------------------------------

for module in base shell git java node python docker openspec wsl; do
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
openspec_install
wsl_install

if [[ "$(basename "${SHELL:-/bin/bash}")" != zsh ]]; then
  warn "Seu shell padrão não é zsh. Rode: chsh -s \"$(command -v zsh)\""
fi
log 'Pronto! Reinicie o terminal (ou o WSL) para aplicar tudo.'