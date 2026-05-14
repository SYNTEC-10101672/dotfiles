## Context

`blame_commit_diff` 透過 `git blame` 取得游標行的 commit hash，再用 fugitive 的 `Gedit` + `Gvdiffsplit` 開啟 vertical split diff。當 blame hash 為 first commit 時，`hash^` 不存在，fugitive 無法執行 `Gvdiffsplit hash^`，目前以 early return + notification 處理。

## Goals / Non-Goals

**Goals:**
- First commit 情況下展示 vertical split diff（左空右有）
- 視覺行為與一般 commit 情況一致（同為 vimdiff split）

**Non-Goals:**
- 改變一般 commit 的 diff 流程
- 修改 buffer label / buffer name 的顯示

## Decisions

### 決策：使用手動 `nofile` buffer 而非 git empty tree SHA

**採用**：開 `vnew`，設定 `buftype=nofile bufhidden=wipe noswapfile`，再對兩側各呼叫 `diffthis`。

**捨棄**：使用 git empty tree SHA（`4b825dc642cb6eb9a060e54bf8d69288fbee4904`）搭配 `Gvdiffsplit`。

**理由**：Fugitive 未明確支援 empty tree SHA 作為 diff target，行為不可預期。手動建 `nofile` buffer 完全可控，`diffthis` 對任何 buffer 均有效，不需要 filetype 即可正確高亮 diff。

### 決策：cursor 最終停在右側（blob）

First commit flow 結束後，cursor 停在右側（`hash:file` blob），與一般 commit 情況（`Gvdiffsplit` 後 cursor 留在 blob buffer）一致。

## Risks / Trade-offs

- `nofile` buffer 沒有 git 語意的 buffer name（顯示為 `[No Name]`），使用者無法從 buffer name 判斷這是 first commit 情況 → 可接受，使用者從 explore mode 討論中已知 label 不需要
- `diffthis` 在呼叫順序上需注意：先對 blob 執行，再切到左側空 buffer 執行，最後 `wincmd p` 回右側
