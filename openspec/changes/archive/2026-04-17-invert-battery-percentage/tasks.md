## 1. Script 修改

- [x] 1.1 將 `claude/scripts/claude-code-statusline` 第 71 行的 `RATE_LIMIT_USED` 改為 `100 - RATE_LIMIT_USED`

## 2. Spec 同步

- [x] 2.1 執行 `openspec sync` 將 delta spec 合併到 `openspec/specs/statusline-rate-limit/spec.md`

## 3. 驗證

- [x] 3.1 使用 mock JSON input 測試各 scenario（有額度有時間、有額度無時間、無額度、0% used → 100% remaining）
