# Delta Spec: setup-guide

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
8. 設定 `~/.env`（從 `env.example` 複製並編輯）
9. Optional：安裝 .NET SDK 與 OmniSharp（C# 開發用）
10. 執行驗證（`make check` + 套件 check script）

#### Scenario: AI 可線性執行 SETUP.md
- **WHEN** AI 在全新 Linux 機器上閱讀 `docs/SETUP.md`
- **THEN** AI SHALL 能夠從第一步到最後一步依序執行，不需跳回前面步驟或參考其他文件

#### Scenario: 不包含 Claude Code 安裝步驟
- **WHEN** 檢視 `docs/SETUP.md` 全文
- **THEN** 不存在「安裝 Claude Code CLI」或 `claude plugin` 相關步驟

## ADDED Requirements

### Requirement: repo root `AGENTS.md` 包含 setup 入口
repo root `AGENTS.md` SHALL 包含一個段落，明確說明新機器建置時應參考 `docs/SETUP.md`。

#### Scenario: AI 開始新機器建置
- **WHEN** AI 讀取 root `AGENTS.md` 並需要設定新機器
- **THEN** SHALL 能夠找到 `docs/SETUP.md` 的參考連結

## REMOVED Requirements

### Requirement: `.claude/CLAUDE.md` 包含 setup 入口

**Reason**: `.claude/CLAUDE.md` 已搬遷至 repo root `AGENTS.md`。

**Migration**: 由 ADDED requirement「repo root `AGENTS.md` 包含 setup 入口」承接，行為要求不變。
