# Dotfiles

[![CI](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/LeonardoEnnes/dotfiles/actions/workflows/ci.yml)

Configurações e scripts para preparar meu ambiente de desenvolvimento em **Ubuntu 24.04 / WSL2**, com foco em **Java/Spring Boot**, **React/TypeScript** e ferramentas de terminal.

O objetivo é tornar o setup **reproduzível**, **modular** e **versionado**: instalar ferramentas, aplicar configurações por links simbólicos e verificar se o ambiente está pronto. Sinta-se à vontade para adaptar ao seu fluxo.

## Visão geral

O repositório separa três responsabilidades:

- **`scripts/`**: instala, atualiza e verifica ferramentas no Ubuntu/WSL.
- **`config/`**: guarda configurações versionadas do shell, Git e ferramentas de IA.
- **`windows/` e `wsl/`**: arquivos voltados ao Windows e à integração com WSL.

O instalador principal carrega módulos independentes na sequência `base → shell → git → java → node → python → docker → ai → wsl`.

## Ferramentas

| Área | Ferramentas / finalidade |
| --- | --- |
| Shell | Zsh, Powerlevel10k e plugins de produtividade |
| Java | SDKMAN, Java 21 (Eclipse Temurin) e Maven |
| Node.js | NVM, Node 24 e pnpm |
| Python | uv |
| Terminal | fzf, zoxide, eza, bat, ripgrep e outros utilitários |
| Git | Configuração versionada e links simbólicos |
| Containers | Configuração do Docker conforme o ambiente; no WSL, preferência pela integração com Docker Desktop |
| IA | Módulo dedicado a ferramentas de IA; configurações em `config/opencode/` e `config/claude/` |

> A lista exata de pacotes e o comportamento de cada instalação são definidos em `scripts/modules/`. Ter um arquivo em `config/` não garante, por si só, que ele esteja sendo aplicado pelo instalador.

## Estrutura

```text
dotfiles/
├── .github/
│   └── workflows/
│       └── ci.yml
├── config/
│   ├── claude/
│   │   └── settings.json
│   ├── git/
│   │   └── .gitconfig
│   ├── opencode/
│   │   └── opencode.json
│   └── zsh/
│       ├── .zshrc
│       └── .p10k.zsh
├── scripts/
│   ├── modules/
│   │   ├── ai.sh
│   │   ├── base.sh
│   │   ├── docker.sh
│   │   ├── git.sh
│   │   ├── java.sh
│   │   ├── node.sh
│   │   ├── python.sh
│   │   ├── shell.sh
│   │   └── wsl.sh
│   ├── doctor.sh
│   ├── install.sh
│   ├── lib.sh
│   └── update.sh
├── windows/
│   ├── packages.json
│   └── setup.ps1
└── wsl/
    └── .wslconfig
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
```

### 3. Executar o instalador

```bash
bash ~/dotfiles/scripts/install.sh
```

O script utiliza módulos separados e foi projetado para permitir novas execuções. Quando a função de links simbólicos encontra um arquivo existente, cria um backup antes de substituí-lo; quando o link já está correto, não faz alterações.

### 4. Abrir uma nova sessão

Se necessário, defina o Zsh como shell padrão:

```bash
chsh -s "$(command -v zsh)"
```

Reabra o terminal para carregar as configurações.

### 5. Verificar o ambiente

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

O Java é gerenciado pelo SDKMAN e o Node.js pelo NVM. Consulte a documentação dessas ferramentas antes de alterar versões em projetos existentes.

## Atualização

O repositório inclui um script dedicado:

```bash
bash ~/dotfiles/scripts/update.sh
```

O que é atualizado depende da implementação atual de `update.sh`. Para verificar o estado do ambiente após uma atualização:

```bash
bash ~/dotfiles/scripts/doctor.sh
```

## Configurações e dados privados

As configurações versionadas ficam em `config/`. Arquivos pessoais, credenciais, tokens, chaves privadas e sessões de autenticação **não devem ser enviados ao GitHub**.

Para o Git, a configuração compartilhada pode incluir um arquivo local não versionado, como `~/.gitconfig.local`, para nome, email e chave de assinatura SSH. A chave privada SSH deve permanecer em `~/.ssh/` e nunca ser adicionada ao repositório.

Os diretórios `config/opencode/` e `config/claude/` são destinados a configurações reutilizáveis das ferramentas de IA. Confirme em `scripts/modules/ai.sh` quais arquivos são efetivamente instalados ou vinculados.

## Windows e WSL

O ambiente é dividido em duas camadas:

- **Windows**: sistema host, aplicativos gráficos e Docker Desktop.
- **Ubuntu no WSL2**: shell, linguagens, gerenciadores de versões, ferramentas de terminal e projetos.

`windows/setup.ps1` e `windows/packages.json` são os pontos de entrada para a automação do Windows. Verifique seu conteúdo antes de executá-los; o instalador Bash não substitui a configuração do host.

### Configuração da VM do WSL

O arquivo `wsl/.wslconfig` é uma configuração do **Windows**, não do diretório `/etc/` do Ubuntu. No PowerShell, copie-o para o perfil do usuário:

```powershell
Copy-Item "\\wsl$\Ubuntu\home\<usuario>\dotfiles\wsl\.wslconfig" "$env:USERPROFILE\.wslconfig"
wsl --shutdown
```

Substitua `Ubuntu` pelo nome da distribuição e `<usuario>` pelo usuário Linux. Revise os limites de memória, CPU e swap do arquivo conforme o hardware.

### Docker

No WSL2 com Docker Desktop, prefira habilitar a integração da distribuição no Docker Desktop, evitando manter um Docker Engine separado no Ubuntu sem necessidade. A CI executada no GitHub Actions usa Ubuntu hospedado pelo GitHub e não valida a integração real com Docker Desktop no Windows.

## CI

O workflow `.github/workflows/ci.yml` é executado em pushes, pull requests e manualmente. Ele possui dois jobs:

1. **Lint**: ShellCheck, validação de sintaxe Bash/Zsh e leitura do arquivo de configuração Git.
2. **Instalação repetível**: executa `install.sh` duas vezes em Ubuntu 24.04 e verifica Java, Maven, Node, pnpm, yq, uv, links simbólicos e `doctor.sh`.

Isso ajuda a detectar erros e regressões, mas não substitui testes específicos do Windows/WSL.

## Recuperação e diagnóstico

Se o Zsh apresentar problemas:

```bash
zsh -f
```

Esse comando abre o Zsh sem carregar os arquivos usuais de inicialização, permitindo investigar a configuração. Para verificar os scripts:

```bash
shellcheck -x scripts/*.sh scripts/modules/*.sh
bash -n scripts/*.sh scripts/modules/*.sh
```

## Licença e uso

Configurações pessoais disponibilizadas como referência. Revise os scripts antes de executá-los e adapte versões, aplicativos e preferências ao seu ambiente.
