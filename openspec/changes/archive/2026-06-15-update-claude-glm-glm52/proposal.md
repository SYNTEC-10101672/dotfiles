## Why

Z.AI 已發佈 GLM 5.2，提供 1M token context window，取代原本的 glm-5.1 和 glm-5-turbo。需同步更新 `claude-glm` 腳本的 model 配置，以使用最新模型並啟用 1M context。

## What Changes

- 將 Opus tier model 從 `glm-5.1` 更新為 `glm-5.2[1m]`
- 將 Sonnet tier model 從 `glm-5-turbo` 更新為 `glm-5.2[1m]`
- 新增 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` 以配合 1M context 運作
- 將 Haiku tier model 名稱從 `GLM-4.5-Air` 統一為官方小寫 `glm-4.5-air`
- 更新 `glm-dynamic-model-display` spec 中的 model 名稱範例

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `glm-dynamic-model-display`：Sonnet/Opus scenario 範例中的 model 名稱需從 `glm-5-turbo`/`glm-5.1` 更新為 `glm-5.2[1m]`

## Impact

- `claude/scripts/claude-glm`：model 環境變數與 auto-compact 設定
- `openspec/specs/glm-dynamic-model-display/spec.md`：scenario 範例中的 model 名稱
