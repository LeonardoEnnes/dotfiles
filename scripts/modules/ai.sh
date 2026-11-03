#!/usr/bin/env bash

ai_install() {
  log 'Configurando ferramentas de IA'

  # Configurações versionadas
  if [[ -f "$DOTFILES_DIR/config/opencode/opencode.json" ]]; then
    link \
      "$DOTFILES_DIR/config/opencode/opencode.json" \
      "$HOME/.config/opencode/opencode.json"
  fi

  if [[ -f "$DOTFILES_DIR/config/claude/settings.json" ]]; then
    link \
      "$DOTFILES_DIR/config/claude/settings.json" \
      "$HOME/.claude/settings.json"
  fi

  # Instalação opcional das CLIs.
  if [[ "${INSTALL_AI_TOOLS:-false}" != true ]]; then
    log 'Instalação das CLIs de IA desativada (INSTALL_AI_TOOLS=true para ativar)'
    return 0
  fi

  if ! has npm; then
    warn 'npm não encontrado. Ignorando instalação das CLIs de IA.'
    return 0
  fi

  if ! has opencode; then
    npm install -g opencode-ai
  fi

  if ! has claude; then
    npm install -g @anthropic-ai/claude-code
  fi

  if ! has codex; then
    npm install -g @openai/codex
  fi
}