## Context

目前 dotfiles 的剪貼簿整合透過兩個機制運作：

1. **tmux copy mode**：`.tmux.conf` 使用 `set-clipboard on` + `terminal-overrides` 讓 tmux 在複製時送出 OSC 52 給外層終端
2. **neovim yank**：`clipboard.lua` 偵測是否在 tmux 內，分別送出 DCS-wrapped 或純 OSC 52 sequence，寫入 `/dev/tty`

在 Windows Terminal + PowerShell + SSH 環境下，兩者都正常運作。在 iPad + Blink Shell + SSH + tmux 環境下，兩者都失敗：
- `set-clipboard on` 路徑送出的是原始 OSC 52（非 DCS-wrapped），Blink 需要 DCS-wrapped 格式才能接收
- `/dev/tty` 在 SSH+tmux 下無法正常開啟，neovim 的 OSC 52 輸出靜默失敗

實測：`allow-passthrough on` 本身不足以讓 `copy-selection-and-cancel` 的 `set-clipboard on` 路徑相容 Blink。根本原因是 tmux 的 `Ms` capability 送出的是未包裝的 OSC 52，而 Blink 在 tmux 環境下需要 DCS-wrapped 格式。

## Goals / Non-Goals

**Goals:**
- tmux copy mode（`y` 鍵）在 iPad/Blink 和 Windows Terminal 兩種環境都能複製到系統剪貼簿
- neovim yank 在兩種環境都能複製到系統剪貼簿
- 修改最小化，不引入外部 script 或依賴

**Non-Goals:**
- 支援 macOS 本機環境（pbcopy 等）
- 支援非 SSH 的本機 tmux 使用情境
- 引入外部 script 或額外 binary

## Decisions

### 決策 1：使用 `copy-pipe-and-cancel` inline 方式送出 DCS-wrapped OSC 52

**選擇**：將 `y` binding 改為 `copy-pipe-and-cancel`，inline 構造 DCS-wrapped OSC 52 並寫入 `#{pane_tty}`。同時保留 `allow-passthrough on`。

```tmux
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel \
  "base64 -w0 | xargs -I{} printf '\\033Ptmux;\\033\\033]52;c;{}\\007\\033\\\\' > '#{pane_tty}'"
```

**原始假設**：`allow-passthrough on` 單獨就足以讓 tmux copy mode 穿透至 Blink。

**實測結果**：假設不成立。`set-clipboard on` 走的是 `Ms` terminfo capability 路徑，tmux 自己送出原始 OSC 52 給外層終端。這條路不受 `allow-passthrough` 影響，且 Blink 需要 DCS-wrapped 格式才能在 tmux 環境下接收 OSC 52。

**替代方案 A**：外部 script（`~/.local/bin/tmux-yank`）。更易讀，但需要額外管理檔案路徑與 symlink。

**替代方案 B**：修改 `terminal-overrides` 的 `Ms` 格式為 DCS-wrapped。理論上可行，但非標準用法，難以驗證與維護。

**選擇 inline 的理由**：不引入外部依賴，binding 自足，修改範圍限定在 `.tmux.conf`。Windows Terminal 支援 DCS-wrapped OSC 52（有 `allow-passthrough on`），兩個環境相容。

### 決策 2：將 neovim 的 OSC 52 輸出改為 `io.stdout`

**選擇**：將 `clipboard.lua` 中 `io.open('/dev/tty', 'w')` 改為 `io.stdout:write()` + `io.stdout:flush()`。

**替代方案**：嘗試 fallback 邏輯（先試 `/dev/tty`，失敗再用 `io.stdout`）。

**理由**：在 SSH 環境下，程式的 stdout 直接連接到 SSH channel，終端（Blink 或 Windows Terminal）都從這條流接收 escape sequence。`io.stdout` 比 `/dev/tty` 更適合 SSH 遠端情境，且行為更一致。不需要 fallback，直接改更簡單。

## Risks / Trade-offs

- **[Risk] `allow-passthrough on` 允許 pane 內程式送任意 escape sequence 至外層終端** → 已知的 tmux 安全考量；在受信任的工作環境（公司 server + 個人 iPad）下可接受。
- **[Risk] `io.stdout` 在非 SSH 本機環境可能行為不同** → 目前設定已限定在 SSH 使用情境，本機不走這套邏輯（`TMUX` env var 偵測邏輯已在 `clipboard.lua` 中）。

## Migration Plan

1. 修改 `.tmux.conf`，加入 `allow-passthrough on`
2. 修改 `.tmux.conf`，更新 `y` binding 為 `copy-pipe-and-cancel` inline 方式
3. 修改 `clipboard.lua`，替換輸出方式
4. 在 server 上執行 `tmux source ~/.tmux.conf` 或重啟 tmux 使設定生效
5. 在 neovim 中重新載入設定（`:source` 或重啟）
6. 驗證：在 iPad 和 Windows 兩個環境分別測試 tmux copy mode 與 neovim yank

**Rollback**：還原兩個檔案的修改即可，無 schema migration 或外部狀態。
