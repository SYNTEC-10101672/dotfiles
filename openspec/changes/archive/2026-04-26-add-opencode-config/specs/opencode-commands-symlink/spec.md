## MODIFIED Requirements

### Requirement: opencode Makefile target 建立 commands symlink
`make opencode` SHALL 建立 `~/.config/opencode/commands` symlink，指向 `dotfiles/claude/commands`；同時建立 `~/.config/opencode/opencode.json` symlink 指向 `dotfiles/opencode/opencode.json`，以及 `~/.config/opencode/package.json` symlink 指向 `dotfiles/opencode/package.json`。目錄 `~/.config/opencode/` 若不存在 SHALL 自動建立。

#### Scenario: 首次安裝
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/` 不存在
- **THEN** 建立 `~/.config/opencode/` 目錄，並建立所有三個 symlink（commands、opencode.json、package.json）

#### Scenario: 已存在 symlink
- **WHEN** 執行 `make opencode` 且所有 symlink 已存在
- **THEN** 更新所有 symlink 指向正確路徑（force replace，idempotent）
