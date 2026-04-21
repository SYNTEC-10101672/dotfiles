## MODIFIED Requirements

### Requirement: SETUP.md 涵蓋完整新機器建置流程
`docs/SETUP.md` SHALL 涵蓋以下所有步驟，並以此順序呈現：
1. Clone repository 並執行 `make install`
2. 安裝系統套件（jq, tmux, tig, ripgrep, fzf, fd, curl, git, make, bash-completion, python3, sshpass）
3. 安裝 nvm 與 node.js
4. 安裝 bun runtime
5. 安裝 neovim（若系統版本不足）
6. 安裝 atuin
7. 安裝 opencode 並執行 `make opencode`
8. 安裝 Claude Code CLI 並安裝所有 enabled plugins
9. 設定 `~/.env`（從 `env.example` 複製並編輯）
10. Optional：安裝 .NET SDK 與 OmniSharp（C# 開發用）
11. 執行驗證（`make check` + 套件 check script）

#### Scenario: AI 可線性執行 SETUP.md
- **WHEN** AI 在全新 Linux 機器上閱讀 `docs/SETUP.md`
- **THEN** AI SHALL 能夠從第一步到最後一步依序執行，不需跳回前面步驟或參考其他文件

### Requirement: ENV_SETUP.md 移除棄用的 SYNTEC MCP 內容
`docs/ENV_SETUP.md` SHALL NOT 存在。ENV_SETUP.md 已刪除，環境變數說明由 `env.example` 的行內註解涵蓋。

#### Scenario: ENV_SETUP.md 不存在
- **WHEN** 查找 `docs/ENV_SETUP.md`
- **THEN** 該檔案 SHALL 不存在

## REMOVED Requirements

### Requirement: ENV_SETUP.md 移除棄用的 SYNTEC MCP 內容
**Reason**: ENV_SETUP.md 整份刪除。環境變數說明改由 env.example 行內註解提供，不再獨立維護文件。
**Migration**: 環境變數設定請直接參考 `env.example` 中的註解說明。
