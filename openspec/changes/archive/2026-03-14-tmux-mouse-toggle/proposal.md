## Why

多個環境共用同一份 `.tmux.conf`，但並非所有環境都支援 OSC 52 剪貼簿。啟用 `mouse on` 時，tmux 會攔截 terminal 原生的文字選取，導致在沒有 OSC 52 的環境（特別是 iPad + Termius）無法複製內容。需要一個快速切換機制，暫時關閉 mouse 來使用原生選取。

## What Changes

- 新增快捷鍵 `Ctrl-b M`，全域 toggle `mouse` 開關
- 切換時透過 `display-message` 顯示目前狀態

## Capabilities

### New Capabilities
- `mouse-toggle`: 快捷鍵切換 tmux mouse mode，附帶視覺回饋

### Modified Capabilities
<!-- 無 — 不影響現有 specs -->

## Impact

- `.tmux.conf`：在 Key Bindings 區段新增一行 `bind`
- 無外部依賴、無 breaking changes
