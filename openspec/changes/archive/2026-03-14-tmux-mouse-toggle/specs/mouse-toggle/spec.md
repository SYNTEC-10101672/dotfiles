## ADDED Requirements

### Requirement: 快捷鍵切換 mouse mode
使用者 SHALL 能透過 `Ctrl-b M` 切換 tmux 全域 mouse mode 開關。當 mouse 為 on 時切換為 off，反之亦然。

#### Scenario: 從 on 切換為 off
- **WHEN** mouse mode 為 on，使用者按下 `Ctrl-b M`
- **THEN** mouse mode SHALL 切換為 off，terminal 原生文字選取恢復可用

#### Scenario: 從 off 切換回 on
- **WHEN** mouse mode 為 off，使用者按下 `Ctrl-b M`
- **THEN** mouse mode SHALL 切換為 on，滾輪捲動和滑鼠選 pane 恢復可用

### Requirement: 切換時顯示狀態回饋
切換 mouse mode 時 SHALL 透過 `display-message` 顯示目前狀態，讓使用者確認切換結果。

#### Scenario: 顯示 ON 狀態
- **WHEN** mouse mode 切換為 on
- **THEN** SHALL 顯示包含 "ON" 的訊息

#### Scenario: 顯示 OFF 狀態
- **WHEN** mouse mode 切換為 off
- **THEN** SHALL 顯示包含 "OFF" 的訊息
