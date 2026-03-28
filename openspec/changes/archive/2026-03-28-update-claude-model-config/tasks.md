## 1. 更新 claude-glm 腳本

- [x] 1.1 將 `ANTHROPIC_DEFAULT_OPUS_MODEL` 從 `GLM-4.7` 改為 `glm-5.1`
- [x] 1.2 將 `ANTHROPIC_DEFAULT_SONNET_MODEL` 從 `GLM-4.7` 改為 `glm-5-turbo`
- [x] 1.3 移除靜態 `CLAUDE_PROXY_MODEL` 環境變數設定
- [x] 1.4 更新腳本頂部的 Models 註解，反映新的 model 名稱

## 2. 更新 claude-code-statusline 腳本

- [x] 2.1 修改 GLM 模式的顯示邏輯：根據 `MODEL_DISPLAY` 做 substring match 判斷 tier，查對應 `ANTHROPIC_DEFAULT_*` env var
- [x] 2.2 加入 fallback 邏輯：無法對應 tier 時顯示 `[GLM]`
- [x] 2.3 修改 native 模式前綴：從 `Claude Code Native ($MODEL_DISPLAY)` 改為直接顯示 `$MODEL_DISPLAY`
- [x] 2.4 修改 GLM 模式前綴：從 `Claude Code GLM: $CLAUDE_PROXY_MODEL` 改為 `GLM <resolved-model>`

## 3. 更新 settings.json

- [x] 3.1 將 `"model": "opusplan"` 改為 `"model": "sonnet"`

## 4. 驗證

- [x] 4.1 執行 `claude-glm`，確認 statusline 顯示 `[GLM glm-5-turbo]`（sonnet tier 預設）
- [x] 4.2 在 `claude-glm` session 內用 `/model` 切換為 opus，確認 statusline 更新為 `[GLM glm-5.1]`
- [x] 4.3 在 `claude-glm` session 內用 `/model` 切換為 haiku，確認 statusline 顯示 `[GLM GLM-4.5-Air]`
- [x] 4.4 執行原生 `claude`，確認 statusline 顯示格式為 `[Sonnet 4.6]`（無 "Claude Code Native" 前綴）
- [x] 4.5 確認 `claude` plan mode 不再自動升級為 opus（進入 plan mode 後 model 維持 sonnet）
