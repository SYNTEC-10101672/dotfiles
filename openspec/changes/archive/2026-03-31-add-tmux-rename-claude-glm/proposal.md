## Why

在 tmux 中執行 `claude-glm` 時，window bar 只顯示 "claude"，因為 `claude-glm` 本質上是 `exec claude` 的包裝腳本。這導致無法一眼區分原生 Claude 和 GLM 版本的 Claude window。

## What Changes

- 在 `claude-glm` 包裝腳本中加入 `tmux rename-window` 呼叫，並以 `$TMUX` 環境變數檢查守衛，確保在 tmux 外不會產生副作用。

## Capabilities

### New Capabilities

- `tmux-window-rename`: 在 tmux session 中啟動 claude-glm 時自動重新命名 tmux window。

### Modified Capabilities

_無。_

## Impact

- 僅修改單一檔案：`.claude/scripts/claude-glm`
- 非 tmux 環境不受影響（由 `$TMUX` 檢查守衛）
- 原生 `claude` 指令行為不受影響
