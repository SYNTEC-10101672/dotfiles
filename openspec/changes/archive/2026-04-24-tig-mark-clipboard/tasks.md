## 1. 實作 clipboard function

- [x] 1.1 在 `scripts/tig-mark-commit.sh` 頂部新增 `copy_to_clipboard()` function，使用 OSC 52 escape sequence
- [x] 1.2 在 `mark` action 中呼叫 `copy_to_clipboard`，傳入 commit hash
- [x] 1.3 在 `status` action 中有已標記 commit 時呼叫 `copy_to_clipboard`，未標記時不呼叫

## 2. 驗證

- [x] 2.1 在支援 OSC 52 的 terminal 中測試 `mark` action，確認 clipboard 包含正確的 commit hash
> 驗證：已手動驗證通過

- [x] 2.2 測試 `status` action，確認已標記時 clipboard 被更新、未標記時無錯誤
> 驗證：跳過。Ctrl-M 與 Enter 發送相同 byte（0x0D），tig 無法區分，為既有 keybinding 衝突問題，非本次變更範圍
