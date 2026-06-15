## Context

`claude-glm` 是一個 wrapper script，透過設定環境變數（`ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL`）讓 Claude Code 使用 Z.AI GLM API。目前設定的是 `glm-5.1`（Opus）和 `glm-5-turbo`（Sonnet），這兩個已被 `glm-5.2[1m]` 取代。

## Goals / Non-Goals

**Goals:**
- 將 Opus/Sonnet tier 切換至 `glm-5.2[1m]`（官方建議，含 1M context）
- 啟用 `CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000` 以配合 1M context
- 統一 Haiku model 名稱為官方小寫 `glm-4.5-air`
- 更新 spec 範例以反映新 model 名稱

**Non-Goals:**
- 不修改 statusline 邏輯（動態讀取環境變數，不需改動）
- 不修改 quota polling 邏輯

## Decisions

### `[1m]` suffix 放入環境變數值

`ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.2[1m]"` — 值為純字串，shell 不會對 `[1m]` 做 glob 展開（只有在 pathname 展開情境才會），傳給 Claude Code 後照原樣送出，與 API 預期一致。

### Opus 和 Sonnet 使用同一個 model

官方已統一 Sonnet/Opus 都對應 `glm-5.2[1m]`，不再有層級區分。保留兩個環境變數設定（而非移除一個）是因為 Claude Code 仍需要兩者都設定。

### `CLAUDE_CODE_AUTO_COMPACT_WINDOW` 放進 script

此設定只對 GLM 1M context 有意義，放進 `claude-glm` script（而非全域 `settings.json`），避免影響 native claude session。

## Risks / Trade-offs

- `[1m]` 在 API model name 中是非標準字元 → 官方文件明確列出此格式，風險低
- Haiku 改小寫 (`glm-4.5-air`) → API 若 case-sensitive 可能影響 Haiku tier，但官方文件如此寫，跟隨官方
