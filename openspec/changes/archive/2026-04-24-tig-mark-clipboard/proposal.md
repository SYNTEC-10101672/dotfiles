## Why

在 tig 中按下 M 標記 commit 時，只能透過 `Ctrl-M` 查看已標記的 commit hash。若要將 commit hash 貼到其他地方（如 Slack、PR comment、script），需要手動記住並重新輸入。在 headless 環境下沒有 GUI clipboard，但可以透過 OSC 52 escape sequence 讓終端機自動複製到 local clipboard。

## What Changes

- 在 `tig-mark-commit.sh` 新增 `copy_to_clipboard()` function，使用 OSC 52 escape sequence 將 commit hash 寫入 local clipboard
- 在 `mark` action 中呼叫此 function，按下 M 時自動複製 commit hash
- 在 `status` action 中也呼叫此 function，方便快速取用已標記的 commit hash

## Capabilities

### New Capabilities
- `tig-clipboard-copy`: 在 tig mark commit 流程中透過 OSC 52 將 commit hash 複製到 local clipboard

### Modified Capabilities
（無）

## Impact

- `scripts/tig-mark-commit.sh` — 新增 clipboard function，修改 `mark` 和 `status` action
- 無新依賴 — OSC 52 是純 escape sequence，使用系統內建的 `base64` 指令
- 需要 terminal emulator 支援 OSC 52（iTerm2、Windows Terminal、Blink 等主流 terminal 皆有支援）
