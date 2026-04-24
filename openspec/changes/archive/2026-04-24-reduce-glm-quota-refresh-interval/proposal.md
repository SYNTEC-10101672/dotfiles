## Why

目前 `claude-glm` 腳本的背景 quota 查詢迴圈間隔為 180 秒（3 分鐘），statusline 顯示的 quota 資訊更新過慢，無法即時反映使用狀況。縮短為 60 秒可讓使用者更快察覺 quota 消耗。

## What Changes

- 將 `claude/scripts/claude-glm` 中背景 quota refresh loop 的兩個 `sleep 180` 改為 `sleep 60`
  - API 呼叫失敗時的重試間隔：180s → 60s
  - 正常更新後的等待間隔：180s → 60s

## Capabilities

### New Capabilities

無。

### Modified Capabilities

- `glm-quota-display`：quota 快取更新頻率從每 3 分鐘改為每 1 分鐘。

## Impact

- `claude/scripts/claude-glm`：修改 sleep 參數
- API 請求頻率提升 3 倍（每小時 20 次 → 60 次），需確認 Z.AI quota endpoint 無頻率限制
