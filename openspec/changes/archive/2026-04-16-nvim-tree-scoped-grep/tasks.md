## 1. 修改 telescope.lua 的 FF keymap

- [x] 1.1 將 `FF` 的靜態 keymap 改為 Lua function，加入 `vim.bo.filetype == "NvimTree"` 判斷
- [x] 1.2 在 nvim-tree branch 中，用 `pcall` 載入 `nvim-tree.api`，取得游標節點路徑
- [x] 1.3 處理游標在目錄節點與檔案節點兩種情況，分別取 `absolute_path` 或其父目錄
- [x] 1.4 將目錄路徑傳入 `require("telescope.builtin").live_grep({ search_dirs = { dir } })`
- [x] 1.5 確保 fallback（api 載入失敗或非 nvim-tree buffer）執行全域 `live_grep()`

## 2. 驗證

- [x] 2.1 在 nvim-tree 中，游標停在目錄節點，按 `FF` 確認 Telescope 只搜尋該目錄
- [x] 2.2 在 nvim-tree 中，游標停在檔案節點，按 `FF` 確認搜尋其父目錄
- [x] 2.3 在一般 buffer 中按 `FF`，確認搜尋整個 cwd（現有行為不變）
