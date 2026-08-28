# Delta Spec: glm-quota-display

## REMOVED Requirements

### Requirement: claude-glm 啟動時背景 fetch Z.ai quota 並快取

**Reason**: `claude-glm` wrapper 為 claude CLI 啟動封裝，隨 claude CLI 退役刪除（`claude/scripts/claude-glm` 與 `~/bin/claude-glm` symlink）。

**Migration**: 無 repo 內承接。opencode 端 quota 顯示由 `@slkiser/opencode-quota` plugin + `opencode.json` 的 `experimental.quotaToast` 承擔（外部 plugin，非本 repo 檔案）。

### Requirement: statusline 在 GLM 模式下顯示 TOKENS_LIMIT 剩餘配額與 reset 倒數

**Reason**: `claude-code-statusline` 為 Claude Code statusline 腳本，隨 claude CLI 退役刪除。

**Migration**: 無 repo 內承接（同上，由 opencode quota plugin 承擔顯示職責）。
