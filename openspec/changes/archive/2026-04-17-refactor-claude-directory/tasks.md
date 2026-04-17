## 1. 目錄重命名與 .claude/ 建立

- [x] 1.1 將 `.claude/` rename 為 `claude/`
- [x] 1.2 建立 `.claude/` 目錄
- [x] 1.3 建立 `.claude/CLAUDE.md`（project-level 指令，描述專案結構、部署方式、新增模組慣例）

## 2. 更新 .gitignore

- [x] 2.1 將 `.claude/commands/opsx/` 改為 `claude/commands/opsx/`
- [x] 2.2 將 `.claude/skills/openspec-*/` 改為 `claude/skills/openspec-*/`
- [x] 2.3 新增 `.claude/*` 和 `!.claude/CLAUDE.md` 規則

## 3. 簡化 Makefile

- [x] 3.1 移除 `BACKUP_DIR` 變數定義
- [x] 3.2 移除 `backup`、`restore`、`clean` target
- [x] 3.3 更新 `install` target（移除 `backup` 依賴）
- [x] 3.4 更新 `claude` target 的 source path：`.claude/` → `claude/`
- [x] 3.5 更新 `check` target 的 source path：`.claude/` → `claude/`
- [x] 3.6 更新 `uninstall` target（移除 backup 相關提示）
- [x] 3.7 更新 `.PHONY`（移除 backup、restore、clean）
- [x] 3.8 更新 `help` target（移除 backup/restore/clean 說明）

## 4. 更新 README.md

- [x] 4.1 更新專案結構圖（`.claude/` → `claude/`，新增 `.claude/CLAUDE.md`）
- [x] 4.2 移除備份與還原章節（備份、手動備份、還原備份、清除備份）
- [x] 4.3 移除 Makefile 指令表中的 backup/restore/clean 列
- [x] 4.4 更新問題排除中 statusline 路徑引用（如有）

## 5. 部署與驗證

- [x] 5.1 移除已部署環境的舊 symlinks（`~/.claude/` 下的 CLAUDE.md、settings.json、commands、skills、scripts）
- [x] 5.2 執行 `make claude` 確認新 symlink 正確建立
- [x] 5.3 執行 `make check` 確認所有 symlink 狀態正確
- [x] 5.4 確認 `make help` 輸出不含 backup/restore/clean
