## Why

`claude-glm` 的 statusline 目前只顯示 model 名稱，無法得知 Z.ai API 的剩餘配額與 reset 時間，導致用戶必須另外查詢才能知道還有多少額度。

## What Changes

- `claude-glm` 啟動時在背景呼叫 Z.ai quota API，將結果快取至 `/tmp/glm-quota-cache.json`
- `claude-code-statusline` 在 GLM 模式下讀取快取，顯示剩餘配額百分比（100% → 0%）與距離 reset 的倒數時間

## Capabilities

### New Capabilities

- `glm-quota-display`: 定義 GLM 模式下配額快取的取得方式，以及 statusline 顯示剩餘配額與 reset 倒數的行為規格

### Modified Capabilities

（無）

## Impact

- `claude/scripts/claude-glm`：新增背景 API fetch 邏輯
- `claude/scripts/claude-code-statusline`：GLM 模式下新增讀取快取並格式化顯示的邏輯
- 新增執行期快取檔案 `/tmp/glm-quota-cache.json`（不納入版本控制）
