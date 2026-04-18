## 1. 重新命名目錄

- [x] 1.1 執行 `git mv .nvim nvim` 將目錄重新命名

## 2. 更新 Makefile

- [x] 2.1 `nvim` target：將 `ln -sf $(ROOT_DIR)/.nvim` 改為 `ln -sf $(ROOT_DIR)/nvim`
- [x] 2.2 `nvim` target：將 echo 訊息中的 `~/.dotfiles/.nvim/` 改為 `dotfiles/nvim/`
- [x] 2.3 `check` target：將 echo 訊息中的 `.nvim/init.lua` 改為 `nvim/init.lua`

## 3. 更新已部署的 Symlink

- [x] 3.1 執行 `make nvim` 重建 `~/.config/nvim` symlink，指向新路徑
- [x] 3.2 執行 `make check` 確認 symlink 狀態正確
