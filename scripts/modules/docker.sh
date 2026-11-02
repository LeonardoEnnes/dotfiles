#!/usr/bin/env bash
docker_install() {
  if is_wsl; then
    log 'WSL detectado: Docker Desktop deve fornecer o Engine e o CLI'
    if ! command -v docker >/dev/null 2>&1; then
      warn 'Docker CLI não encontrado. Instale Docker Desktop no Windows e habilite Settings > Resources > WSL Integration.'
    elif ! docker info >/dev/null 2>&1; then
      warn 'Docker CLI disponível, mas o Engine não responde. Abra o Docker Desktop e confira a integração WSL.'
    elif ! docker compose version >/dev/null 2>&1; then
      warn 'Docker Compose v2 não está disponível na integração atual.'
    else
      log 'Docker Desktop acessível pelo WSL'
    fi
    return 0
  fi

  warn 'Linux nativo: instalação do Docker Engine não automatizada neste perfil.'
  warn 'Configure um módulo separado para Docker Engine caso precise.'
}
