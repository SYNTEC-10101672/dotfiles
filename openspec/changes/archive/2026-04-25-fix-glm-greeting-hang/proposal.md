## Why

`claude-glm` 的 cron greeting 自 2026-04-25 起持續失敗（卡住不回應），因為最近加入的 background quota refresh loop 繼承了 command substitution 的 pipe fd，導致 greeting-runner.sh 永遠等不到 EOF。同時系統上累積了多個僵屍 greeting 進程。

## What Changes

- 修正 `claude-glm` script 中 background quota refresh loop 的 fd 洩漏問題，將其 stdout/stderr 重定向到 `/dev/null`，確保不繼承 parent 的 pipe fd
- 清理目前系統上卡住的僵屍 greeting 進程

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `glm-quota-display`: background quota refresh loop 需正確隔離 file descriptors，避免在 command substitution 等場景下造成 parent hang

## Impact

- `claude/scripts/claude-glm`：background loop 加上 output redirect
- 系統進程：需手動清理卡住的 greeting-runner 和 claude-glm 僵屍進程
