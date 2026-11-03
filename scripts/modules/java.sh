#!/usr/bin/env bash

java_install() {
  if [[ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log 'Instalando SDKMAN'
    curl -fsSL 'https://get.sdkman.io?rcupdate=false' | bash
  fi

  load_sdkman

  # SDKMAN não é totalmente compatível com nounset.
  local had_nounset=false

  if [[ $- == *u* ]]; then
    had_nounset=true
    set +u
  fi

  local status=0

  install_java || status=$?

  if (( status == 0 )) &&
     [[ ! -d "$SDKMAN_DIR/candidates/maven/current" ]]; then
    log 'Instalando Maven'
    sdk install maven </dev/null || status=$?
  fi

  if [[ "$had_nounset" == true ]]; then
    set -u
  fi

  return "$status"
}