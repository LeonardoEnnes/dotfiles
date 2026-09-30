# direnv: antes do instant prompt (recomendação do p10k)
(( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── PATH & Env Vars ───────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── Histórico ─────────────────────────────────────────────────────
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY        # histórico compartilhado entre abas
setopt HIST_IGNORE_SPACE    # comando com espaço na frente não é salvo

# ─── Autocompletions ───────────────────────────────────────────────
fpath=(~/.zsh/plugins/zsh-completions/src $fpath)
autoload -Uz compinit && compinit

# ─── Tema e plugins ────────────────────────────────────────────────
source ~/.zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ─── Ferramentas ───────────────────────────────────────────────────
(( ${+commands[zoxide]} )) && eval "$(zoxide init zsh)"
(( ${+commands[direnv]} )) && eval "$(direnv hook zsh)"

# fzf: Ctrl+R (histórico), Ctrl+T (arquivos), Alt+C (pastas)
[[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]]   && source /usr/share/doc/fzf/examples/completion.zsh

# SDKMAN (Java)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# NVM (Node)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ─── Aliases ───────────────────────────────────────────────────────
alias mvr="./mvnw spring-boot:run"
if (( ${+commands[eza]} )); then
  alias ls="eza --icons"
  alias ll="eza -la --icons"
fi

# ─── Syntax highlighting: SEMPRE a última linha ────────────────────
source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh