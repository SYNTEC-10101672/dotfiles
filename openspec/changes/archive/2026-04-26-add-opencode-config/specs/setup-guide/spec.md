## MODIFIED Requirements

### Requirement: SETUP.md 涵蓋完整新機器建置流程
`docs/SETUP.md` SHALL 涵蓋以下所有步驟，並以此順序呈現：
1. Clone repository 並執行 `make install`
2. 安裝系統套件（jq, tmux, tig, ripgrep, fzf, fd, curl, git, make, bash-completion, python3, sshpass）
3. 安裝 nvm 與 node.js
4. 安裝 bun runtime
5. 安裝 neovim（若系統版本不足）
6. 安裝 atuin
7. 安裝 opencode、執行 `make opencode`，並說明 plugin（`@slkiser/opencode-quota`）在首次啟動時自動下載
8. 安裝 openspec
9. 安裝 Claude Code CLI 並安裝所有 enabled plugins
10. 設定 `~/.env`（從 `env.example` 複製並編輯）
11. Optional：安裝 .NET SDK 與 OmniSharp（C# 開發用）
12. 執行驗證（`make check` + 套件 check script）

#### Scenario: AI 可線性執行 SETUP.md
- **WHEN** AI 在全新 Linux 機器上閱讀 `docs/SETUP.md`
- **THEN** AI SHALL 能夠從第一步到最後一步依序執行，不需跳回前面步驟或參考其他文件

### Requirement: opencode 步驟說明 plugin 自動安裝行為
SETUP.md 的 opencode 安裝步驟 SHALL 明確說明：`make opencode` 完成後，opencode 宣告的 plugin（`@slkiser/opencode-quota`）將在**首次啟動 opencode 時自動下載**，無需手動執行 `npm install`。

#### Scenario: AI 執行 opencode 安裝步驟
- **WHEN** AI 閱讀 SETUP.md 的 opencode 步驟並執行
- **THEN** AI SHALL 知道 `make opencode` 後不需要額外的 plugin 安裝指令，啟動 opencode 即可
