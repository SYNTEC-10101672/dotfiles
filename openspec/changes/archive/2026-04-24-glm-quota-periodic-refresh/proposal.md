## Why

目前 `claude-glm` 僅在啟動時 fetch 一次 Z.ai quota API 並快取至 `/tmp/glm-quota-cache.json`，之後整個 session 不再更新。一個 session 可能執行數小時，quota 持續消耗但顯示的數字始終是啟動時的 snapshot，失去參考價值。

## What Changes

- 將 `claude-glm` 的背景 quota fetch 從一次性改為每 3 分鐘定期更新

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `glm-quota-display`: 將 quota fetch 從啟動時一次性改為定期更新（每 3 分鐘），新增 session 存活期間持續 poll 的行為規格

## Impact

- `claude/scripts/claude-glm`：背景 subshell 從單次 curl 改為 while loop + sleep
- `claude/scripts/claude-code-statusline`：不需修改（仍讀取同一個 cache 檔案）
- 執行期行為變化：`claude-glm` session 期間會有一個常駐的輕量背景 process
