# zsh-config Spec

## Purpose

`.zshrc` 提供完整的 zsh 互動 shell 環境，包含 PATH、locale、工具初始化及 completion 設定，取代原有 `.bashrc` 的角色。

## Requirements

### Requirement: zshrc 提供完整的互動 shell 環境

dotfiles 的 `.zshrc` SHALL 包含所有互動 shell 所需的環境設定，取代 `.bashrc` 的角色，並適配 zsh 語法。

#### Scenario: PATH 設定完整

- **WHEN** 使用者啟動 zsh 互動 shell
- **THEN** `~/bin`、`~/.local/bin`、`~/.dotnet`、`~/.omnisharp`、`~/.bun/bin` 均在 PATH 內

#### Scenario: Locale 與 TERM 環境變數設定正確

- **WHEN** 使用者啟動 zsh 互動 shell
- **THEN** `LANG`、`LC_ALL`、`LC_CTYPE` 設為 `en_US.UTF-8`，`TERM` 設為 `xterm-256color`

#### Scenario: source .aliases

- **WHEN** 使用者啟動 zsh 互動 shell
- **THEN** `~/.aliases` 被 source，所有 alias 與 function 可用

#### Scenario: 選用 .env 載入

- **WHEN** `~/.env` 存在
- **THEN** 自動 source，環境變數（API tokens 等）載入

#### Scenario: nvm 初始化

- **WHEN** `~/.nvm/nvm.sh` 存在
- **THEN** nvm 正常初始化，`nvm` 指令可用

#### Scenario: atuin 初始化（zsh 模式）

- **WHEN** 使用者啟動 zsh
- **THEN** `eval "$(atuin init zsh)"` 執行，atuin history 可用

#### Scenario: bun 初始化

- **WHEN** `~/.bun/_bun` 存在
- **THEN** bun completions 載入，`bun` 指令可用

#### Scenario: zsh completion 系統啟用

- **WHEN** 使用者啟動 zsh
- **THEN** `compinit` 初始化，`setopt MENU_COMPLETE` 與大小寫不敏感補全啟用

#### Scenario: Linux 特定環境變數（選用）

- **WHEN** 在 Linux 機器上啟動 zsh 且 fcitx 相關設定存在
- **THEN** `GTK_IM_MODULE`、`QT_IM_MODULE`、`XMODIFIERS` 正確設定
