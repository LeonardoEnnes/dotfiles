#!/usr/bin/env bash
# Funções compartilhadas entre install.sh e update.sh

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[aviso] %s\033[0m\n' "$*"; }

is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

# amd64 | arm64 (formato do dpkg, usado pelo yq e pelos repositórios apt)
ARCH="$(dpkg --print-architecture)"

# Cria symlink fazendo backup se já existir um arquivo real no destino
link() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backup criado para $dest"
  fi
  ln -sfn "$src" "$dest"
}

# Última tag de release de um repositório no GitHub (ex: "v4.44.3")
latest_github_tag() {
  local headers=()
  [ -n "${GITHUB_TOKEN:-}" ] && headers=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${headers[@]}" "https://api.github.com/repos/$1/releases/latest" | jq -r .tag_name
}

install_yq() {
  log "Instalando yq"
  sudo curl -fsSLo /usr/local/bin/yq \
    "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}"
  sudo chmod +x /usr/local/bin/yq
}

# ─── Versões fixadas ──────────────────────────────────────
# Só o MAJOR é fixo; patches (21.0.x, 24.x.y)
# Para trocar numa execução: JAVA_MAJOR=17 bash install.sh
JAVA_MAJOR="${JAVA_MAJOR:-21}"
JAVA_VENDOR="${JAVA_VENDOR:-tem}"   # tem = Eclipse Temurin
NODE_MAJOR="${NODE_MAJOR:-24}"

# Instala (ou atualiza) o patch mais recente do Java $JAVA_MAJOR e define como padrão
install_java() {
  local id
  sdk update </dev/null || true

  # Tenta buscar a versão disponível de forma mais tolerante
  id="$(sdk list java | grep -oE "\b${JAVA_MAJOR}\.[0-9.]+-${JAVA_VENDOR}\b" | sort -uV | tail -1)"
  
  # Fallback direto caso a listagem falhe em ambientes limpos de CI
  if [ -z "$id" ]; then
    id="${JAVA_MAJOR}.0.2-${JAVA_VENDOR}"
  fi

  if [ -d "$SDKMAN_DIR/candidates/java/$id" ]; then
    echo "  Java $id já está instalado"
  else
    log "Instalando Java $id"
    sdk install java "$id" </dev/null || sdk install java "${JAVA_MAJOR}-open" </dev/null
  fi
  
  # Garante que define o default independentemente da string exata instalada
  local current_default
  current_default="$(sdk current java | awk '{print $NF}')"
  if [[ "$current_default" != *"${JAVA_MAJOR}"* ]]; then
    sdk default java "$id" || true
  fi
}

# Instala (ou atualiza) o patch mais recente do Node $NODE_MAJOR,
# levando os pacotes globais (pnpm etc.) da versão anterior
install_node() {
  local target current
  target="$(nvm version-remote "$NODE_MAJOR")"
  current="$(nvm current)"
  if [ "$current" = "$target" ]; then
    echo "  Node $target já é o mais recente da linha $NODE_MAJOR"
  elif [[ "$current" == v* ]]; then
    log "Atualizando Node $current -> $target"
    nvm install "$target" --reinstall-packages-from="$current"
  else
    log "Instalando Node $target"
    nvm install "$target"
  fi
  nvm alias default "$NODE_MAJOR"
  nvm use default >/dev/null
}

# Carregadores de SDKMAN e NVM
load_sdkman() {
  export SDKMAN_DIR="$HOME/.sdkman"
  # shellcheck disable=SC1091
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
}

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
}