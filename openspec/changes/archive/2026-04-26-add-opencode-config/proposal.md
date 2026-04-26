## Why

目前 dotfiles 只透過 symlink 管理 opencode 的 `commands/` 目錄，但 `opencode.json`（主設定、plugin 宣告）和 `package.json`（plugin SDK 依賴）是普通檔案，未納入版本控制。新機器建置時無法自動還原 opencode 的設定與 plugin 清單。

## What Changes

- 新增 `opencode/` 目錄，包含 `opencode.json` 和 `package.json`
- Makefile `opencode` target 新增 symlink 這兩個檔案到 `~/.config/opencode/`
- Makefile `check` 和 `uninstall` target 對應新增驗證與清理邏輯
- `docs/SETUP.md` 步驟 7 新增說明：opencode plugin（`@slkiser/opencode-quota`）在首次啟動時自動下載

## Capabilities

### New Capabilities

- `opencode-config-files`: dotfiles 管理 `opencode/opencode.json` 與 `opencode/package.json`，透過 Makefile symlink 到 `~/.config/opencode/`

### Modified Capabilities

- `opencode-commands-symlink`: Makefile `opencode` target 範圍擴展，除 `commands/` 外也管理 `opencode.json` 與 `package.json` 的 symlink；`check` 和 `uninstall` target 對應更新
- `setup-guide`: SETUP.md 步驟 7 新增 plugin 自動安裝說明

## Impact

- `opencode/` 目錄（新增）
- `Makefile`（修改 `opencode`、`check`、`uninstall` target）
- `docs/SETUP.md`（修改步驟 7）
