## MODIFIED Requirements

### Requirement: statusline 動態解析 GLM model 名稱
GLM 模式下，statusline SHALL 根據當前 model tier 動態顯示對應的 GLM model 名稱，而非使用靜態環境變數。解析邏輯如下：
- 從 JSON input 的 `model.display_name` 判斷 tier（case-insensitive substring match）
- 對應到 `ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL` 環境變數
- 若無法對應，fallback 顯示 `GLM`

#### Scenario: display_name 為 GLM model 名稱時直接使用
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`model.display_name` 包含 "glm"（例如 `glm-5.2[1m]`）
- **THEN** statusline 顯示 `[GLM glm-5.2[1m]]`

#### Scenario: sonnet tier 顯示對應 GLM model
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`model.display_name` 包含 "sonnet"，`ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2[1m]`
- **THEN** statusline 顯示 `[GLM glm-5.2[1m]]`

#### Scenario: opus tier 顯示對應 GLM model
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`model.display_name` 包含 "opus"，`ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2[1m]`
- **THEN** statusline 顯示 `[GLM glm-5.2[1m]]`

#### Scenario: haiku tier 顯示對應 GLM model
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`model.display_name` 包含 "haiku"，`ANTHROPIC_DEFAULT_HAIKU_MODEL=glm-4.5-air`
- **THEN** statusline 顯示 `[GLM glm-4.5-air]`

#### Scenario: 無法對應 tier 時 fallback
- **WHEN** `CLAUDE_PROXY_MODE=glm`，`model.display_name` 不含 "glm"/"opus"/"sonnet"/"haiku"
- **THEN** statusline 顯示 `[GLM]`

### Requirement: statusline 前綴格式簡化
statusline SHALL 移除冗餘的 "Claude Code Native" 與 "Claude Code GLM" 前綴文字。

#### Scenario: native 模式只顯示 model 名稱
- **WHEN** `CLAUDE_PROXY_MODE` 未設定（native 模式），`model.display_name` 為 "Sonnet 4.6"
- **THEN** statusline 顯示 `[Sonnet 4.6] 📁 ...`

#### Scenario: GLM 模式顯示 GLM 標記加 model 名稱
- **WHEN** `CLAUDE_PROXY_MODE=glm`，解析結果為 `glm-5.2[1m]`
- **THEN** statusline 顯示 `[GLM glm-5.2[1m]] 📁 ...`
