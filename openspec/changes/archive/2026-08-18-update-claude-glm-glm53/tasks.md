## 測試

- [x] T1 Opus/Sonnet model 已更新為 glm-5.3[1m]
  > 指令：`grep -E "ANTHROPIC_DEFAULT_(OPUS|SONNET)_MODEL" claude/scripts/claude-glm`
  > 預期：兩行都包含 `glm-5.3[1m]`，不含 `glm-5.2`

- [x] T2 Haiku model 已更新為 glm-5-turbo
  > 指令：`grep ANTHROPIC_DEFAULT_HAIKU_MODEL claude/scripts/claude-glm`
  > 預期：輸出包含 `glm-5-turbo`，不含 `glm-4.5-air`

- [x] T3 CLAUDE_CODE_AUTO_COMPACT_WINDOW 維持 1000000
  > 指令：`grep CLAUDE_CODE_AUTO_COMPACT_WINDOW claude/scripts/claude-glm`
  > 預期：輸出包含 `"1000000"`

- [x] T4 main spec 中舊 model 名稱已全部清除
  > 指令：`grep -cE "glm-5\.2|glm-4\.5-air" openspec/specs/glm-dynamic-model-display/spec.md`
  > 預期：輸出 `0`

- [x] T5 煙霧測試：claude-glm 可用新 model 完成一次對話
  > 指令：`claude-glm -p "Reply with exactly: pong"`
  > 預期：輸出包含 `pong`（證實 API 接受新 model 配置）

## 實作

- [x] 1.1 更新 claude-glm script model 環境變數與註解（→ T1, T2, T3）
  - `ANTHROPIC_DEFAULT_OPUS_MODEL` 改為 `glm-5.3[1m]`
  - `ANTHROPIC_DEFAULT_SONNET_MODEL` 改為 `glm-5.3[1m]`
  - `ANTHROPIC_DEFAULT_HAIKU_MODEL` 改為 `glm-5-turbo`
  - `CLAUDE_CODE_AUTO_COMPACT_WINDOW="1000000"` 維持不變
  - 更新 header 註解（L19-20、L49）中的 model 說明

- [x] 1.2 更新 openspec/specs/glm-dynamic-model-display/spec.md 範例（→ T4）
  - 8 處 `glm-5.2[1m]` → `glm-5.3[1m]`（「動態解析」requirement 6 處、「前綴格式簡化」requirement 2 處）
  - Haiku scenario 2 處：`glm-4.5-air` → `glm-5-turbo`（L28、L29）

- [x] 1.3 執行煙霧測試（→ T5）
