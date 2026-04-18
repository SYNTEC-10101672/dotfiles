# Spec: Setup Guide

## Purpose

Define requirements for the new machine setup guide (`docs/SETUP.md` and related documentation), ensuring AI agents can follow it linearly to configure a complete development environment from scratch.

## Requirements

### Requirement: SETUP.md 涵蓋完整新機器建置流程
`docs/SETUP.md` SHALL 涵蓋以下所有步驟，並以此順序呈現：
1. Clone repository 並執行 `make install`
2. 安裝系統套件（jq, tmux, tig, ripgrep, fzf, fd, curl, git, make, bash-completion, python3, sshpass）
3. 安裝 nvm 與 node.js
4. 安裝 bun runtime
5. 安裝 neovim（若系統版本不足）
6. 安裝 atuin
7. 安裝 opencode 並執行 `make opencode`
8. 安裝 oh-my-openagent
9. 安裝 Claude Code CLI 並安裝所有 enabled plugins
10. 設定 `~/.env`（指向 `docs/ENV_SETUP.md` 取得詳細說明）
11. Optional：安裝 .NET SDK 與 OmniSharp（C# 開發用）
12. 執行驗證（`make check` + 套件 check script）

#### Scenario: AI 可線性執行 SETUP.md
- **WHEN** AI 在全新 Linux 機器上閱讀 `docs/SETUP.md`
- **THEN** AI SHALL 能夠從第一步到最後一步依序執行，不需跳回前面步驟或參考其他文件（ENV_SETUP.md 除外）

### Requirement: 套件安裝指令不綁定特定發行版
SETUP.md 中的套件安裝說明 SHALL NOT 指定特定套件管理器（apt、pacman 等），改以描述需求或提供 distro-agnostic 安裝 script。

#### Scenario: 遇到系統套件安裝步驟
- **WHEN** AI 閱讀系統套件安裝步驟
- **THEN** AI SHALL 能夠理解需要安裝的套件名稱，並自行選擇適合當前系統的安裝方式

### Requirement: SETUP.md 包含驗證步驟
SETUP.md 最後 SHALL 提供可一鍵執行的驗證指令，確認所有必要工具已正確安裝。

#### Scenario: 執行驗證
- **WHEN** 執行 `make check` 與套件 check script
- **THEN** 輸出應顯示所有必要工具的安裝狀態（✓ 或 ✗）

### Requirement: Optional 段落僅包含 OmniSharp
SETUP.md 的 Optional 段落 SHALL 只包含 OmniSharp（含 .NET SDK 前置條件），不包含其他工具。

#### Scenario: 閱讀 Optional 段落
- **WHEN** AI 閱讀 SETUP.md 的 Optional 段落
- **THEN** SHALL 只看到 OmniSharp 相關安裝說明

### Requirement: ENV_SETUP.md 移除棄用的 SYNTEC MCP 內容
`docs/ENV_SETUP.md` SHALL NOT 包含 SYNTEC Confluence/JIRA MCP 的設定說明、`start-mcp-server.sh`、`check-mcp-connection.sh` 的參考。

#### Scenario: 閱讀 ENV_SETUP.md
- **WHEN** AI 閱讀 `docs/ENV_SETUP.md`
- **THEN** SHALL 不看到任何 SYNTEC_EMAIL、SYNTEC_API_TOKEN 的說明

### Requirement: `.claude/CLAUDE.md` 包含 setup 入口
Project-level `.claude/CLAUDE.md` SHALL 包含一個段落，明確說明新機器建置時應參考 `docs/SETUP.md`。

#### Scenario: AI 開始新機器建置
- **WHEN** AI 讀取 `.claude/CLAUDE.md` 並需要設定新機器
- **THEN** SHALL 能夠找到 `docs/SETUP.md` 的參考連結
