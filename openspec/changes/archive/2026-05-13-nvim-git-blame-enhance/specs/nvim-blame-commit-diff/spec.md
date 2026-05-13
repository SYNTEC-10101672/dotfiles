## ADDED Requirements

### Requirement: 每行 EOL 持續顯示 blame commit message
gitsigns 的 inline blame 功能 SHALL 預設開啟，每行行尾（EOL）持續顯示 `author, date - commit message`（即 `current_line_blame_formatter` 中的 `<summary>` 欄位）。

#### Scenario: 開啟含 git 歷史的檔案時自動顯示 inline blame
- **WHEN** 使用者在 git repo 內開啟任何已追蹤的檔案
- **THEN** 每行行尾以虛擬文字顯示 `author, YYYY-MM-DD - commit message`

#### Scenario: 使用 toggle 切換 inline blame 顯示
- **WHEN** 使用者按下 `<leader>tb`
- **THEN** inline blame 顯示切換（開 ↔ 關）

---

### Requirement: 游標行 blame commit 的 vertical split diff
使用者 SHALL 能在游標所在行按下 `<leader>hv`，觸發對該行 blame commit 的 file-level vertical split diff，左側顯示 commit 前的版本，右側顯示 commit 後的版本。

#### Scenario: 游標在已 commit 的行時開啟 diff
- **WHEN** 使用者游標在某行，該行有已 commit 的變更記錄，並按下 `<leader>hv`
- **THEN** nvim 開啟 vertical split：左側為該 commit 的 parent 版本（`hash^`），右側為該 commit 版本（`hash`）

#### Scenario: 游標在未 commit 的行時給予提示
- **WHEN** 使用者游標在 uncommitted 的行（blame hash 為 `0000000000000000000000000000000000000000`）並按下 `<leader>hv`
- **THEN** 顯示警告通知「Line not committed yet」，不開啟 diff
