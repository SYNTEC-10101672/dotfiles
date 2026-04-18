## Why

`.nvim/` 使用隱藏目錄命名，與同層的 `claude/`、`scripts/` 等明確命名的目錄風格不一致。統一改為無前綴的 `nvim/`，讓 dotfiles repo 的目錄結構更整齊。

## What Changes

- 將 `dotfiles/.nvim/` 重新命名為 `dotfiles/nvim/`
- 更新 Makefile `nvim` target：symlink 來源從 `.nvim` 改為 `nvim`
- 更新 Makefile `check` target：echo 訊息中的路徑從 `.nvim/` 改為 `nvim/`
- 更新 Makefile `nvim` target：備註訊息從 `~/.dotfiles/.nvim/` 改為 `dotfiles/nvim/`

## Capabilities

### New Capabilities

（無新增 capability）

### Modified Capabilities

（無 spec-level 行為變更，純屬重新命名與 Makefile 調整）

## Impact

- **dotfiles repo 目錄結構**：`.nvim/` → `nvim/`
- **Makefile**：三處字串異動
- **部署後的 symlink**：`~/.config/nvim` 指向路徑需更新（舊 symlink 需移除後重新 `make nvim`）
- 不影響任何 neovim 功能或設定內容
