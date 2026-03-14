## Context

目前 `.tmux.conf` 啟用 `mouse on`，提供滾輪捲動和滑鼠選 pane。但在不支援 OSC 52 的環境下，mouse mode 會攔截 terminal 原生選取，導致無法複製。需要一個快速切換機制。

## Goals / Non-Goals

**Goals:**
- 一鍵 toggle mouse mode，操作直覺
- 切換時有明確的視覺回饋
- 不引入外部依賴

**Non-Goals:**
- 不做環境自動偵測（偵測 OSC 52 支援度）
- 不做 status bar 常駐狀態指示（`display-message` 暫時提示即可）
- 不處理 `allow-passthrough` 方案

## Decisions

### 1. 使用 `set -g mouse` toggle（而非 per-session）

全域切換，確保所有 window/pane 一致。單一環境通常只有一種 terminal，不需要 per-session 控制。

### 2. 快捷鍵選擇 `Ctrl-b M`

- `M` = Mouse，語意直覺
- 大寫 `M` 避免與 `m`（未使用但保留空間）衝突
- 已確認 `.tmux.conf` 中 `M` 未被佔用（現有 `M-Left/Right/Up/Down` 是 Alt+方向鍵，不衝突）

### 3. 使用 `display-message` 而非 status bar 常駐顯示

- 簡單，一行搞定
- 切換頻率低，不需要常駐佔用 status bar 空間
- 未來如果需要可以加，但目前 YAGNI

## Risks / Trade-offs

- **忘記切回 on** → 滾輪和 pane 點選暫時失效。影響低，再按一次 `Ctrl-b M` 即可恢復。
- **display-message 一閃而過** → 如果沒注意到可能不確定當前狀態。可用 `tmux show -g mouse` 手動確認，或未來加 status bar 指示。
