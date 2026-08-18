## Why

Z.AI 已於 2026-08-14 發佈 GLM-5.3（1M context、128K max output），需同步更新 `claude-glm` 腳本的 model 配置。另外 `glm-4.5-air` 雖仍在 model list 中，但 API 實測已被 alias 到 `glm-4.7`，Haiku tier 改用 `glm-5-turbo`（實測 latency 0.82s，快於 `glm-4.7` 的 1.68s，且與主模型同家族）。

## What Changes

- 將 Opus tier model 從 `glm-5.2[1m]` 更新為 `glm-5.3[1m]`
- 將 Sonnet tier model 從 `glm-5.2[1m]` 更新為 `glm-5.3[1m]`
- 將 Haiku tier model 從 `glm-4.5-air` 更新為 `glm-5-turbo`
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` 維持不變（GLM-5.3 支援 1M context）
- 更新 `glm-dynamic-model-display` spec 中的 model 名稱範例

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `glm-dynamic-model-display`：Sonnet/Opus scenario 範例中的 model 名稱需從 `glm-5.2[1m]` 更新為 `glm-5.3[1m]`；Haiku scenario 範例從 `glm-4.5-air` 更新為 `glm-5-turbo`

## Impact

- `claude/scripts/claude-glm`：model 環境變數與 header 註解
- `openspec/specs/glm-dynamic-model-display/spec.md`：scenario 範例中的 model 名稱
