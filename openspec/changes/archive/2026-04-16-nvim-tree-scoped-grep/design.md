## Context

目前 `.nvim/lua/config/telescope.lua` 中的 `FF` keymap 是靜態指令：

```lua
keymap("n", "FF", "<cmd>Telescope live_grep<cr>", opts)
```

這會無條件搜尋整個 cwd，無法感知使用者目前的游標位置。nvim-tree 提供 `nvim-tree.api` 可以在 Lua function 中取得當前游標節點的路徑，Telescope `live_grep` 支援 `search_dirs` 參數限制搜尋範圍。

## Goals / Non-Goals

**Goals:**
- `FF` 在 nvim-tree buffer 中執行時，以游標節點的目錄為搜尋範圍
- 游標在檔案節點時，取其父目錄
- 游標在一般 buffer 時，維持原有全域搜尋行為
- 不新增額外 keymap，維持單一 `FF` 入口

**Non-Goals:**
- 不支援多目錄同時搜尋
- 不修改其他 keymap（`<leader>fg` 等）
- 不處理 nvim-tree 以外的 file explorer

## Decisions

### 以 `vim.bo.filetype == "NvimTree"` 判斷游標位置

`FF` 是 global keymap，觸發時需判斷目前 buffer 是否為 nvim-tree。使用 `vim.bo.filetype` 是最直接的方式，不需要額外 flag 或 event。

替代方案：在 nvim-tree 的 `on_attach` 內另設 keymap — 這會產生兩個 `FF` 定義，維護分散，排除。

### 游標在檔案節點時取父目錄

使用者在 nvim-tree 瀏覽時游標可能停在檔案上，此時取 `vim.fn.fnamemodify(node.absolute_path, ":h")` 得到父目錄，語意上符合「搜尋我正在看的這個目錄」。

### 修改位置：`telescope.lua` 而非 `tree.lua`

`FF` 的定義在 `telescope.lua`，將 context-aware 邏輯集中在同一檔案，不跨檔案分散 keymap 責任。

## Risks / Trade-offs

- `nvim-tree.api` 不存在時 `pcall` 會失敗 → 加 `pcall` 保護，fallback 到全域搜尋
- nvim-tree 更新後 API 介面變動 → 低風險，`get_node_under_cursor` 是穩定 public API
