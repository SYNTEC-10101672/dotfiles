# Proposal: migrate-config-to-opencode

## Why

使用者已解除 Claude 訂閱、改用 opencode + Z.AI GLM，不再使用 claude CLI。現況有三個問題：

1. **Compat 靜默失效**：`~/.claude/CLAUDE.md` 的讀取是 OpenCode V1 legacy 相容行為，V2 只認 `AGENTS.md` — opencode 升級後全域指示檔會靜默失效。
2. **死部署拓撲**：`claude/` 目錄與 `make claude` target 部署的 `~/.claude/` 五條 symlinks 服務一個不再使用的 CLI；commands 實際上是借 `claude/commands` 給 opencode 用（`~/.config/opencode/commands` symlink 指向 `dotfiles/claude/commands`）。
3. **Spec 體系與現實矛盾**：26 個 specs 引用 `claude/` 路徑系統，其中 8 個規範的對象（`claude-glm`、`claude-code-statusline`、notify hooks、`~/.claude` 部署）即將不存在。

前置清理已完成（change `cleanup-claude-md-references`，commit `f0249db`）：skills/commands 內文已零全域指示檔引用、零必改 claude 字眼。搬遷已是純機械動作 + 兩個指示檔的必要改名。

## What Changes

**檔案搬遷（git mv，保留歷史）**：
- `claude/commands/` → `opencode/commands/`（9 個 command 檔含 `opsx/` 子目錄）
- `claude/skills/` → `opencode/skills/`（12 個 skill 目錄，內文零修改）
- `claude/CLAUDE.md` → `opencode/AGENTS.md`（內文零修改 — 已驗證全文無 claude 字眼）
- `.claude/CLAUDE.md` → root `AGENTS.md`（內文改寫：Architecture 段、`make claude` 模組清單、Claude Code plugins 提及）

**刪除**：
- `claude/settings.json`（user-level：hooks、attribution、plugins — 全為 claude 專屬）
- `claude/scripts/` 整目錄（`claude-glm`、`claude-code-statusline`、`claude-notify-stop.sh`、`claude-notify-waiting.sh`；後兩者已有 identical 副本於 `opencode/scripts/`）
- root `.claude/settings.json`（僅含 `enabledPlugins: claude-code-setup`）
- `claude/`、`.claude/` 空目錄

**Makefile**：
- 刪 `claude` target、`CLAUDE_FILES`/`CLAUDE_DIRS` 變數、`install` 與 `.PHONY` 中的 `claude`
- `opencode` target：commands symlink 來源改 `opencode/commands`；新增 `skills` 目錄 symlink 與 `AGENTS.md` 單檔 symlink
- `scripts` target：刪 `claude-glm`、`claude-code-statusline` 兩條 `~/bin` symlink
- `check`/`uninstall`：移除 `~/.claude` 段與 `~/bin/claude-*`；新增 opencode `skills`/`AGENTS.md` 項目

**Docs 與雜項**：
- `.gitignore`：刪 `# Claude Code` 區塊（`.claude/*`、`!.claude/CLAUDE.md`、`!.claude/settings.json`）
- `README.md`：功能特色、結構樹、`make claude`、Claude Code 設定段、jq troubleshooting
- `docs/SETUP.md`：刪 §9「Claude Code CLI 與 Plugins」、jq 說明、驗證段 `claude plugin list`
- `env.example`：`GLM_API_KEY` 說明從「claude-glm 命令」改為 opencode provider 用途
- `opencode/oh-my-openagent.json` 的 `claude_code` 區塊（全 false）**保留不動** — 防禦性明示關閉

**部署切換（runtime 動作，不進 git）**：
`make opencode` → 使用者開新 session 驗證 → 拔 `~/.claude/` 五條 config symlinks（runtime 目錄 `~/.claude/` 本體保留）→ 拔 `~/bin/claude-glm`、`~/bin/claude-code-statusline`

## Capabilities

### New Capabilities
- `project-agents-md`：repo root `AGENTS.md` 的存在性與內容大綱（承接 `project-claude-md` 的 path 變更後職責）

### Modified Capabilities
- `opencode-commands-symlink`：commands symlink 來源從 `dotfiles/claude/commands` 改為 `dotfiles/opencode/commands`
- `opencode-config-files`：`opencode/` 目錄內容新增 `commands/`、`skills/`、`AGENTS.md`；部署/check/uninstall 清單同步
- `mattpocock-skills`：`claude/skills/`、`claude/commands/`、`~/.claude/skills/` 部署鏈路徑全面改寫
- `writing-skills`：command 檔路徑與部署鏈改寫（只剩 opencode 一條鏈）
- `openspec-skill-command-parity`：`claude/commands/opsx/` 與 `claude/skills/openspec-<name>/` 路徑改寫
- `commit-rules-placement`：路徑改寫 + 刪除 `claude/settings.json` attribution 引用（規則由 `/commit` command 自包含承載）
- `skill-authoring-governance`：路徑改寫 + 收容 `claude-config-symlink` 遺孤（explore 寫檔白名單、CONTEXT.md 寫入程序）
- `handover-dual-mode`：HANDOVER.md auto-detect 規則的宿主從 `.claude/CLAUDE.md` 改為 root `AGENTS.md`
- `self-contained-tasks`：全域指示檔路徑改 `opencode/AGENTS.md` + 收容遺孤（TDD 規範記載要求）
- `domain-knowledge-layer`：全域指示檔路徑改 `opencode/AGENTS.md`（部署於 `~/.config/opencode/AGENTS.md`）
- `setup-guide`：刪「安裝 Claude Code CLI」步驟；setup 入口規則宿主改 root `AGENTS.md`
- `dotfiles-install`：收容 `claude-config-symlink` 遺孤（Makefile 禁止 backup/restore/clean target）
- `opencode-native-notify`：收容 `claude-task-notify`/`claude-waiting-indicator` 的 tmux 消費端 requirements（status bar 格式、切換清除、不改 window 名稱）；「與 claude 設定零相依」requirement 移除歷史字眼
- `glossary-maintenance`：`claude/skills/` 路徑改寫
- `spec-test-contract`：`claude/skills/` 路徑改寫
- `artifact-review-gate`：範例路徑 `claude/skills/nonexistent/` 改寫
- `openspec-code-review`：`~/.claude/skills/` 部署路徑與 `~/.claude/CLAUDE.md` 引用改寫
- `skill-self-containment`：`claude/skills/`、`claude/commands/` 掃描路徑改寫

### Removed Capabilities
- `claude-config-symlink`：`~/.claude` 混合 symlink 部署與 `make claude` target 消失；倖存 requirements 已遷往 `self-contained-tasks`、`skill-authoring-governance`、`dotfiles-install`
- `project-claude-md`：`.claude/CLAUDE.md` 不存在，職責由 `project-agents-md` 承接
- `claude-task-notify`：claude hooks 鏈消失；行為由 `opencode-native-notify`（`plugins/notify.ts` + `scripts/notify-*.sh`）承接
- `claude-waiting-indicator`：同上（且其引用的 `claude-notify-clear.sh` 從未存在於 repo，spec 已 stale）
- `glm-quota-display`：`claude-glm` 與 `claude-code-statusline` 刪除；opencode 端 quota 顯示由 `@slkiser/opencode-quota` plugin 承接（外部 plugin，非本 repo 檔案）
- `glm-dynamic-model-display`：同上
- `statusline-rate-limit`：同上
- `tmux-window-rename`：規範 `claude-glm` 的 tmux window 改名行為，對象消失

## Impact

- **部署拓撲**：`make install` 不再部署 `~/.claude/`；`make opencode` 部署範圍擴大（commands/skills/AGENTS.md）。全域指示檔生效路徑 `~/.claude/CLAUDE.md` → `~/.config/opencode/AGENTS.md`。
- **行為承接**：BEL 通知與 `@claude_state` 由 opencode scripts 持續供給（zsh prompt 消費端不受影響）；quota/model 顯示改由 opencode quota plugin 承擔；AI 署名防護由 `/commit` command 自包含規則承擔（opencode 預設不加 `Co-Authored-By`）。
- **切換風險**：git mv 會使現存 `~/.config/opencode/commands` symlink 短暫 dangling — mv、Makefile 修改、`make opencode` 必須在同一 task 內完成。全域指示檔僅對新 session 生效，驗證必須開新 session。
- **`~/.claude/` runtime 保留**：credentials/history/transcripts 不動，只拔五條 config symlinks。
- **Git 歷史**：`git mv` 保留歷史，`git log --follow` 可追溯。
