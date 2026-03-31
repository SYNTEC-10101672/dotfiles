## Context

`claude-glm`（`.claude/scripts/claude-glm`）是一個 shell 包裝腳本，在 `exec claude "$@"` 之前設定 GLM 相關的環境變數。兩個指令最終都執行同一個 `claude` binary，因此 tmux 無法根據 process name 區分它們來命名 window。

## Goals / Non-Goals

**Goals:**
- 在 tmux 中啟動 `claude-glm` 時，window name 顯示為 "claude-glm"
- tmux 外不產生任何副作用

**Non-Goals:**
- 修改原生 `claude` 的行為
- 支援其他 terminal multiplexer（screen 等）

## Decisions

**在包裝腳本中以 `$TMUX` 檢查進行 rename**
- 包裝腳本本來就在 `exec claude` 前設定環境變數，在同一位置加入 `tmux rename-window` 是最小範圍的修改。
- 考慮過的替代方案：在 `.bashrc` 中使用 shell function — 被否決，因為這會將邏輯分散到兩個設定檔，且在其他情境下（如 scripts、其他檔案的 alias）呼叫包裝腳本時無法發揮作用。

## Risks / Trade-offs

- [競態條件] → 可忽略。`rename-window` 在 `exec claude` 接管 process 前同步執行。
- [覆蓋使用者自訂的 window name] → 影響低。rename 僅在啟動時觸發，啟動後手動更改 name 不受影響。
