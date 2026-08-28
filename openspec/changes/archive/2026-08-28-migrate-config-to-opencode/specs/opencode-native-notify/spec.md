# Delta Spec: opencode-native-notify

## MODIFIED Requirements

### Requirement: 通知 scripts 與 claude 設定零相依
`dotfiles/opencode/scripts/notify-stop.sh` 與 `notify-waiting.sh` SHALL 為獨立檔案（僅依賴 `$TMUX` / `$TMUX_PANE` 環境變數與 tmux 指令），不讀取 stdin、不參照 `~/.claude/` 任何路徑。

#### Scenario: scripts 為獨立檔案
- **WHEN** 查看 `dotfiles/opencode/scripts/` 目錄
- **THEN** 存在 `notify-stop.sh` 與 `notify-waiting.sh` 一般檔案（非 symlink）
- **THEN** 內容不含 `~/.claude` 或 `claude/scripts` 路徑參照

## ADDED Requirements

### Requirement: tmux status bar 格式
tmux 的 `window-status-format` SHALL 讀取 `@claude_state` window option，條件式渲染對應指示符：`@claude_state` 為 `"done"` 時顯示綠色 `✓`，為 `"waiting"` 時顯示綠色 `?`，其餘不顯示任何額外字元。

#### Scenario: @claude_state 為 done 時顯示 ✓
- **WHEN** window 的 `@claude_state` 為 `"done"`
- **THEN** window bar 顯示 `#I:#W✓`，其中 `✓` 使用 colour46（亮綠色）

#### Scenario: @claude_state 為 waiting 時顯示 ?
- **WHEN** window 的 `@claude_state` 為 `"waiting"`
- **THEN** window bar 顯示 `#I:#W?`，其中 `?` 使用 colour46（亮綠色）

#### Scenario: @claude_state 為空時不顯示額外字元
- **WHEN** window 的 `@claude_state` 為 `""` 或未設定
- **THEN** window bar 顯示 `#I:#W`，無任何附加字元

### Requirement: 切換到 window 時自動清除指示符
使用者切換到帶有 `✓` 或 `?` 指示符的 window 時，tmux `after-select-window` hook SHALL 將該 window 的 `@claude_state` 設為 `""`，window bar 不再顯示指示符。

#### Scenario: 切換視窗時自動清除
- **WHEN** 使用者切換到任何 tmux window
- **THEN** tmux `after-select-window` hook 將該 window 的 `@claude_state` 設為 `""`
- **THEN** window bar 不顯示 `✓` 或 `?`

### Requirement: 通知不改變 window 名稱
通知 scripts 與 `after-select-window` hook SHALL NOT 在通知或清除過程中修改 tmux window 名稱。

#### Scenario: 通知後 window 名稱不變
- **WHEN** opencode session 完成觸發 `notify-stop.sh`
- **THEN** window 名稱與 script 執行前完全相同
