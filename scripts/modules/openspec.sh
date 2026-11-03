#!/usr/bin/env bash
# Instalação do OpenSpec via npm.

openspec_install() {
  log 'Configurando OpenSpec'

  if ! has npm; then
    fail 'npm não encontrado; instale Node.js primeiro'
    return 1
  fi

  if has openspec; then
    log "OpenSpec já instalado: $(openspec --version)"
    return 0
  fi

  log 'Instalando OpenSpec'
  npm install -g @fission-ai/openspec@latest

  if ! has openspec; then
    fail 'OpenSpec não encontrado no PATH após instalação'
    return 1
  fi

  log "OpenSpec instalado: $(openspec --version)"
}