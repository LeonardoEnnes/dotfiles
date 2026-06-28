# Dotfiles

This is my personal WSL Ubuntu development environment for software development.
I added some things that i thought were useful for me, you can improve it as you see fit.

> [!IMPORTANT]  
> The main focus of this setup is Java

## What's included

- **Zsh** with Powerlevel10k, autosuggestions and syntax highlighting
- **Java** via SDKMAN (Java 21)
- **Node.js** via NVM + pnpm
- **Docker**
- **PostgreSQL** client
- **Maven**
- Productivity tools: ripgrep, bat, fzf, htop, jq, yq

## Structure
```
dotfiles/
├── wsl/
│   ├── .wslconfig       # Windows WSL resource limits (copy to C:\Users\You\)
│   └── wsl.conf         # systemd + WSL settings (/etc/wsl.conf)
└── scripts/
    ├── install.sh       # Run this on a fresh machine
    ├── update.sh        # Run this to update everything
    ├── .zshrc           # Zsh config
    ├── .p10k.zsh        # Powerlevel10k theme config
    └── .gitconfig       # Git global config with aliases and GPG signing
```

## Fresh machine setup

1. Install git and zsh first
```bash
sudo apt install git zsh
```

2. Clone the repo
```bash
git clone https://github.com/youruser/dotfiles.git ~/dotfiles
```

3. Run the install script
```bash
cd ~/dotfiles && bash scripts/install.sh
```
> This will symlink `.zshrc`, `.p10k.zsh` and `.gitconfig` to your home directory automatically.

4. Set zsh as default shell
```bash
chsh -s $(which zsh)
```

5. Copy .wslconfig to Windows (do this from PowerShell)
```powershell
copy \\wsl$\Ubuntu\home\your\dotfiles\wsl\.wslconfig $env:USERPROFILE
```

6. Import your GPG key (if you have one from another machine)
```bash
gpg --import chave.gpg
```

7. Restart WSL
```bash
wsl --shutdown
```

## Keeping everything updated
```bash
bash ~/dotfiles/scripts/update.sh
```

## GPG key - new machine

Your GPG key is stored locally and won't transfer automatically. On your old machine, export it:
```bash
gpg --export-secret-keys email > chave.gpg
```
Then copy `chave.gpg` to the new machine and import it (step 6 above).

## Recover shell

If zsh breaks:

```bash
zsh -f
source ~/.zshrc