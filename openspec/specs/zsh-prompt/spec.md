# zsh-prompt Spec

## Purpose

`.p10k.zsh` 設定 Powerlevel10k prompt，採用 lean style、Gruvbox dark 配色、兩行 layout，提供 git 狀態、執行時間、時間顯示等資訊。

## Requirements

### Requirement: Powerlevel10k lean prompt，Gruvbox 配色

`.p10k.zsh` SHALL 設定 Powerlevel10k 為 lean style，使用 Gruvbox dark 配色，兩行 layout。

#### Scenario: Prompt 顯示當前路徑

- **WHEN** 使用者在任意目錄下
- **THEN** 左側第一行顯示縮短的當前路徑，顏色為 Gruvbox blue（`#458588`）

#### Scenario: Git 狀態顯示（clean）

- **WHEN** 目前目錄在 git repo 內，且工作樹乾淨
- **THEN** 顯示 branch 名稱，顏色為 Gruvbox green（`#98971a`）

#### Scenario: Git 狀態顯示（dirty）

- **WHEN** 有未 commit 的修改
- **THEN** branch 名稱後顯示 `*`，顏色切換為 Gruvbox yellow（`#d79921`）

#### Scenario: Git 狀態顯示（untracked）

- **WHEN** 有 untracked 檔案
- **THEN** 顯示 `?` 標記，顏色為 Gruvbox orange（`#d65d0e`）

#### Scenario: 執行時間顯示

- **WHEN** 指令執行時間超過 3 秒
- **THEN** 右側顯示執行時間（如 `3s`、`1m 20s`），顏色為 Gruvbox orange

#### Scenario: 時間顯示

- **WHEN** 使用者在 prompt 下
- **THEN** 右側顯示當前時間（`HH:MM`），顏色為 Gruvbox grey（`#928374`）

#### Scenario: Prompt 符號反映上一個指令結果

- **WHEN** 上一個指令成功（exit code 0）
- **THEN** 第二行顯示 `❯`，顏色為 Gruvbox green

#### Scenario: Prompt 符號反映失敗

- **WHEN** 上一個指令失敗（exit code != 0）
- **THEN** `❯` 顏色切換為 Gruvbox red（`#cc241d`）

#### Scenario: SSH 環境標記

- **WHEN** 使用者透過 SSH 連線
- **THEN** 左側顯示 hostname，與一般環境有視覺區分

#### Scenario: p10k instant prompt 啟用

- **WHEN** `.zshrc` 頂部載入 instant prompt cache
- **THEN** zsh 啟動時 prompt 立即顯示，不等待後續初始化完成
