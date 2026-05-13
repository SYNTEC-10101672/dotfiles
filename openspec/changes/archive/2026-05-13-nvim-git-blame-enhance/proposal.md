## Why

目前 nvim 的 git blame 功能（`<leader>gb` / `<leader>hb`）只能看到 commit hash 與日期，無法直接看到 commit message。看到可疑的程式行時，需要手動複製 hash 再查 log，流程繁瑣。此外，確認是哪個 commit 修改後，缺乏快速對該 commit 做 file-level diff 的方式。

## What Changes

- 開啟 gitsigns `current_line_blame`，讓每行 EOL 持續顯示 `author, date - commit message`
- 新增 `<leader>hv` keybinding：取得游標所在行的 blame commit hash，以 vertical split 展開該 commit 對當前檔案的 diff（左：改前，右：改後）

## Capabilities

### New Capabilities

- `nvim-blame-commit-diff`: 在游標所在行取得 blame commit hash，並以 vertical split 顯示該 commit 對當前檔案的前後差異

### Modified Capabilities

（無）

## Impact

- `nvim/lua/config/git.lua`：開啟 `current_line_blame`，新增 `<leader>hv` keybinding 與對應 Lua function
- 依賴已安裝的 `vim-fugitive`（`:Gedit`、`:Gvdiffsplit`）
- 無新增 plugin，無 breaking changes
