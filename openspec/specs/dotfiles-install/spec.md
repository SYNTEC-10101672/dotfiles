# dotfiles-install Spec

## Purpose

Makefile 提供統一的安裝、檢查、移除 dotfiles 的介面，包含 zsh 設定與相關 plugins 的 symlink 管理。

## Requirements

### Requirement: Makefile zshrc target 安裝 zsh 設定

Makefile SHALL 提供 `zshrc` target，建立 symlink 並 clone 所需 plugins。

#### Scenario: symlink 建立正確

- **WHEN** 執行 `make zshrc`
- **THEN** `~/.zshrc` symlink 指向 `$(ROOT_DIR)/.zshrc`，`~/.p10k.zsh` symlink 指向 `$(ROOT_DIR)/.p10k.zsh`，`~/.aliases` symlink 指向 `$(ROOT_DIR)/.aliases`

#### Scenario: plugins clone（首次）

- **WHEN** 執行 `make zshrc` 且 `~/powerlevel10k` 不存在
- **THEN** git clone p10k 至 `~/powerlevel10k`

#### Scenario: plugins clone（已存在）

- **WHEN** 執行 `make zshrc` 且 `~/powerlevel10k` 已存在
- **THEN** 跳過 clone，不報錯

### Requirement: make install 包含 zshrc，移除 bashrc

`install` target SHALL 呼叫 `zshrc` 而非 `bashrc`。

#### Scenario: make install 安裝 zsh 設定

- **WHEN** 執行 `make install`
- **THEN** zsh 設定檔 symlink 建立，plugins 安裝

#### Scenario: make install 不再安裝 bash 設定

- **WHEN** 執行 `make install`
- **THEN** 不建立 `.bashrc`、`.bash_profile`、`.bash_prompt` 的 symlink

### Requirement: make check 驗證 zsh 安裝狀態

`check` target SHALL 驗證 `.zshrc`、`.p10k.zsh` 的 symlink 狀態。

#### Scenario: check 顯示 zsh 設定狀態

- **WHEN** 執行 `make check`
- **THEN** 顯示 `.zshrc` 與 `.p10k.zsh` 的 symlink 狀態（✓ 正確 / ✗ 缺少 / ⚠ 非預期目標）

### Requirement: make uninstall 移除 zsh symlink

`uninstall` target SHALL 移除 `.zshrc`、`.p10k.zsh` 的 symlink。

#### Scenario: uninstall 清除 zsh symlink

- **WHEN** 執行 `make uninstall`
- **THEN** `~/.zshrc`、`~/.p10k.zsh` symlink 被移除（若存在）
