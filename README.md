# Dotfiles

This is my personal WSL Ubuntu development environment for software development.
I added some thing that i thought were usefull for me, you can improve it as you see fit

> [!IMPORTANT]  
> The main focus of this setup is Java


## What's included

- **Zsh** with Powerlevel10k, autosuggestions and syntax highlighting
- **Java** via SDKMAN (Java 21)
- **Node.js** via NVM + pnpm
- **Docker**
- **PostgreSQL** client
- **Maven**
- Productivity tools: ripgrep, bat, fzf, htop, jq

## Structure
```
dotfiles/
├── wsl/
│   ├── .wslconfig       # Windows WSL resource limits (copy to C:\Users\You\)
│   └── wsl.conf         # systemd + WSL settings (/etc/wsl.conf)
└── scripts/
    ├── install.sh       # Run this on a fresh machine
    ├── .zshrc           # Zsh config
    └── .p10k.zsh        # Powerlevel10k theme config
```

## Fresh machine setup

1. Clone the repo
```
   git clone https://github.com/youruser/dotfiles.git ~/dotfiles
```

2. Copy .wslconfig to Windows (do this from PowerShell)
```
   copy \\wsl$\Ubuntu\home\youruser\dotfiles\wsl\.wslconfig $env:USERPROFILE
```

3. Run the install script
```
   cd ~/dotfiles && bash scripts/install.sh
```

4. Restart WSL
```
   wsl --shutdown
```