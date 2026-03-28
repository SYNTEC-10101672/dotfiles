## 動機

GLM 5 系列模型（glm-5.1、glm-5-turbo）已可用，取代 GLM-4.7 作為首選後端。此外，`opusplan` 模型設定會讓 plan mode 自動升級為 opus，在 GLM 使用情境下成本效益不符需求。

## 變更內容

- `claude-glm` 腳本：opus tier → `glm-5.1`，sonnet tier → `glm-5-turbo`
- `claude-glm` 腳本：`CLAUDE_PROXY_MODEL` 改為動態顯示（根據當前 model tier 反映實際 GLM model 名稱）
- `settings.json`：`"opusplan"` → `"sonnet"`，移除 plan mode 自動升 opus 的行為
- `claude-code-statusline`：簡化前綴顯示——native 只顯示 model 名稱（例如 `[Claude Sonnet 4.6]`），GLM 顯示 `[GLM <model-name>]`

## 功能範圍

### 新增功能

- `glm-dynamic-model-display`：statusline 根據當前 model tier（opus/sonnet/haiku），從 statusline JSON input 的 `model.display_name` 對應 `ANTHROPIC_DEFAULT_*` 環境變數，動態顯示實際 GLM model 名稱

### 修改功能

（無——無既有 spec 檔需要 delta spec）

## 影響範圍

- `.claude/scripts/claude-glm`：更新 env var 值，修改 `CLAUDE_PROXY_MODEL` 邏輯
- `.claude/scripts/claude-code-statusline`：更新 GLM/native 兩種模式的顯示前綴
- `.claude/settings.json`：`model` 欄位從 `"opusplan"` 改為 `"sonnet"`
