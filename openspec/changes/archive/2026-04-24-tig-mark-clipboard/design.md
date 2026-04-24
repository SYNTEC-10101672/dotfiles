## Context

目前 `scripts/tig-mark-commit.sh` 的 `mark` action 會將 commit hash 寫入 `/tmp/tig-marked-commit-${USER}` 並顯示確認訊息，但無法自動複製到 clipboard。使用環境為 headless Linux，透過 SSH 從 Windows Terminal 或 iPad Blink 連入，沒有 X11/Wayland，但有 OSC 52 clipboard 支援。

## Goals / Non-Goals

**Goals:**
- 按下 M 標記 commit 時自動複製 commit hash 到 local clipboard
- 使用 OSC 52 escape sequence，相容於支援此協議的 terminal
- 在 `status` action 中也提供 clipboard 複製功能

**Non-Goals:**
- 不處理不支援 OSC 52 的 terminal 的 fallback（靜默跳過即可）
- 不新增外部依賴（`base64` 為系統內建）
- 不修改 `.tigrc` 的 keybinding

## Decisions

**1. 使用 OSC 52 而非 `xclip`/`wl-copy`**

環境沒有 display server，`xclip` 等工具無法運作。OSC 52 是純 escape sequence，直接寫入 stdout 由 terminal 處理，零外部依賴。

**2. `copy_to_clipboard` 為獨立 function**

將 clipboard 邏輯封裝為 function，方便未來擴充或複用。function 內容為 `printf '\033]52;c;%s\a' "$(printf '%s' "$1" | base64 -w0)"`。

**3. 不做 fallback 提示**

不支援 OSC 52 的 terminal 看不到效果但不會報錯，靜默跳過比印出警告訊息更乾淨。

## Risks / Trade-offs

- [部分 terminal 不支援 OSC 52] → 不影響現有功能，只是 clipboard 不會被寫入，commit 標記功能仍正常運作
- [base64 編碼在極少數系統可能需要 `-w 0` 而非 `-w0`] → 兩種寫法差異極小，GNU coreutils（Ubuntu 預設）支援 `-w0`
