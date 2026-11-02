#!/usr/bin/env bash
java_install() {
  if [[ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    log 'Instalando SDKMAN'
    curl -fsSL 'https://get.sdkman.io?rcupdate=false' | bash
  fi
  load_sdkman
  install_java
  if [[ ! -d "$SDKMAN_DIR/candidates/maven/current" ]]; then
    sdk install maven </dev/null
  fi
}
