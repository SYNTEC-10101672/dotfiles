## 測試

- [x] T1 Opus/Sonnet model 已更新為 glm-5.2[1m]
  > 指令：`grep -E "ANTHROPIC_DEFAULT_(OPUS|SONNET)_MODEL" claude/scripts/claude-glm`
  > 預期：兩行都包含 `glm-5.2[1m]`，不含 `glm-5.1` 或 `glm-5-turbo`

- [x] T2 CLAUDE_CODE_AUTO_COMPACT_WINDOW 已設定
  > 指令：`grep CLAUDE_CODE_AUTO_COMPACT_WINDOW claude/scripts/claude-glm`
  > 預期：輸出包含 `"1000000"`

- [x] T3 Haiku model 已統一為小寫
  > 指令：`grep ANTHROPIC_DEFAULT_HAIKU_MODEL claude/scripts/claude-glm`
  > 預期：輸出包含 `glm-4.5-air`（全小寫，不含 `GLM-4.5-Air`）

- [x] T4 main spec 中舊 model 名稱已全部清除
  > 指令：`grep -cE "glm-5-turbo|glm-5\.1|GLM-4\.5-Air" openspec/specs/glm-dynamic-model-display/spec.md`
  > 預期：輸出 `0`

## 實作

- [x] 1.1 更新 claude-glm script model 環境變數（→ T1, T2, T3）
  - `ANTHROPIC_DEFAULT_OPUS_MODEL` 改為 `glm-5.2[1m]`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL` 改為 `glm-5.2[1m]`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL` 改為 `glm-4.5-air`
  - 新增 `CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"`
  - 更新 header 註解中的 model 說明

- [x] 1.2 更新 openspec/specs/glm-dynamic-model-display/spec.md 範例（→ T4）
  - Sonnet/Opus scenario 範例：`glm-5-turbo`/`glm-5.1` → `glm-5.2[1m]`
  - display_name 包含 "glm" scenario 範例：`glm-5-turbo` → `glm-5.2[1m]`
  - 最後一個 scenario 範例：`glm-5-turbo` → `glm-5.2[1m]`
  - Haiku scenario 範例：`GLM-4.5-Air` → `glm-4.5-air`
