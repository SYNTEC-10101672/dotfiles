## Context

`claude-glm` 是一個 wrapper script（`claude/scripts/claude-glm`），透過設定環境變數（`ANTHROPIC_DEFAULT_OPUS_MODEL`、`ANTHROPIC_DEFAULT_SONNET_MODEL`、`ANTHROPIC_DEFAULT_HAIKU_MODEL`）讓 Claude Code 使用 Z.AI GLM API（`https://api.z.ai/api/anthropic`）。目前設定：Opus/Sonnet = `glm-5.2[1m]`、Haiku = `glm-4.5-air`。

本次變更前已完成查證（2026-08-18 實測與官方文件）：

- `GET /v1/models` 確認 `glm-5.3` 已上架（2026-08-14），共 9 個 model
- Raw API 呼叫 `glm-5.3` 回應正常；`glm-5.3[1m]` 與 `glm-5.2[1m]` 打 raw endpoint 都報 `1214 modelCode does not exist`，證實 `[1m]` 是 Claude Code client 端剝解的 context variant 指令，不會原樣送給 API
- `glm-4.5-air` 仍在 model list，但實際回應的 `model` 欄位為 `glm-4.7`（已被 alias）
- Latency 實測（`max_tokens=32`，單次）：`glm-5-turbo` 0.82s、`glm-4.7` 1.68s、`glm-4.7-flashx` 0.46s
- 官方 Claude Code 文件（docs.z.ai/devpack/latest-model）：Opus/Sonnet 用 `glm-5.3[1m]`，GLM-5.3 支援 1M context / 128K max output，无需 beta header

## Goals / Non-Goals

**Goals:**

- Opus/Sonnet tier 切換至 `glm-5.3[1m]`（1M context）
- Haiku tier 從已退役的 `glm-4.5-air` 換成 `glm-5-turbo`
- 同步更新 `glm-dynamic-model-display` spec 的 model 名稱範例

**Non-Goals:**

- 不改 statusline 顯示邏輯（`claude-code-statusline` 動態解析 `CLAUDE_PROXY_MODEL`，與 model 名稱無耦合）
- 不改 quota 輪詢、tmux rename、timeout 等其他 wrapper 行為
- 不採用 `glm-4.7-flashx`（雖最快，但非官方 Claude Code mapping，品質未驗證）

## Decisions

1. **Opus/Sonnet = `glm-5.3[1m]`**：沿用官方 Claude Code 建議格式。`[1m]` suffix 由 Claude Code client 端處理（对照組：raw `glm-5.3` 已實測可用，suffix 機制與 5.2 相同）。`CLAUDE_CODE_AUTO_COMPACT_WINDOW` 維持 `1000000` 配合 1M context。
2. **Haiku = `glm-5-turbo` 而非官方預設 `glm-4.7`**：實測快 2 倍（0.82s vs 1.68s）、與主模型同家族（背景任務輸出行為一致）、且仍在維護的 5.x 系列。`glm-4.7` 為官方文件預設值，作為退路。
3. **維持兩個 tier 環境變數都指向同一 model**：與前次變更（2026-06-15）決策一致，Claude Code 需要 Opus/Sonnet 兩者皆設定。

## Risks / Trade-offs

- [`glm-5-turbo` 品質未在 Haiku tier 實測] → 驗證步驟包含實跑 `claude-glm -p` 煙霧測試；若有問題可單獨改回 `glm-4.7`（單行變更）
- [GLM-5.3 上架 4 天，穩定性未知] → wrapper 環境變數隨 session 生效， rollback 即改回 `glm-5.2[1m]`（單行變更，`glm-5.2` 仍在 model list）
- [`[1m]` suffix 行為依賴 Claude Code client 端處理] → 此機制自 5.2 起已運作兩個月，風險低
