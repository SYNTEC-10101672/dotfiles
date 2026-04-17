## Why

Statusline 的 rate limit 百分比目前顯示「已使用量」（0→100），但 🔋 emoji 搭配「剩餘量」（100→0）更符合電池的使用者心智模型。

## What Changes

- 將 rate limit 百分比從 `used_percentage` 改為 `100 - used_percentage`（剩餘配額）
- 更新 `statusline-rate-limit` spec 的 scenario 語意對應

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `statusline-rate-limit`: 百分比語意從「已使用」改為「剩餘配額」

## Impact

- `claude/scripts/claude-code-statusline` — 第 71 行的 `RATE_LIMIT_USED` 計算
- `openspec/specs/statusline-rate-limit/spec.md` — scenario 的百分比描述
