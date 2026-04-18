## Context

目前 `doc/PACKAGES.md` 是套件清單格式，對 AI 而言不是可執行的流程。`doc/ENV_SETUP.md` 包含已棄用的 SYNTEC MCP 段落（現已改用 Claude Code Atlassian plugin）。README.md 的專案結構圖仍使用舊路徑（`.nvim/`、`.claude/`）。

這是純文件變更，不涉及任何設定檔邏輯的修改。

## Goals / Non-Goals

**Goals:**
- `docs/SETUP.md` 讓 AI 在全新機器上可從頭到尾線性執行，不需跳頁或推斷
- 移除所有已棄用的 SYNTEC MCP 內容
- README.md 與實際目錄結構一致

**Non-Goals:**
- 不修改任何 dotfiles 設定檔本身（Makefile、.bashrc、settings.json 等）
- 不為不同 Linux 發行版撰寫分支指令（generic 指令，讓 AI 依環境判斷）
- 不刪除 `claude/scripts/start-mcp-server.sh`、`check-mcp-connection.sh` 等 script 檔案本身

## Decisions

**SETUP.md 採線性 checklist 而非參考表**
原本的表格格式適合查詢，不適合執行。改為有編號順序的步驟，每個步驟有前置條件說明與驗證指令，AI 可從第一步走到最後一步而不需要額外判斷。

**套件安裝指令不指定發行版**
不寫 `apt install` 或 `pacman -S`，改為描述「需要安裝 X 套件」並提供官方安裝 script（nvm、bun、atuin 等均有 distro-agnostic 安裝方式）。AI 可根據實際系統選擇正確的套件管理器。

**ENV_SETUP.md 保留為獨立文件，不合併進 SETUP.md**
SETUP.md 中 step 6 僅說明「執行 `cp env.example ~/.env` 並填入 token」，細節指向 ENV_SETUP.md。分離原因：ENV_SETUP.md 包含 credentials 安全管理規範，合併會讓 SETUP.md 過長且責任混雜。

**Optional 段落僅保留 OmniSharp**
其餘工具（fzf、fd、atuin、opencode、oh-my-openagent 等）全部列為必要安裝，反映實際使用情況。

## Risks / Trade-offs

**文件與實際 Makefile 再次失同步** → 在 `.claude/CLAUDE.md` 加入明確說明，每次新增 Makefile target 或 plugin 時需同步更新 `docs/SETUP.md`。

**SETUP.md 的 generic 指令可能對某些發行版不夠精確** → 可接受，目標是讓 AI 讀懂意圖後自行判斷，而非提供複製貼上的命令。
