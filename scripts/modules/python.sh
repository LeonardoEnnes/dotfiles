#!/usr/bin/env bash
python_install() {
  if ! command -v uv >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/uv" ]]; then
    log 'Instalando uv'
    curl -LsSf 'https://astral.sh/uv/install.sh' | env UV_NO_MODIFY_PATH=1 sh
  fi
}
