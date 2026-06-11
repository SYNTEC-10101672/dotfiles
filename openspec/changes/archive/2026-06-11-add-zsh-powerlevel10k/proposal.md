## Why

目前 dotfiles 只管理 bash 環境，但三台工作機器（macOS、Arch Linux、公司 Ubuntu Docker container）實際上全部都可以換成 zsh。與其維護兩套 shell 設定，不如統一以 zsh 為標準，並加入 Powerlevel10k prompt 與常用 plugin 提升開發體驗。

## What Changes

- **新增** `.zshrc`：取代 `.bashrc` 成為主要 shell 設定，適配 zsh 語法
- **新增** `.p10k.zsh`：Powerlevel10k lean style 設定，使用 Gruvbox 配色
- **新增** `zsh-autosuggestions`、`zsh-syntax-highlighting` plugin 安裝與載入
- **新增** Makefile `zshrc` target：安裝 zsh 設定檔 symlink + clone plugins
- **修改** Makefile `install` target：加入 `zshrc`，移除 `bashrc`
- **保留** `.aliases`：兩個 shell 共用，`.zshrc` 直接 source
- **保留但不再維護** `.bashrc`、`.bash_profile`、`.bash_prompt`：從 `install` 移除，待 zsh 穩定後刪除
- **更新** `docs/SETUP.md`：移除 bash-preexec 安裝步驟、更新所有 `source ~/.bashrc` 為 `.zshrc`、新增 zsh 安裝步驟與 Nerd Font 說明

## Capabilities

### New Capabilities

- `zsh-config`: zsh 互動 shell 設定（PATH、env vars、tool init、plugin 載入）
- `zsh-prompt`: Powerlevel10k lean prompt，Gruvbox 配色，兩行 layout
- `zsh-plugins`: zsh-autosuggestions 與 zsh-syntax-highlighting 安裝與管理

### Modified Capabilities

- `dotfiles-install`: Makefile install target 加入 zshrc，移除 bashrc

## Impact

- 三台機器需手動安裝 zsh 並 `chsh`（macOS 已是 zsh，Arch 與 Ubuntu 需額外安裝）
- `.aliases` 維持不變，兩個 shell 均可 source
- Makefile scripts 使用 `#!/bin/bash` shebang，不受 login shell 影響
- Plugin 以 git clone 方式安裝至 `~/powerlevel10k`、`~/.zsh/`，不引入 plugin manager
