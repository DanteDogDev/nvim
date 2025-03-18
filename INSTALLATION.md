# Installation

## Clone the Repository

Windows

```bash
Remove-Item $env:LOCALAPPDATA\nvim -Recurse -Force
Remove-Item $env:LOCALAPPDATA\nvim-data -Recurse -Force
git clone https://github.com/DanteDogDev/nvim.git $env:LOCALAPPDATA\nvim
```

Linux

```bash
git clone https://github.com/DanteDogDev/nvim.git ~/.config/nvim
```

## Install Dependencies

- Neovim 
- Nerd Font
- lua
- lua rocks
- git
- lazygit
- ripgrep
- fd
- fzf
- rust

### C/CPP

- llvm
- cmake
- ninja
- dotnet sdk

### JSON

- nodejs

## Dependencie Installer

Windows

```bash
winget install chocolatey
winget install pwsh
choco install git
choco install neovim
choco install lua51
choco install luarocks
choco install lazygit
choco install ripgrep
choco install fd
choco install fzf
choco install rust
# C/C++
choco install llvm
choco install cmake
choco install ninja
winget install Microsoft.DotNet.SDK.9
# Json
winget install Schniz.fnm
fnm install 22 # might have to add this to enviroment variables
```

Linux
