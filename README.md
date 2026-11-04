# Dotfiles

[![CI](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml)

Configurações e scripts para preparar meu ambiente de desenvolvimento em **Ubuntu 24.04 / WSL2**, com foco em **Java/Spring Boot**, **React/TypeScript** e ferramentas de terminal.

O objetivo é tornar o setup **reproduzível**, **modular** e **versionado**: instalar ferramentas, aplicar configurações por links simbólicos e verificar se o ambiente está pronto, isolando dados sensíveis e específicos da máquina em um arquivo `.env`.

Sinta-se à vontade para adaptar ao seu fluxo.
.
## Visão geral

O repositório separa três responsabilidades principais:

- **`scripts/`**: instala, atualiza e verifica ferramentas no Ubuntu/WSL.
- **`config/`**: guarda configurações versionadas do shell, Git e ferramentas de IA.
- **`windows/` e `wsl/`**: arquivos voltados ao Windows e à integração com WSL (incluindo templates gerados dinamicamente).

O instalador principal carrega módulos independentes na sequência:

`base → shell → git → java → node → python → docker → openspec → wsl`

## Ferramentas


| Área | Ferramentas / finalidade |
| --- | --- |
| Shell | Zsh, Powerlevel10k e plugins de produtividade |
| Java | SDKMAN, Java 21 (Eclipse Temurin) e Maven |
| Node.js | NVM, Node 24 e pnpm |
| Python | uv |
| Terminal | fzf, zoxide, eza, bat, ripgrep e outros utilitários |
| Containers | Configuração do Docker conforme o ambiente; no WSL, preferência pela integração com Docker Desktop |
| IA | Módulo dedicado a ferramentas de IA |

> A lista exata de pacotes e o comportamento de cada instalação são definidos em `scripts/modules/`. Ter um arquivo em `config/` não garante, por si só, que ele esteja sendo aplicado pelo instalador.

## Estrutura

```text
dotfiles/
├── .env.example          # Template de variáveis locais (Git, WSL)
├── .github/
│   └── workflows/
│       └── ci.yml
├── config/
│   ├── git/
│   │   └── .gitconfig
│   └── zsh/
│       ├── .zshrc
│       └── .p10k.zsh
├── scripts/
│   ├── modules/
│   │   ├── base.sh
│   │   ├── docker.sh
│   │   ├── git.sh
│   │   ├── java.sh
│   │   ├── node.sh
│   │   ├── python.sh
│   │   ├── shell.sh
│   │   ├── openspec.sh
│   │   └── wsl.sh
│   ├── doctor.sh
│   ├── install.sh
│   ├── lib.sh
│   └── update.sh
├── windows/
│   ├── packages.json
│   └── setup.ps1
└── wsl/
    ├── .wslconfig
    └── wsl.conf.template
```

## Instalação no Ubuntu / WSL

### 1. Pré-requisitos

```bash
sudo apt update
sudo apt install -y git curl
```

### 2. Clonar o repositório

```bash
git clone https://github.com/LeonardoEnnes/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Configurar variáveis de ambiente (Obrigatório)

Antes de instalar, crie seu arquivo local de configuração para injetar seus dados no WSL sem expô-los no repositório:

```bash
cp .env.example .env
nano .env # Ou use o editor de sua preferência
```

Preencha as variáveis com seus dados reais

O arquivo `.env` é ignorado pelo Git.

### 4. Executar o instalador

```bash
bash ~/dotfiles/scripts/install.sh
```

O script validará a existência do `.env`, fará a leitura segura das variáveis e injetará nos módulos corretos.

Quando a função de links simbólicos encontra um arquivo existente, cria um backup antes de substituí-lo.

### 5. Abrir uma nova sessão

Se necessário, defina o Zsh como shell padrão:

```bash
chsh -s "$(command -v zsh)"
```

Reabra o terminal para carregar as configurações.

### 6. Verificar o ambiente

```bash
bash ~/dotfiles/scripts/doctor.sh
```

## Versões de Java e Node.js

Os valores padrão ficam em `scripts/lib.sh`:

```bash
JAVA_MAJOR="${JAVA_MAJOR:-21}"
JAVA_VENDOR="${JAVA_VENDOR:-tem}"
NODE_MAJOR="${NODE_MAJOR:-24}"
```

É possível sobrescrevê-los em uma execução:

```bash
JAVA_MAJOR=17 NODE_MAJOR=22 bash ~/dotfiles/scripts/install.sh
```

O Java é gerenciado pelo SDKMAN e o Node.js pelo NVM.

Consulte a documentação dessas ferramentas antes de alterar versões em projetos existentes.

## Windows e WSL

O ambiente é dividido em duas camadas:

- **Windows**: sistema host, aplicativos gráficos e Docker Desktop.
- **Ubuntu no WSL2**: shell, linguagens, gerenciadores de versões, ferramentas de terminal e projetos.

`windows/setup.ps1` e `windows/packages.json` são os pontos de entrada para a automação do Windows.

Verifique seu conteúdo antes de executá-los; o instalador Bash não substitui a configuração do host.

### Configuração da VM do WSL

As configurações do WSL são divididas em duas etapas:

1. **Interna (`/etc/wsl.conf`)**: O script `wsl.sh` lê o arquivo `wsl/wsl.conf.template`, injeta o `WSL_ENV_NAME` definido no seu `.env` e aplica automaticamente em `/etc/wsl.conf`, exigindo privilégios de `root`.

2. **Externa (`.wslconfig`)**: Arquivo de configuração do **Windows**, responsável por limites de hardware (RAM/CPU). Copie-o manualmente para o perfil do usuário do Windows:

```powershell
Copy-Item "\\wsl$\Ubuntu\home\<usuario>\dotfiles\wsl\.wslconfig" "$env:USERPROFILE\.wslconfig"
wsl --shutdown
```

### Docker

No WSL2 com Docker Desktop, prefira habilitar a integração da distribuição no Docker Desktop, evitando manter um Docker Engine separado no Ubuntu sem necessidade.

A CI executada no GitHub Actions usa Ubuntu hospedado pelo GitHub e não valida a integração real com Docker Desktop no Windows.

## CI

O workflow `.github/workflows/ci.yml` é executado em pushes, pull requests e manualmente.

Ele possui dois jobs:

1. **Lint**: ShellCheck, validação de sintaxe Bash/Zsh e leitura do arquivo de configuração Git.
2. **Instalação repetível**: executa `install.sh` duas vezes em Ubuntu 24.04 e verifica Java, Maven, Node, pnpm, yq, uv, links simbólicos e `doctor.sh`.

## Recuperação e diagnóstico

Se o Zsh apresentar problemas:

```bash
zsh -f
```

Esse comando abre o Zsh sem carregar os arquivos usuais de inicialização, permitindo investigar a configuração.

Para verificar os scripts:

```bash
shellcheck -x scripts/*.sh scripts/modules/*.sh
bash -n scripts/*.sh scripts/modules/*.sh
```

## Licença e uso

Configurações pessoais disponibilizadas como referência. Revise os scripts antes de executá-los e adapte versões, aplicativos e preferências ao seu ambiente.
