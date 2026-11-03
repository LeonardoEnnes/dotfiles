#!/usr/bin/env bash
# Shared helpers. Sourced by install/update/doctor.

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*" >&2; }
fail() { printf '\033[1;31m[erro] %s\033[0m\n' "$*" >&2; return 1; }
has() { command -v "$1" >/dev/null 2>&1; }
is_wsl() { grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease 2>/dev/null; }
ARCH="$(dpkg --print-architecture)"
JAVA_MAJOR="${JAVA_MAJOR:-21}"
JAVA_VENDOR="${JAVA_VENDOR:-tem}"
NODE_MAJOR="${NODE_MAJOR:-24}"

link() {
  if (( $# != 2 )); then
    fail "link(): esperado 2 argumentos (origem e destino), recebidos $#"
    return 1
  fi

  local src="$1"
  local dest="$2"

  [[ -e "$src" ]] || {
    fail "Arquivo de origem não encontrado: $src"
    return 1
  }

  mkdir -p "$(dirname "$dest")"

  # Se o symlink já está correto, não faz nada.
  if [[ -L "$dest" ]] &&
     [[ "$(readlink -f -- "$dest")" == "$(realpath -- "$src")" ]]; then
    return 0
  fi

  # Remove symlinks antigos ou quebrados.
  if [[ -L "$dest" ]]; then
    rm -- "$dest"

  # Preserva arquivos existentes.
  elif [[ -e "$dest" ]]; then
    local backup
    backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    mv -- "$dest" "$backup"
    warn "Backup criado: $backup"
  fi

  ln -s -- "$src" "$dest"
  log "Symlink criado: $dest -> $src"
}

install_yq() {
  log 'Instalando yq'
  local yq_arch
  case "$ARCH" in
    amd64|arm64) yq_arch="$ARCH" ;;
    *) fail "Arquitetura não suportada pelo instalador de yq: $ARCH"; return 1 ;;
  esac
  sudo curl -fsSLo /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${yq_arch}"
  sudo chmod +x /usr/local/bin/yq
}

load_sdkman() {
  export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

  if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    fail "SDKMAN não instalado"
    return 1
  fi

  local restore_nounset=false

  if [[ $- == *u* ]]; then
    restore_nounset=true
    set +u
  fi

  # shellcheck source=/dev/null
  source "$SDKMAN_DIR/bin/sdkman-init.sh"

  if [[ "$restore_nounset" == true ]]; then
    set -u
  fi
}

install_java() {
  local candidate="${JAVA_MAJOR}-${JAVA_VENDOR}"

  log "Instalando/selecionando Java $candidate"

  sdk install java "$candidate" </dev/null
  sdk default java "$candidate"
}

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] || { warn 'NVM não instalado'; return 1; }
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh"
}

install_node() {
  local target current
  target="$(nvm version-remote "$NODE_MAJOR")"
  [[ "$target" == v* ]] || { warn "Não foi possível resolver Node $NODE_MAJOR"; return 1; }
  current="$(nvm current)"
  if [[ "$current" == "$target" ]]; then
    log "Node $target já instalado"
  elif [[ "$current" == v* ]]; then
    nvm install "$target" --reinstall-packages-from="$current"
  else
    nvm install "$target"
  fi
  nvm alias default "$NODE_MAJOR"
  nvm use default >/dev/null
}
