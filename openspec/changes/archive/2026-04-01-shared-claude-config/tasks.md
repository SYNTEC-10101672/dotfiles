## 1. 更新 Makefile claude target

- [x] 1.1 將 `claude` target 改為：先建立 `~/.claude/` 目錄（若不存在），再用 `ln -sf` 建立單檔 symlink（settings.json, CLAUDE.md, .gitignore），再用 `ln -sfn` 建立目錄 symlink（commands/, skills/, scripts/）
- [x] 1.2 更新 `uninstall` target：移除對應的單檔和目錄 symlink（不移除 ~/.claude/ 目錄本身，因為可能含 runtime 資料）
- [x] 1.3 更新 `check` target：檢查 symlink 是否存在且指向正確路徑

## 2. 簡化 .gitignore

- [x] 2.1 移除 `.gitignore` 中 `.claude/` 的 runtime 目錄排除規則（plugins/, debug/, sessions/, projects/, session-env/, telemetry/, cache/, paste-cache/, backups/, logs/, shell-snapshots, todos/, tasks/, plans/, file-history/, ide/）
- [x] 2.2 保留 `.claude/skills/openspec-*/` 和 `.claude/commands/opsx/` 排除規則

## 3. 驗證

- [x] 3.1 執行 `make check` 確認 symlink 設定正確
- [x] 3.2 確認 `make claude` 冪等：執行兩次不產生錯誤
