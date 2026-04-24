## Context

`claude-glm` 是以 Z.ai GLM API 為後端的 Claude Code wrapper。`claude-code-statusline` 透過 stdin JSON 取得資訊並渲染 statusline。

Native Claude 模式的 rate limit 資料由 Claude Code 注入 stdin JSON（`rate_limits.five_hour.*`），GLM 模式下這個欄位不存在。Z.ai 提供獨立的 quota REST API，需要主動呼叫後才能取得配額狀態。

## Goals / Non-Goals

**Goals:**
- GLM 模式下在 statusline 顯示 TOKENS_LIMIT 剩餘配額百分比（100 - used%）
- GLM 模式下在 statusline 顯示距離 reset 的倒數時間
- 不影響 native Claude 模式的行為

**Non-Goals:**
- Session 期間的配額即時更新（啟動時 fetch 一次即可）
- TIME_LIMIT 類型的配額顯示（僅顯示 TOKENS_LIMIT）
- 配額耗盡時的警告通知

## Decisions

### 決策 1：快取機制使用 `/tmp/glm-quota-cache.json`

`claude-glm` 在啟動後以背景子程序呼叫 Z.ai API，結果寫入 `/tmp/glm-quota-cache.json`。`claude-code-statusline` 在 GLM 模式下讀取此檔案。

**考慮的替代方案：**
- **每次 statusline 呼叫時打 API**：statusline 是 event-driven，Claude 活躍期間每次 tool use 都會觸發，打 API 會造成高延遲且浪費配額。捨棄。
- **將快取存至 `~/.claude/logs/`**：跨 reboot 保留，但快取過期後顯示的資料會更舊。`/tmp` 在 reboot 後清除，符合「每次使用前重新 fetch」的語意。採用 `/tmp`。

快取格式（最小欄位集）：
```json
{
  "tokens_remaining": 99,
  "tokens_reset_at": 1776996269,
  "fetched_at": 1776988800
}
```

### 決策 2：顯示邏輯複用 rate limit pattern

沿用 `statusline-rate-limit` spec 的現有顯示格式（`🔋 N% (Xh Ym)`），只改資料來源為 cache file。視覺上與 native Claude 一致，不需要引入新的 UI 元素。

### 決策 3：API 呼叫失敗時靜默略過

若 fetch 失敗（網路錯誤、API key 無效等），不更新快取，statusline 靜默略過 quota 欄位。不顯示錯誤，避免干擾 statusline 輸出格式。

## Risks / Trade-offs

- **快取過期**：若 `claude-glm` 長時間不重啟，快取資料會漸漸過期，顯示的 reset 倒數仍能即時計算，但剩餘百分比可能不準。→ 可接受，statusline 為參考用途。
- **多個 `claude-glm` 實例同時寫入**：last-write-wins，資料內容相近，不影響正確性。→ 可接受。
- **`/tmp` 在某些系統的清理策略不同**：大多數 Linux distro 在 reboot 時清除 `/tmp`，符合預期。→ 若 `/tmp` 被提早清除，下次 `claude-glm` 啟動時會重新建立。
