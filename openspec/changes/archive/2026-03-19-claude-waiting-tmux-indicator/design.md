## Context

目前 Claude Code Stop hook 觸發時，`claude-notify-stop.sh` 向 pane tty 發送 BEL 字元（`\a`），tmux 以 `window_bell_flag` 記錄，`window-status-format` 條件式渲染 `✓`。

這個機制只有 binary 狀態（有 bell / 無 bell），無法區分「任務完成」與「等待使用者回應」兩種情境。

## Goals / Non-Goals

**Goals:**
- 當 Claude Code 出現 permission dialog 時，window bar 顯示 `?`
- 當 Claude Code 執行 `AskUserQuestion` 時，window bar 顯示 `?`
- 任務完成（Stop）時繼續顯示 `✓`
- Claude 開始處理（使用任何其他 tool）時自動清除指示符
- 使用者切換到該 window 時自動清除指示符

**Non-Goals:**
- 不處理 `idle_prompt` 通知（與 Stop 語意重疊，不需要額外視覺區分）
- 不發出聲音（bell 僅用於觸發 tmux flag，與視覺顯示解耦）
- 不支援 tmux 以外的環境

## Decisions

### Decision 1：以 `@claude_state` window option 取代 `window_bell_flag` 驅動視覺顯示

**選擇**：用 `tmux set-window-option @claude_state <value>` 存三種狀態（`"done"` / `"waiting"` / `""`），`window-status-format` 讀取此值決定顯示。

**捨棄方案**：繼續用 bell flag 搭配 activity flag 分別代表兩種狀態。
**原因**：bell flag 和 activity flag 都是 binary，且 activity flag 已被 `monitor-activity` 使用，容易產生衝突。`@claude_state` 可存任意字串，擴展性更好。

**代價**：`window_bell_flag` 切換 window 時自動消失的行為不再內建，改用 tmux `after-select-window` hook 補足：切換到 window 時自動將 `@claude_state` 清空。`PreToolUse` hook 則在 Claude 開始處理時額外清除。

### Decision 2：仍發送 BEL 字元，但僅作為音效/注意力提示

`claude-notify-stop.sh` 和 `claude-notify-waiting.sh` 都繼續發送 `\a`，讓 tmux 維持 bell 行為（例如終端機 bell 聲）。視覺顯示改由 `@claude_state` 驅動，兩者解耦。

### Decision 3：用 `PreToolUse`（無 matcher）清除狀態，用 `PreToolUse`（matcher: AskUserQuestion）設定等待狀態

Hook 執行順序：同一事件的 hooks 依序執行，matcher 更具體的優先。設定方式：

```json
"PreToolUse": [
  { "matcher": "AskUserQuestion", "hooks": [{ "command": "claude-notify-waiting.sh" }] },
  { "matcher": "",                "hooks": [{ "command": "claude-notify-clear.sh" }]  }
]
```

**注意**：需確認 Claude Code 是否依序執行同一事件的多個 hook 群組，以及 matcher 是否互斥。若兩個都觸發，`AskUserQuestion` 時狀態會被清除。

→ **風險緩解**：在 `claude-notify-clear.sh` 中排除 `AskUserQuestion`（讀取 stdin JSON 的 `tool_name` 欄位判斷）。

### Decision 4：`@claude_state` 設在 window 層級，而非 pane 層級

一個 window 通常只跑一個 Claude Code session，window 層級足夠。且 `window-status-format` 直接讀取 window option，不需要額外的 pane→window 映射。

## Risks / Trade-offs

- **`@claude_state` 不自動清除** → 若 Claude Code 異常結束，`?` 或 `✓` 會停留在 window bar，直到下次 hook 觸發。可接受，屬於邊緣情境。
- **多個 Claude Code pane 共用同一 window** → `@claude_state` 只有一個值，後觸發的 hook 會覆蓋前者。目前不支援此情境，屬於 Non-Goal。
- **PreToolUse matcher 行為未經驗證** → 需要實際測試確認 `AskUserQuestion` 的 PreToolUse hook 與空 matcher 的 PreToolUse hook 是否能獨立觸發，不互相干擾。
