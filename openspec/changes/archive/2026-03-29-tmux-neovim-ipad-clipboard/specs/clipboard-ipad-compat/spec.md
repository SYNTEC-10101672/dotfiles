## ADDED Requirements

### Requirement: tmux copy mode works in iPad/Blink environment
tmux 的 `allow-passthrough` 設定 SHALL 啟用，確保 OSC 52 escape sequence 能從 pane 穿透至外層終端（Blink Shell）。

#### Scenario: tmux copy mode in iPad Blink Shell
- **WHEN** 使用者在 iPad + Blink Shell + SSH + tmux 環境下，於 copy mode 按下 `y`
- **THEN** 選取的文字 SHALL 被複製到 iPad 的系統剪貼簿

#### Scenario: tmux copy mode in Windows Terminal
- **WHEN** 使用者在 Windows Terminal + PowerShell + SSH + tmux 環境下，於 copy mode 按下 `y`
- **THEN** 選取的文字 SHALL 被複製到 Windows 的系統剪貼簿（不受 `allow-passthrough` 影響）

### Requirement: neovim yank works in SSH+tmux environment
neovim 的 OSC 52 輸出 SHALL 使用 `io.stdout`，確保在無法存取 `/dev/tty` 的 SSH+tmux 環境下仍能正常輸出 escape sequence。

#### Scenario: neovim yank in iPad Blink Shell
- **WHEN** 使用者在 iPad + Blink Shell + SSH + tmux 環境下，於 neovim 執行 yank 操作
- **THEN** yank 的內容 SHALL 透過 DCS-wrapped OSC 52 被複製到 iPad 的系統剪貼簿

#### Scenario: neovim yank in Windows Terminal
- **WHEN** 使用者在 Windows Terminal + PowerShell + SSH + tmux 環境下，於 neovim 執行 yank 操作
- **THEN** yank 的內容 SHALL 透過 DCS-wrapped OSC 52 被複製到 Windows 的系統剪貼簿

#### Scenario: neovim yank outside tmux
- **WHEN** 使用者在 SSH 環境下（不在 tmux 內），於 neovim 執行 yank 操作
- **THEN** yank 的內容 SHALL 透過純 OSC 52（非 DCS 包裝）被複製到終端的系統剪貼簿
