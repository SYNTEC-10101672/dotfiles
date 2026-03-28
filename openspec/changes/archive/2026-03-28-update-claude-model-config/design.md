## 背景

目前 `claude-glm` 腳本將 opus/sonnet tier 都對應到 `GLM-4.7`，並以靜態變數 `CLAUDE_PROXY_MODEL="GLM-4.7"` 提供給 statusline 顯示。GLM 5 系列已推出，模型定位更清晰：`glm-5.1` 對應高品質任務（opus tier）、`glm-5-turbo` 對應一般任務（sonnet tier）。

`settings.json` 中的 `"model": "opusplan"` 使 plan mode 自動升級為 opus，在 GLM 環境下代表會自動切換到成本較高的 `glm-5.1`，但使用者預期維持 sonnet tier。

statusline 目前顯示冗長前綴（`Claude Code Native (...)` / `Claude Code GLM: ...`），可簡化。

## 目標 / 非目標

**目標：**
- 更新 claude-glm 的 model 對應為 GLM 5 系列
- 移除 plan mode 自動升 opus 行為
- statusline 動態顯示實際使用的 GLM model 名稱
- 簡化 statusline 前綴格式

**非目標：**
- 修改 haiku tier 對應（`GLM-4.5-Air` 維持不變）
- 修改 `ANTHROPIC_BASE_URL` 或其他 proxy 設定
- 支援多個 GLM proxy 並存

## 決策

### D1：動態 model 名稱的解析位置

**決策：在 `claude-code-statusline` 腳本內解析，而非在 `claude-glm` 啟動時決定。**

rationale：statusline 每次更新時都會收到 JSON input，其中包含 `model.display_name`（如 `Claude Sonnet 4.6`）。若在啟動時解析，mid-session 切換 model（`/model` 指令）後顯示會過時。在 statusline 內解析可確保每次刷新都反映當前實際 tier。

替代方案：啟動時讀取 `settings.json` 決定 tier → 不支援 mid-session 切換，捨棄。

### D2：model tier 對應方式

**決策：用 `model.display_name` 做 case-insensitive substring match 判斷 tier，再查對應的 `ANTHROPIC_DEFAULT_*` 環境變數。**

```
display_name contains "opus"   → $ANTHROPIC_DEFAULT_OPUS_MODEL
display_name contains "sonnet" → $ANTHROPIC_DEFAULT_SONNET_MODEL
display_name contains "haiku"  → $ANTHROPIC_DEFAULT_HAIKU_MODEL
無法對應                        → "GLM"（fallback）
```

替代方案：hardcode model 名稱對照表 → 每次 GLM model 更新都需改 statusline，彈性較差，捨棄。

### D3：statusline 前綴格式

**決策：**
- Native 模式：`[<display_name>]`（直接顯示 Claude 回傳的 model 名稱）
- GLM 模式：`[GLM <resolved-model-name>]`

rationale：保留 `GLM` 標記讓使用者一眼辨識 proxy 模式，其餘去除冗餘文字。

### D4：`CLAUDE_PROXY_MODEL` 環境變數的處理

**決策：從 `claude-glm` 腳本中移除 `CLAUDE_PROXY_MODEL` 靜態設定，改由 statusline 動態解析。**

`CLAUDE_PROXY_MODE="glm"` 仍保留，作為 statusline 判斷是否進入 GLM 顯示邏輯的 flag。

## 風險 / 取捨

- **`model.display_name` 格式變動** → 若 Claude 更新 model 顯示名稱格式（不含 "sonnet"/"opus"），fallback 為 "GLM"，不會 crash，但顯示資訊減少。緩解：substring match 容錯性高，可接受。
- **`ANTHROPIC_DEFAULT_*` 未設定** → 若 env var 為空，fallback 為 "GLM"。緩解：`claude-glm` 腳本已確保設定這些變數。

## 遷移計畫

1. 修改 `claude-glm` 腳本：更新 model 值、移除靜態 `CLAUDE_PROXY_MODEL`
2. 修改 `claude-code-statusline`：實作動態 model 解析、更新前綴格式
3. 修改 `settings.json`：`opusplan` → `sonnet`

無需 rollback 策略，所有變更均為設定/腳本，可直接 revert。

## 待解問題

（無）
