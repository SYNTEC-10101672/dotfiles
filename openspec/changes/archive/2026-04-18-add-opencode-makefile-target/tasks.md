## 1. Makefile 修改

- [x] 1.1 在 `.PHONY` 行加入 `opencode`
- [x] 1.2 在 `install` 依賴中加入 `opencode`（放在 `claude` 之後）
- [x] 1.3 在 `help` 輸出中加入 `make opencode` 說明
- [x] 1.4 新增 `opencode` target：`mkdir -p ~/.config/opencode && ln -sfn commands symlink`
- [x] 1.5 在 `uninstall` target 中加入清理 `~/.config/opencode/commands` symlink
- [x] 1.6 在 `check` target 中加入 opencode symlink 狀態檢查

## 2. 驗證

- [x] 2.1 執行 `make opencode` 確認 symlink 建立正確
- [x] 2.2 執行 `make check` 確認 opencode 項目顯示 ✓
- [x] 2.3 執行 `make uninstall` 確認 symlink 被清理
