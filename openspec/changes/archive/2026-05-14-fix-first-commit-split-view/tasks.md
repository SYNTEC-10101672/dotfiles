## 測試

- [x] T1 First commit 情況下開啟 split view
  > 指令：在 git repo 中找一個 first commit 引入的檔案，游標移到該檔案的任一行，按下 `<leader>hv`
  > 預期：nvim 開啟 vertical split diff，左側為空 buffer，右側為 `hash:file` blob，所有行標示為綠色（新增）

- [x] T2 一般 commit 情況不受影響
  > 指令：游標移到一個非 first commit 引入的行，按下 `<leader>hv`
  > 預期：行為與修改前相同，左側顯示 `hash^` 版本，右側顯示 `hash` 版本

- [x] T3 未 commit 的行仍顯示警告
  > 指令：新增一行但不 commit，游標移到該行，按下 `<leader>hv`
  > 預期：顯示警告「Line not committed yet」，不開啟 diff

## 實作

- [x] 1.1 修改 `blame_commit_diff` 中的 first commit 處理邏輯（→ T1）

  將 `nvim/lua/config/git.lua` 中 first commit 的 early return 替換為：
  1. `Gedit hash:git_rel` 開啟 blob
  2. `diffthis` 標記右側
  3. `leftabove vnew` 建空 buffer
  4. `setlocal buftype=nofile bufhidden=wipe noswapfile`
  5. `diffthis` 標記左側
  6. `wincmd p` 回到右側 blob
