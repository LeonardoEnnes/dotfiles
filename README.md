# Dotfiles

[![CI](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml)

Meu ambiente de desenvolvimento no **WSL (Ubuntu)**, focado em **Java/Spring** e **React**.
Uso principalmente para deixar um PC novo pronto com um único comando. Fique à vontade para usar e adaptar.

## O que é instalado

| Categoria | Ferramentas |
|---|---|
| Shell | Zsh, Powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions |
| Java | SDKMAN, Java 21 (Eclipse Temurin), Maven |
| Node | NVM, Node 24, pnpm |
| Python | uv |
| Containers | Docker Engine (repositório oficial) com Compose v2 e Buildx |
| Banco de dados | postgresql-client |
| Terminal | fzf, zoxide, eza, bat, ripgrep, direnv, git-delta, tldr |
| Utilitários | jq, yq, htop, lsof, net-tools, build-essential |

## Estrutura

```
dotfiles/
├── .github/workflows/ci.yml   # Lint + teste de instalação a cada push
├── wsl/
│   ├── .wslconfig             # Recursos da VM do WSL (copiar para C:\Users\<Você>\)
│   └── wsl.conf               # systemd, interop e automount (vai para /etc/wsl.conf)
└── scripts/
    ├── install.sh             # Setup completo de uma máquina nova
    ├── lib.sh                 # Funções usadas pelo install.sh e versões fixadas
    ├── .zshrc
    ├── .p10k.zsh
    ├── .gitconfig
    └── .gitignore_global
```

## Setup de uma máquina nova

**1. Pré-requisitos**

```bash
sudo apt update && sudo apt install -y git zsh
```

**2. Clonar o repositório**

```bash
git clone https://github.com/LeonardoEnnes/dotfiles.git ~/dotfiles
```

**3. Rodar a instalação**

```bash
bash ~/dotfiles/scripts/install.sh
```

O script cria symlinks de `.zshrc`, `.p10k.zsh`, `.gitconfig` e `.gitignore_global` na sua home. Se já existir um desses arquivos, ele faz um backup antes (`arquivo.bak.<data>`).

Ele pode ser executado mais de uma vez sem problemas: cada etapa verifica se já foi feita.

**4. Definir o zsh como shell padrão**

```bash
chsh -s "$(command -v zsh)"
```

**5. Configurar o WSL (no PowerShell)**

```powershell
copy \\wsl$\Ubuntu\home\<seu-usuario>\dotfiles\wsl\.wslconfig $env:USERPROFILE
wsl --shutdown
```

Ao abrir o terminal de novo, tudo já estará aplicado.

## Versões

Os majors do Java e do Node ficam fixos no topo de `scripts/lib.sh`:

```bash
JAVA_MAJOR="${JAVA_MAJOR:-21}"
JAVA_VENDOR="${JAVA_VENDOR:-tem}"   # tem = Eclipse Temurin
NODE_MAJOR="${NODE_MAJOR:-24}"
```

O install sempre pega o patch mais recente dessas linhas (por exemplo, o último `21.0.x`). Antes de configurar um PC novo, confira se esses números ainda são os que você usa.

Também dá para trocar só numa execução:

```bash
JAVA_MAJOR=17 NODE_MAJOR=22 bash ~/dotfiles/scripts/install.sh
```

Depois de instalado, trocar de versão é com as próprias ferramentas:

```bash
sdk install java 25-tem && sdk default java 25-tem
nvm install 22 && nvm alias default 22
```

Para um projeto que precisa de outra versão do Java, crie um `.sdkmanrc` na raiz dele com `sdk env init`.

## Mantendo atualizado

Não há script de update. Use os comandos das próprias ferramentas:

```bash
sudo apt update && sudo apt upgrade -y               # sistema, Docker, delta, eza...
sdk upgrade maven                                    # Maven
sdk install java <21.0.x-tem>                        # novo patch do Java (veja com: sdk list java)
nvm install 24 --reinstall-packages-from=current     # novo patch do Node
uv self update                                       # uv
git -C ~/.zsh/plugins/powerlevel10k pull             # repita para cada plugin em ~/.zsh/plugins
```

## Atalhos úteis

| Atalho | Faz |
|---|---|
| `Ctrl+R` | Busca fuzzy no histórico |
| `Ctrl+T` | Busca fuzzy de arquivos |
| `Alt+C` | Busca fuzzy de pastas e entra nela |
| `z <pasta>` | Pula para uma pasta já visitada (zoxide) |
| `mvr` | `./mvnw spring-boot:run` |
| `ls` / `ll` | Listagem com eza (com ícones) |
| `git lg` | Log em grafo |
| `git co` / `git br` | `checkout` / `branch` |

> Os ícones do `eza` precisam de uma [Nerd Font](https://www.nerdfonts.com/) configurada no Windows Terminal (ex: MesloLGS NF). Sem ela, aparecem quadradinhos; nesse caso, remova o `--icons` dos aliases no `.zshrc`.

## Detalhes do WSL

- **`wsl.conf`** habilita o systemd (necessário para o Docker) e desativa o `appendWindowsPath`, o que deixa o zsh bem mais rápido. Como o PATH do Windows deixa de ser herdado, o install cria um atalho para o VS Code em `~/.local/bin/code`, então `code .` continua funcionando.
- **`.wslconfig`** limita a VM a 8 GB de RAM, 4 processadores e 2 GB de swap. Ajuste conforme a sua máquina.

## Chave GPG em uma máquina nova

Os commits são assinados com GPG (`commit.gpgsign = true`). A chave não vem junto com o repositório.

Na máquina antiga, exporte para **fora** da pasta do repositório:

```bash
gpg --export-secret-keys --armor <seu-email> > ~/chave.asc
```

Na máquina nova:

```bash
gpg --import ~/chave.asc
shred -u ~/chave.asc   # apaga o arquivo com segurança depois de importar
```

Depois, pegue o ID da chave e coloque em `signingkey` no `.gitconfig`:

```bash
gpg --list-secret-keys --keyid-format=long
# sec   ed25519/ABCD1234EF567890 ...   ← o ID é a parte depois da barra
```

## CI

A cada push, o GitHub Actions:

1. Roda o `shellcheck` nos scripts e valida a sintaxe do `.zshrc`, do `.p10k.zsh` e do `.gitconfig`.
2. Executa o `install.sh` **duas vezes** num Ubuntu 24.04 limpo, garantindo que ele funciona do zero e que rodar de novo não quebra nada.
3. Confere se Java, Maven, Node, pnpm, Docker Compose, yq e uv ficaram disponíveis e se os symlinks foram criados.

## Recuperar o shell

Se o zsh quebrar depois de alguma alteração:

```bash
zsh -f            # abre o zsh sem carregar nenhuma config
source ~/.zshrc   # recarrega e mostra onde está o erro
```