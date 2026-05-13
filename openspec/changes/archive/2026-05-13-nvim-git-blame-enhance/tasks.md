## 測試

- [x] T1 開啟 inline blame 驗證
  > 指令：開啟 dotfiles repo 內任意已追蹤檔案（如 `nvim/lua/config/git.lua`），等待約 1 秒
  > 預期：每行行尾出現虛擬文字，格式為 `author, YYYY-MM-DD - commit message`

- [x] T2 `<leader>hv` 對已 commit 行展開 diff
  > 指令：游標移至任意已 commit 且 parent commit 仍有此檔案的行，按下 `<leader>hv`
  > 預期：nvim 開啟 vertical split，左側為該 commit 的 parent 版本，右側為該 commit 版本，兩側皆為唯讀 fugitive buffer

- [x] T2.1 `<leader>hv` 對首次引入此檔案的 commit 行給予提示
  > 指令：游標移至一個被 blame 到「首次新增該檔案的 commit」的行（如 `.bash_profile` 中被 blame 到 `a97945a` 的行），按下 `<leader>hv`
  > 預期：出現 Info 通知「First commit of this file — no parent to diff against」，不開啟任何 split

- [x] T3 `<leader>hv` 對未 commit 行給予提示
  > 指令：在檔案中新增一行但不 commit，游標移至該行並按下 `<leader>hv`
  > 預期：出現警告通知「Line not committed yet」，不開啟任何 split

## 實作

- [x] 1.1 開啟 `current_line_blame`（→ T1）
  在 `nvim/lua/config/git.lua` 第 28 行將 `current_line_blame = false` 改為 `current_line_blame = true`

- [x] 1.2 新增 `blame_commit_diff` function 與 `<leader>hv` keybinding（→ T2, T3）
  在 `nvim/lua/config/git.lua` 的 `on_attach` 函式內新增：
  - local function `blame_commit_diff()`：用 `vim.fn.system("git blame -L <line>,<line> <file> --porcelain | head -1 | awk '{print $1}'")`  取得 hash，檢查是否為 40 個 0（未 commit），否則依序執行 `:Gedit <hash>:%` 與 `:Gvdiffsplit <hash>^`
  - `map("n", "<leader>hv", blame_commit_diff, { desc = "Blame commit diff" })`
