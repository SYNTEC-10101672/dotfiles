# Spec: statusline-rate-limit

## Purpose

Display Claude API rate limit usage and reset time in the tmux statusline, allowing users to monitor their 5-hour quota at a glance.

## Requirements

### Requirement: 顯示 5 小時額度使用量與剩餘重置時間
Statusline script 應從 JSON 輸入解析 `rate_limits.five_hour.used_percentage` 與 `rate_limits.five_hour.resets_at`，並在值存在時將格式化結果附加至 statusline 輸出。

#### Scenario: 有額度資料且剩餘時間超過 1 小時
- **WHEN** JSON 輸入包含 `rate_limits.five_hour.used_percentage` 與 `resets_at`，且剩餘時間 ≥ 1 小時
- **THEN** statusline 應包含 ` | 🔋 N% (Xh Ym)`（N 為整數百分比，X 為剩餘小時，Y 為剩餘分鐘）

#### Scenario: 有額度資料且剩餘時間不足 1 小時
- **WHEN** JSON 輸入包含 `rate_limits.five_hour.used_percentage` 與 `resets_at`，且剩餘時間 < 1 小時
- **THEN** statusline 應包含 ` | 🔋 N% (Ym)`，省略小時部分

#### Scenario: 有額度資料但無 resets_at
- **WHEN** JSON 輸入包含 `rate_limits.five_hour.used_percentage`，但不含 `resets_at`
- **THEN** statusline 應包含 ` | 🔋 N%`，不顯示括號時間

#### Scenario: 無額度資料
- **WHEN** JSON 輸入不包含 `rate_limits` 或 `rate_limits.five_hour`
- **THEN** statusline 應完全省略額度欄位，且不產生任何錯誤輸出

#### Scenario: 額度資料為 null
- **WHEN** `rate_limits.five_hour.used_percentage` 的值為 JSON null
- **THEN** statusline 應完全省略額度欄位
