## Why

當在 nvim-tree 中瀏覽專案時，`FF` 全域搜尋會搜尋整個 cwd，無法聚焦在特定子目錄，導致搜尋結果雜訊過多。需要讓 `FF` 具備 context-aware 行為，在 nvim-tree 中時針對游標所在目錄做搜尋。

## What Changes

- `FF` keymap 從靜態的 `<cmd>Telescope live_grep<cr>` 改為動態 function
- 當游標在 nvim-tree buffer 時，抓取游標節點路徑，傳入 `live_grep({ search_dirs = { dir } })`
- 游標在一般 buffer 時，維持原有行為（搜尋整個 cwd）
- 游標在 nvim-tree 的檔案節點上時，取其父目錄作為搜尋範圍

## Capabilities

### New Capabilities

- `nvim-tree-scoped-grep`: 在 nvim-tree 中按 `FF` 時，以游標所在目錄為範圍執行 Telescope live_grep

### Modified Capabilities

（無）

## Impact

- 修改檔案：`.nvim/lua/config/telescope.lua`
- 依賴：`nvim-tree.api`（已安裝）、`telescope.builtin`（已安裝）
- 不影響其他現有 keymap
