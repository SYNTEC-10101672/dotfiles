## MODIFIED Requirements

### Requirement: 游標行 blame commit 的 vertical split diff
使用者 SHALL 能在游標所在行按下 `<leader>hv`，觸發對該行 blame commit 的 file-level vertical split diff，左側顯示 commit 前的版本，右側顯示 commit 後的版本。若該 commit 為 first commit（無 parent），左側顯示空 buffer，右側顯示該 commit 引入的完整檔案內容。

#### Scenario: 游標在已 commit 的行時開啟 diff
- **WHEN** 使用者游標在某行，該行有已 commit 的變更記錄，並按下 `<leader>hv`
- **THEN** nvim 開啟 vertical split：左側為該 commit 的 parent 版本（`hash^`），右側為該 commit 版本（`hash`）

#### Scenario: 游標在 first commit 的行時開啟 diff
- **WHEN** 使用者游標在某行，該行的 blame commit 為 first commit（`hash^` 不存在），並按下 `<leader>hv`
- **THEN** nvim 開啟 vertical split：左側為空 buffer，右側為該 commit 版本（`hash`），所有行標示為新增（綠色）

#### Scenario: 游標在未 commit 的行時給予提示
- **WHEN** 使用者游標在 uncommitted 的行（blame hash 為 `0000000000000000000000000000000000000000`）並按下 `<leader>hv`
- **THEN** 顯示警告通知「Line not committed yet」，不開啟 diff
