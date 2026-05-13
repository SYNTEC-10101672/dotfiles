## Context

目前的 git blame 設定分散在兩個地方：

- `nvim/lua/config/git.lua`：gitsigns 設定，`current_line_blame = false`，formatter 已含 `<summary>`（commit message）但沒開啟
- `nvim/lua/config/fugitive.lua`：只有 `<leader>gb`（`:Git blame`）和 `<leader>gd`（`:Gvdiffsplit`）

要達成「看 commit msg → 做 file-level diff」需要：
1. 開啟 inline blame 顯示 commit message
2. 新增一個 function 能取得游標所在行的 blame hash 並展開 vertical split diff

## Goals / Non-Goals

**Goals:**
- 開啟 `current_line_blame` 讓每行 EOL 持續顯示 commit message
- 新增 `<leader>hv` keybinding，對游標行的 blame commit 展開 vertical split diff（左：改前，右：改後）
- 不安裝任何新 plugin，完全依賴已有的 gitsigns + fugitive

**Non-Goals:**
- 互動式 blame browser（diffview.nvim 類型）
- 跨 commit 的歷史瀏覽
- Telescope 整合

## Decisions

### 決策 1：用 `git blame --porcelain` 取 hash，而非 gitsigns API

**選擇**：`vim.fn.system("git blame -L <line>,<line> <file> --porcelain | head -1 | awk '{print $1}'")`

**理由**：gitsigns 的 `get_hunks()` / `blame_line()` 返回的是 hunk 層級的資訊，取單行 commit hash 需要 callback 且 API 不穩定。直接呼叫 `git blame --porcelain` 簡單可靠，輸出第一欄就是 40-char hash。

**替代方案**：`gitsigns.get_hunks()` → 較複雜且依賴 async callback

---

### 決策 2：用 `:Gedit hash:%` + `:Gvdiffsplit hash^` 展開 diff

**選擇**：
1. `:Gedit <hash>:%` — 在新 buffer 開啟當前檔案在該 commit 時的快照（`%` = fugitive magic for current file path）
2. `:Gvdiffsplit <hash>^` — 從該 buffer 再 split 出 parent 版本

**結果**：左側 = `hash^`（改前），右側 = `hash`（改後）

**理由**：完全符合使用者習慣的左右 split diff 視圖，且不顯示 working tree 的當前狀態（只看那個 commit 改了什麼）。

**替代方案**：
- `:Gdiffsplit <hash>^`（從當前 working tree buffer）→ 右側會是 working tree，不是那個 commit 的狀態
- `git show <hash> -- <file>` + 手動 split → 要自己管理 buffer，太複雜

---

### 決策 3：未 commit 的行（hash 為 `0000...`）給予提示

**選擇**：偵測到 40 個 0 的 hash（代表 uncommitted changes）時，用 `vim.notify` 提示使用者，不開啟 diff。

## Risks / Trade-offs

- [inline blame 可能在長行時截斷] → formatter 的 `<summary>` 受終端寬度限制，無法完整顯示長 commit message。緩解：用 `<leader>hb`（popup）查完整資訊。
- [git blame 指令依賴 shell 環境] → 在非 git repo 目錄下會失敗。緩解：function 頭部加 guard，檢查 hash 是否為空。
- [`:Gedit hash:%` 的 `%` 語法] → 需要當前 buffer 是 fugitive 能識別的路徑（一般 git repo 內的檔案都沒問題）。
