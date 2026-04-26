## ADDED Requirements

### Requirement: dotfiles 包含 opencode 設定檔
`dotfiles/opencode/` 目錄 SHALL 包含 `opencode.json` 和 `package.json`，作為 opencode 設定的唯一 source of truth。

#### Scenario: 檔案存在
- **WHEN** 查看 dotfiles repo 的 `opencode/` 目錄
- **THEN** SHALL 存在 `opencode.json`（含 plugin 宣告與 experimental 設定）和 `package.json`（含 plugin SDK 依賴）

### Requirement: opencode 設定檔透過 symlink 部署到 ~/.config/opencode/
`make opencode` SHALL 建立 `~/.config/opencode/opencode.json` → `dotfiles/opencode/opencode.json` 和 `~/.config/opencode/package.json` → `dotfiles/opencode/package.json` 的 symlink。

#### Scenario: 首次安裝
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/opencode.json` 不存在
- **THEN** 建立 symlink `~/.config/opencode/opencode.json` → `dotfiles/opencode/opencode.json`

#### Scenario: 已存在普通檔案
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/opencode.json` 是普通檔案
- **THEN** 以 symlink 覆蓋（`ln -sf`）

#### Scenario: 已存在 symlink
- **WHEN** 執行 `make opencode` 且 `~/.config/opencode/opencode.json` 已是正確 symlink
- **THEN** symlink 維持不變或更新（idempotent）

### Requirement: check target 驗證 opencode 設定檔 symlink
`make check` SHALL 顯示 `~/.config/opencode/opencode.json` 和 `~/.config/opencode/package.json` 的 symlink 狀態。

#### Scenario: symlink 正確
- **WHEN** 執行 `make check` 且兩個 symlink 均正確指向 dotfiles
- **THEN** 各顯示 `✓` 狀態與 target 路徑

#### Scenario: symlink 不存在
- **WHEN** 執行 `make check` 且 symlink 不存在
- **THEN** 顯示 `✗` 狀態

### Requirement: uninstall target 清理 opencode 設定檔 symlink
`make uninstall` SHALL 移除 `~/.config/opencode/opencode.json` 和 `~/.config/opencode/package.json` symlink。

#### Scenario: symlink 存在
- **WHEN** 執行 `make uninstall` 且 symlink 存在
- **THEN** 移除該 symlink

#### Scenario: symlink 不存在
- **WHEN** 執行 `make uninstall` 且 symlink 不存在
- **THEN** 不報錯，繼續執行
