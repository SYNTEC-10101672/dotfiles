## Why

`blame_commit_diff`（`<leader>hv`）在游標行的 blame commit 為 first commit 時，目前直接顯示 notification 並返回，無法看到該 commit 實際引入的內容。First commit 同樣應該展示 split view，語意上左側為空（無 parent），右側顯示所有被引入的行，與一般 commit 的體驗一致。

## What Changes

- 移除 first commit 情況下的 early return
- 改為開啟 vertical split diff：左側為空 buffer（`nofile`），右側為 `hash:file` blob
- 右側所有行因左側為空而標示為綠色（新增），正確反映 first commit 引入所有內容的語意

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `nvim-blame-commit-diff`：新增 first commit 的 diff 展示行為（目前 spec 未涵蓋此 scenario）

## Impact

- 修改 `nvim/lua/config/git.lua` 中的 `blame_commit_diff` 函式
- 不影響現有 keybinding、其他 gitsigns 設定或一般 commit 的 diff 流程
