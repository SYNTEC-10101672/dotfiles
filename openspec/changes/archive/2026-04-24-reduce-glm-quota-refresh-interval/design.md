## Context

`claude/scripts/claude-glm` 在啟動時會 fork 一個背景子程序，持續呼叫 Z.ai quota API 並將結果寫入 `/tmp/glm-quota-cache.json`，供 statusline 讀取顯示。目前 loop 間隔固定為 180 秒。

## Goals / Non-Goals

**Goals:**
- 將 quota refresh 間隔從 180 秒縮短為 60 秒，讓 statusline 顯示更即時

**Non-Goals:**
- 動態調整間隔（固定值即可）
- 修改 cache 格式或 statusline 邏輯

## Decisions

**兩個 sleep 都改**：loop 中有兩個 `sleep 180`，分別對應 API 失敗重試路徑與正常更新路徑，均改為 `sleep 60`，保持一致的行為。

## Risks / Trade-offs

- API 請求頻率從每小時 ~20 次提升至 ~60 次。Z.ai quota endpoint 目前未知是否有 rate limit；若有，失敗路徑的靜默略過機制可自然吸收錯誤，不影響主流程。
