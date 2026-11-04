#!/usr/bin/env bash

wsl_install() {
  if ! is_wsl; then
    log 'Fora do WSL: pulando configuração WSL'
    return 0
  fi

  log 'WSL detectado: gerando /etc/wsl.conf a partir das configurações do .env...'

  local template_file="$DOTFILES_DIR/wsl/wsl.conf.template"
  
  if [[ ! -f "$template_file" ]]; then
    fail "Template do wsl.conf não encontrado em: $template_file"
    return 1
  }

  # Valores padrão caso o usuário esqueça de preencher no .env
  local wsl_host="${WSL_ENV_NAME:-ubuntu-dev}"
  local wsl_user="${WSL_DEFAULT_USER:-$USER}"

  local temp_conf
  temp_conf="$(mktemp)"

  # Lê o template e substitui as variáveis com segurança
  sed -e "s/\${WSL_DEFAULT_USER}/$wsl_user/g" \
      -e "s/\${WSL_ENV_NAME}/$wsl_host/g" \
      "$template_file" > "$temp_conf"

  # Move o arquivo gerado para /etc/wsl.conf com permissões corretas
  sudo mv "$temp_conf" /etc/wsl.conf
  sudo chown root:root /etc/wsl.conf
  sudo chmod 644 /etc/wsl.conf

  log "Arquivo /etc/wsl.conf aplicado com sucesso (Usuário: $wsl_user | Hostname: $wsl_host)"

  # Configuração do atalho do VS Code (mantendo sua lógica atual)
  local candidate
  for candidate in /mnt/c/Users/*/AppData/Local/Programs/"Microsoft VS Code"/bin/code \
    "/mnt/c/Program Files/Microsoft VS Code/bin/code"; do
    if [[ -f "$candidate" ]]; then
      mkdir -p "$HOME/.local/bin"
      ln -sfn "$candidate" "$HOME/.local/bin/code"
      log 'Atalho do VS Code configurado'
      break
    fi
  done

  warn 'Lembre-se de reiniciar o WSL pelo PowerShell (wsl --shutdown) para aplicar as mudanças de rede/sistema.'
}