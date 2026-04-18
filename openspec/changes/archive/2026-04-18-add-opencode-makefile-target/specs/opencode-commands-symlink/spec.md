## ADDED Requirements

### Requirement: opencode Makefile target 建立 commands symlink
`make opencode` SHALL 建立 `~/.config/opencode/commands` symlink，指向 `dotfiles/claude/commands`。目錄 `~/.config/opencode/` 若不存在 SHALL 自動建立。

#### Scenario: 首次安裝
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/` 不存在
- **THEN** 建立 `~/.config/opencode/` 目錄，並建立 `~/.config/opencode/commands` → `dotfiles/claude/commands` symlink

#### Scenario: 已存在 symlink
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/commands` 已是 symlink
- **THEN** 更新 symlink 指向正確路徑（force replace）

### Requirement: opencode target 整合到 install 流程
`make install` SHALL 包含 `opencode` target 作為依賴。

#### Scenario: 完整安裝
- **WHEN** 執行 `make install`
- **THEN** opencode target 被執行，commands symlink 被建立

### Requirement: check target 驗證 opencode symlink
`make check` SHALL 顯示 opencode commands symlink 的狀態。

#### Scenario: symlink 正確
- **WHEN** 執行 `make check` 且 `~/.config/opencode/commands` 正確指向 `dotfiles/claude/commands`
- **THEN** 顯示 `✓` 狀態

#### Scenario: symlink 不存在
- **WHEN** 執行 `make check` 且 `~/.config/opencode/commands` 不存在
- **THEN** 顯示 `✗` 狀態

### Requirement: uninstall target 清理 opencode symlink
`make uninstall` SHALL 移除 `~/.config/opencode/commands` symlink。

#### Scenario: symlink 存在
- **WHEN** 執行 `make uninstall` 且 `~/.config/opencode/commands` symlink 存在
- **THEN** 移除該 symlink

#### Scenario: symlink 不存在
- **WHEN** 執行 `make uninstall` 且 `~/.config/opencode/commands` 不存在
- **THEN** 不報錯，繼續執行

### Requirement: help 顯示 opencode target
`make help` SHALL 包含 opencode target 的說明。

#### Scenario: 查看說明
- **WHEN** 執行 `make help`
- **THEN** 輸出包含 `make opencode` 說明行
