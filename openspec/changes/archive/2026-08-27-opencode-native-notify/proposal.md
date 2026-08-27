# Proposal: opencode-native-notify

## Why

opencode 已取代 Claude Code 成為主要的 AI coding 工具，但 tmux 通知（完成 `✓` / 等待 `?` + bell）目前依賴 oh-my-openagent 的 claude-code-hooks bridge 讀取 `~/.claude/settings.json` — 跨工具的間接層，且 atuin 記錄等不需要的 hooks 也被一併啟用。設定應收斂到 opencode 原生機制，為後續刪除 Claude 設定檔鋪路。

## What Changes

- 新增 opencode native plugin `dotfiles/opencode/plugins/notify.ts`：監聽 `session.idle`（主 session 過濾）與 `permission.asked` 事件，呼叫通知 scripts
- 新增 `dotfiles/opencode/scripts/notify-stop.sh` 與 `notify-waiting.sh`：獨立新檔（非 symlink），內容沿用現有 `claude/scripts/claude-notify-*.sh` 邏輯（tmux `@claude_state` + BEL），與 `claude/` 目錄零相依
- `dotfiles/opencode/oh-my-openagent.json` 的 `claude_code` 區塊加入 `"hooks": false`，停用 bridge（**BREAKING**：atuin shell 歷史記錄、elicitation 通知等 bridge 行為同時消失，經確認不需要）
- `Makefile` 的 `opencode` target 擴充：部署 `plugins/` 與 `scripts/` 到 `~/.config/opencode/`
- `claude/settings.json` 的 hooks 區塊**保留不動**（另案處理）

## Capabilities

### New Capabilities
- `opencode-native-notify`: opencode native plugin 驅動的 tmux window bar 通知機制（完成 `✓` / 等待 `?` + BEL），不依賴 claude-code-hooks bridge

### Modified Capabilities
- `opencode-config-files`: `dotfiles/opencode/` 內容從 3 個檔案擴增為 `plugins/` 與 `scripts/` 目錄，`make opencode` 部署範圍跟著擴大

## Impact

- 新檔案：`dotfiles/opencode/plugins/notify.ts`、`dotfiles/opencode/scripts/notify-stop.sh`、`dotfiles/opencode/scripts/notify-waiting.sh`
- 修改：`dotfiles/opencode/oh-my-openagent.json`（`claude_code.hooks: false`）、`Makefile`（opencode target）、`README.md`（專案結構）
- 行為風險：oh-my-openagent 內建通知與本 plugin 同聽 `session.idle` / `permission.asked` — 預期 auto-disable 禮讓，需實測驗證無 double bell
- 不受影響：`claude/settings.json`、`claude/scripts/`（Claude Code 端行為完全不變）、tmux 設定（`.tmux.conf` 沿用 `@claude_state` 慣例）
