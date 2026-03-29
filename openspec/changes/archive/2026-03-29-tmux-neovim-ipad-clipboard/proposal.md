## Why

tmux copy mode 和 neovim yank 在 iPad + Blink Shell + SSH 環境下無法複製到系統剪貼簿，根本原因是 tmux 預設不允許 OSC 52 escape sequence 穿透，且 neovim 在 SSH+tmux 環境下無法開啟 `/dev/tty`。需要在維持 Windows Terminal + PowerShell 現有功能的前提下，讓兩個環境都能正常複製。

## What Changes

- `.tmux.conf`: 新增 `set -g allow-passthrough on`，允許 pane 內的程式將 escape sequence 穿透至外層終端
- `.tmux.conf`: 修改 copy mode `y` binding，改用 `copy-pipe-and-cancel` 送出 DCS-wrapped OSC 52，確保 Blink 能接收
- `.nvim/lua/config/clipboard.lua`: 將 `io.open('/dev/tty', 'w')` 改為 `io.stdout`，確保在 SSH+tmux 環境下能正確輸出 OSC 52 sequence

## Capabilities

### New Capabilities

- `clipboard-ipad-compat`: 跨終端環境（iPad/Blink + Windows Terminal）的剪貼簿相容層，讓 tmux copy mode 與 neovim yank 在兩種 SSH 環境下都能運作

### Modified Capabilities

（無 spec-level 行為變更）

## Impact

- `.tmux.conf` — 新增 `allow-passthrough on` 設定、修改 `y` binding
- `.nvim/lua/config/clipboard.lua` — 修改 OSC 52 輸出方式
- 不影響現有 Windows Terminal + PowerShell 功能（Windows Terminal 支援 DCS-wrapped OSC 52 + `allow-passthrough on` 已設定）
- 不需要外部 script 或額外 binary（binding 改為 inline 方式）
