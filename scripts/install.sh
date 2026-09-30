#!/usr/bin/env bash
# Setup completo de um ambiente WSL Ubuntu novo.
# Pode ser executado mais de uma vez: cada etapa verifica se já foi feita.
set -eo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=scripts/lib.sh
source "$DOTFILES_DIR/scripts/lib.sh"

mkdir -p "$HOME/.local/bin"

# ─── Pacotes base ──────────────────────────────────────────
log "Instalando pacotes do sistema"
sudo apt-get update -y
sudo apt-get install -y \
  build-essential ca-certificates curl wget gnupg git zsh \
  unzip zip htop net-tools jq ripgrep bat fzf \
  postgresql-client \
  zoxide eza git-delta direnv tldr lsof

# No Ubuntu o bat vem como "batcat"
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

# ─── Plugins do zsh ────────────────────────────────────────
log "Instalando plugins do zsh"
mkdir -p "$HOME/.zsh/plugins"
clone_plugin() {
  [ -d "$HOME/.zsh/plugins/$2" ] || git clone --depth=1 "https://github.com/$1.git" "$HOME/.zsh/plugins/$2"
}
clone_plugin romkatv/powerlevel10k             powerlevel10k
clone_plugin zsh-users/zsh-autosuggestions     zsh-autosuggestions
clone_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting
clone_plugin zsh-users/zsh-completions         zsh-completions

# ─── Ferramentas via release ───────────────────────────────
command -v yq      >/dev/null 2>&1 || install_yq

# ─── Docker Engine (repositório oficial, com compose v2 e buildx) ──
if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  log "Instalando Docker Engine"
  # Remove pacotes antigos do Ubuntu que conflitam com o docker-ce
  for pkg in docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc; do
    sudo apt-get remove -y "$pkg" >/dev/null 2>&1 || true
  done
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi
sudo usermod -aG docker "$USER"
if command -v systemctl >/dev/null 2>&1 && [ -d /run/systemd/system ]; then
  sudo systemctl enable --now docker || true
fi

# ─── SDKMAN + Java + Maven ─────────────────────────────────
if [ ! -d "$HOME/.sdkman" ]; then
  log "Instalando SDKMAN"
  # rcupdate=false: não deixa o instalador editar o .zshrc (que é versionado)
  curl -fsSL "https://get.sdkman.io?rcupdate=false" | bash
fi
load_sdkman

install_java
[ -d "$SDKMAN_DIR/candidates/maven/current" ] || sdk install maven </dev/null

# ─── NVM + Node + pnpm ─────────────────────────────────
if [ ! -d "$HOME/.nvm" ]; then
  log "Instalando NVM"
  # PROFILE=/dev/null: mesma ideia do rcupdate=false acima
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | PROFILE=/dev/null bash
fi
load_nvm
install_node
command -v pnpm >/dev/null 2>&1 || npm install -g pnpm

# ─── uv (Python) ───────────────────────────────────────────
if ! command -v uv >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/uv" ]; then
  log "Instalando uv"
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi

# ─── Symlinks dos dotfiles ─────────────────────────────────
log "Criando symlinks"
link "$DOTFILES_DIR/scripts/.zshrc"            "$HOME/.zshrc"
link "$DOTFILES_DIR/scripts/.p10k.zsh"         "$HOME/.p10k.zsh"
link "$DOTFILES_DIR/scripts/.gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES_DIR/scripts/.gitignore_global" "$HOME/.gitignore_global"

# ─── Configuração específica do WSL ────────────────────────
if is_wsl; then
  log "WSL detectado"
  # Cópia em vez de symlink: o /etc/wsl.conf é lido no boot da distro
  sudo install -m 644 "$DOTFILES_DIR/wsl/wsl.conf" /etc/wsl.conf

  # Com appendWindowsPath=false o `code` some do PATH; cria um atalho fixo
  CMD_EXE=/mnt/c/Windows/System32/cmd.exe
  if [ -x "$CMD_EXE" ]; then
    WIN_LOCALAPPDATA="$(cd /mnt/c && "$CMD_EXE" /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')"
    VSCODE_BIN="$(wslpath "$WIN_LOCALAPPDATA")/Programs/Microsoft VS Code/bin/code"
    [ -x "$VSCODE_BIN" ] && ln -sf "$VSCODE_BIN" "$HOME/.local/bin/code"
  fi

  warn "Copie wsl/.wslconfig para C:\\Users\\<Você>\\.wslconfig e rode 'wsl --shutdown' no PowerShell"
else
  log "Fora do WSL, pulando wsl.conf"
fi

if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  warn "Seu shell padrão não é zsh. Rode: chsh -s \"\$(command -v zsh)\""
fi

log "Pronto! Reinicie o terminal (ou o WSL) para aplicar tudo."