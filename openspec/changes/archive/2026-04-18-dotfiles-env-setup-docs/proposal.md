## Why

現有的 `doc/PACKAGES.md` 是套件參考清單，不是可執行的安裝流程；`doc/ENV_SETUP.md` 包含已棄用的 SYNTEC MCP 內容。下一個 AI 在全新機器上進行環境建立時，缺乏一份可從頭到尾線性執行的 setup 指南。

## What Changes

- `doc/` 目錄重新命名為 `docs/`
- `docs/PACKAGES.md` 重寫為 `docs/SETUP.md`：以 AI 可執行的線性 checklist 取代現有的套件參考表，涵蓋從 clone 到驗證的完整新機器建置流程，套件安裝指令不指定特定發行版
- `docs/ENV_SETUP.md`：移除已棄用的 SYNTEC Confluence/JIRA MCP 段落（現已改用 Claude Code plugins）
- `env.example`：移除 `SYNTEC_EMAIL`、`SYNTEC_API_TOKEN` 欄位
- `README.md`：修正過時的專案結構圖（`.nvim/` → `nvim/`、`.claude/` → `claude/`）、更新 `doc/` → `docs/` 參考連結
- `.claude/CLAUDE.md`（project-level）：加入新機器 setup 的入口說明，指向 `docs/SETUP.md`

## Capabilities

### New Capabilities

- `setup-guide`: 新機器從零建置的完整 setup 指南（`docs/SETUP.md`）——線性 checklist，涵蓋系統套件、language runtimes、Claude Code plugins、opencode、oh-my-openagent、環境變數設定、驗證，optional 段落僅保留 OmniSharp

### Modified Capabilities

## Impact

- `docs/SETUP.md`（新檔案，取代 `docs/PACKAGES.md`）
- `docs/ENV_SETUP.md`（移除 SYNTEC MCP 段落）
- `env.example`（移除 SYNTEC 欄位）
- `README.md`（更新結構圖與連結）
- `.claude/CLAUDE.md`（加入 setup 入口）
