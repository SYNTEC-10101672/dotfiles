## Purpose

在 tig 中標記或查看 commit 時，透過 OSC 52 escape sequence 自動將 commit hash 複製到 local clipboard，支援 SSH 遠端開發情境。

## Requirements

### Requirement: Mark commit 時複製到 clipboard
系統 SHALL 在使用者於 tig 中標記 commit（`mark` action）時，透過 OSC 52 escape sequence 將 commit hash 複製到 local clipboard。

#### Scenario: 標記 commit 後 clipboard 包含 commit hash
- **WHEN** 使用者在 tig 中按下 M 標記 commit `abc1234`
- **THEN** 系統將 `abc1234` 寫入 `/tmp/tig-marked-commit-${USER}`
- **AND** 系統透過 OSC 52 escape sequence 將 `abc1234` 發送至 terminal
- **AND** 使用者的 local clipboard 包含 `abc1234`

#### Scenario: 不支援 OSC 52 的 terminal
- **WHEN** 使用者在不支援 OSC 52 的 terminal 中標記 commit
- **THEN** commit 標記功能仍正常運作（寫入檔案、顯示確認訊息）
- **AND** 不產生錯誤訊息

### Requirement: 查看已標記 commit 時複製到 clipboard
系統 SHALL 在使用者查看已標記 commit（`status` action）時，透過 OSC 52 escape sequence 將已標記的 commit hash 複製到 local clipboard。

#### Scenario: 查看已標記 commit 後 clipboard 包含 commit hash
- **WHEN** 使用者在 tig 中按下 Ctrl-M 查看已標記 commit，且已標記的 commit 為 `abc1234`
- **THEN** 系統顯示 "Currently marked commit: abc1234"
- **AND** 系統透過 OSC 52 escape sequence 將 `abc1234` 發送至 terminal
- **AND** 使用者的 local clipboard 包含 `abc1234`

#### Scenario: 尚未標記 commit 時查看 status
- **WHEN** 使用者按下 Ctrl-M 查看已標記 commit，但尚未標記任何 commit
- **THEN** 系統顯示 "No commit marked"
- **AND** 不發送 OSC 52 escape sequence
