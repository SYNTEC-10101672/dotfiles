# Delta Spec: statusline-rate-limit

## REMOVED Requirements

### Requirement: 顯示 5 小時額度使用量與剩餘重置時間

**Reason**: 規範 `claude-code-statusline` 解析 Claude API `rate_limits.five_hour` 的行為；claude CLI 與其 statusline 隨訂閱解除退役刪除。

**Migration**: 無 repo 內承接。opencode 端 quota 顯示由 `@slkiser/opencode-quota` plugin + `experimental.quotaToast` 承擔（`opencode.json` 已設定）。
