# iPad Blink Shell + tmux + Neovim 剪貼簿整合

## 目標

讓在遠端 server（透過 SSH）使用 tmux/neovim 時，能將內容複製到 iPad 的系統剪貼簿。

## 環境

- 客戶端：iPad + Blink Shell
- 連線方式：SSH
- 遠端：Linux server，使用 tmux 3.3+、neovim 0.9+

## 原理

Blink Shell 支援 OSC 52 escape sequence（終端機剪貼簿協定）。當程式在 tmux 內時，OSC 52 需要用 tmux DCS 格式包裝才能穿透：

```
\033Ptmux;\033\033]52;c;<base64>\007\033\
```

neovim 無法存取 `/dev/tty`（在 SSH+tmux 環境下），需改用 `io.stdout` 寫入。

---

## 實作步驟

### 1. `~/.tmux.conf` — 加入兩個選項

在 `set-clipboard on` 下方加入 `allow-passthrough on`：

```tmux
set -g set-clipboard on
set -g allow-passthrough on
```

同時修改 copy mode 的 `y` binding，改用 pipe 方式：

```tmux
# 修改前：
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# 修改後：
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "~/.local/bin/tmux-yank > #{pane_tty}"
```

### 2. 建立 `~/.local/bin/tmux-yank`

```bash
#!/bin/bash
# Read from stdin, send via OSC 52 DCS-wrapped for tmux
encoded=$(base64 -w0)
printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$encoded"
```

```bash
chmod +x ~/.local/bin/tmux-yank
```

### 3. Neovim `clipboard.lua` — 修改寫入方式

原本程式碼使用 `io.open('/dev/tty', 'w')`，在此環境下會失敗。改為 `io.stdout`：

```lua
-- 修改前：
local tty = io.open('/dev/tty', 'w')
if tty then
    tty:write(osc52_sequence)
    tty:close()
end

-- 修改後：
io.stdout:write(osc52_sequence)
io.stdout:flush()
```

完整的 `osc52_yank()` 函式（供參考）：

```lua
local function osc52_yank()
  local content = vim.fn.getreg('0')
  local base64_content = vim.fn.system('base64 -w0', content)
  base64_content = vim.fn.substitute(base64_content, '\n$', '', '')

  local osc52_sequence
  if vim.env.TMUX ~= nil and vim.env.TMUX ~= '' then
    osc52_sequence = string.format('\x1bPtmux;\x1b\x1b]52;c;%s\x07\x1b\\', base64_content)
  else
    osc52_sequence = string.format('\x1b]52;c;%s\x07', base64_content)
  end

  io.stdout:write(osc52_sequence)
  io.stdout:flush()
end
```

---

## 驗證

### 診斷指令（確認整條鏈是否通）

```bash
# 1. 不在 tmux — 確認 Blink OSC 52 支援
printf "\033]52;c;Y29weXBhc3RhIQ==\a"
# 去備忘錄貼，應出現 "copypasta!"

# 2. 在 tmux — 確認 allow-passthrough 有效
printf "\033Ptmux;\033\033]52;c;Y29weXBhc3RhIQ==\007\033\\"
# 去備忘錄貼，應出現 "copypasta!"
```

### 確認 tmux 設定生效

```bash
tmux show-options -g allow-passthrough   # → allow-passthrough on
tmux show-options -g set-clipboard       # → set-clipboard on
```

---

## 注意事項

- `base64 -w0` 是 Linux（GNU coreutils）專用，macOS 需改為 `base64`
- 此設定對 Windows Terminal + SSH 也有效（Windows Terminal 支援 OSC 52）
- tmux 版本需 3.3+（`allow-passthrough` 是 3.3 加入的功能）
