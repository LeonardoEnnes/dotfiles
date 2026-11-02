#!/usr/bin/env bash
wsl_install() {
  if ! is_wsl; then
    log 'Fora do WSL: pulando configuração WSL'
    return 0
  fi

  log 'WSL detectado: preservando /etc/wsl.conf'
  if [[ ! -f /etc/wsl.conf ]]; then
    warn 'Arquivo /etc/wsl.conf ausente. Revise wsl/wsl.conf antes de aplicá-lo manualmente.'
  fi

  # Com appendWindowsPath=false, localizar o VS Code nas instalações comuns.
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
  warn 'Confira wsl/.wslconfig e reinicie o WSL pelo PowerShell quando necessário.'
}
