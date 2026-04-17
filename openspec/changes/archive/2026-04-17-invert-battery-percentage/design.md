## Context

`claude/scripts/claude-code-statusline` 腳本從 Claude Code 的 JSON input 解析 rate limit 資料，目前直接使用 `used_percentage` 顯示。修改為 `100 - used_percentage` 即可反轉語意。

## Goals / Non-Goals

**Goals:**

- Rate limit 百分比顯示剩餘配額（100→0），符合電池心智模型

**Non-Goals:**

- 不修改 context window 百分比
- 不修改 emoji 或格式
- 不修改重置時間顯示邏輯

## Decisions

- **計算方式**: `100 - used_percentage`，在 bash 中使用 `$(( 100 - RATE_LIMIT_USED ))`
- **不引入額外依賴**: 純 bash 算術，不需要修改 jq 解析邏輯

## Risks / Trade-offs

- 低風險：單行算術變更，不影響其他 statusline 欄位
