## 1. 移除檔案與 Makefile 引用

- [x] 1.1 刪除 `scripts/resetcnc`
- [x] 1.2 從 Makefile `scripts` target 移除 resetcnc symlink 行（L86）
- [x] 1.3 從 Makefile `uninstall` target 的迴圈中移除 `resetcnc`（L121）
- [x] 1.4 從 Makefile `check` target 的迴圈中移除 `resetcnc`（L199）

## 2. 更新文件

- [x] 2.1 從 `docs/ENV_SETUP.md` 移除「硬體控制工具」整個段落（L173-188）
- [x] 2.2 從 `docs/ENV_SETUP.md` 參考資料中移除 resetcnc 連結（L312）

## 3. 驗證

- [x] 3.1 執行 `make check` 確認 resetcnc 不再出現
- [x] 3.2 確認 `make scripts`、`make uninstall` 正常運作
