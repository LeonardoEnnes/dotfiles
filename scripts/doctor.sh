#!/usr/bin/env bash
# Diagnóstico somente leitura. Não altera o sistema.
set -uo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR
# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"
failures=0
check_cmd() {
  local label="$1" command_name="$2"
  if has "$command_name"; then
    printf 'OK   %-16s %s\n' "$label" "$(command -v "$command_name")"
  else
    printf 'FAIL %-16s ausente\n' "$label"
    failures=$((failures + 1))
  fi
}
check_link() {
  local path="$1"
  if [[ -L "$path" && -e "$path" ]]; then
    printf 'OK   symlink          %s\n' "$path"
  else
    printf 'FAIL symlink          %s\n' "$path"
    failures=$((failures + 1))
  fi
}

log 'Diagnóstico do ambiente'
for cmd in git zsh curl java mvn node npm pnpm uv yq openspec; do
  check_cmd "$cmd" "$cmd"
done
check_link "$HOME/.zshrc"
check_link "$HOME/.gitconfig"
if is_wsl; then
  printf 'INFO WSL               detectado\n'
  [[ -r /etc/wsl.conf ]] && printf 'INFO WSL config        /etc/wsl.conf presente\n'
  if has docker && docker info >/dev/null 2>&1; then
    printf 'OK   Docker            daemon acessível\n'
  else
    printf 'WARN Docker            não acessível (verifique Docker Desktop e integração WSL)\n'
  fi
else
  printf 'INFO WSL               não detectado\n'
fi
if (( failures > 0 )); then
  printf '\n%d verificação(ões) falharam.\n' "$failures"
  exit 1
fi
printf '\nDiagnóstico básico aprovado.\n'
