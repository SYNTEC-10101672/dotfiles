## MODIFIED Requirements

### Requirement: 混合 symlink 部署 ~/.claude
系統 SHALL 使用混合 symlink 策略部署 `~/.claude/`：單檔 config 用單檔 symlink，目錄型 config 用目錄 symlink，runtime 目錄不 symlink（由 Claude Code 在本機建立）。

以下項目 SHALL 被 symlink：
- **單檔**：`settings.json`、`CLAUDE.md`
- **目錄**：`commands/`、`skills/`、`scripts/`

其他所有目錄（plugins, debug, sessions, projects, session-env, telemetry, cache, paste-cache, backups, logs, shell-snapshots, todos, tasks, plans, file-history, ide）SHALL NOT 被 symlink。

所有 symlink SHALL 使用 `$(ROOT_DIR)/claude/` 作為來源路徑（而非 `$(ROOT_DIR)/.claude/`），不寫死路徑。

#### Scenario: 全新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 不存在
- **THEN** 系統建立 `~/.claude/` 目錄，並建立 config 檔案和目錄的 symlink，來源指向 `$(ROOT_DIR)/claude/`

#### Scenario: 在已有環境上重新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 已存在且含 symlink
- **THEN** 系統更新 symlink，不移除已有的 runtime 目錄

#### Scenario: 在 container 中部署
- **WHEN** dotfiles repo 被 volume mount 到 container 內任意路徑（例如 `~/shared_zone/dotfiles/`），並從該路徑執行 `make install`
- **THEN** 系統透過 `ROOT_DIR` 自動解析正確的 repo 路徑，建立正確的 symlink

### Requirement: Makefile claude target 使用混合 symlink
Makefile 的 `claude` target SHALL 建立 `~/.claude/` 為真實目錄，然後為 config 檔案建立單檔 symlink，為 config 目錄建立目錄 symlink。symlink 來源 SHALL 使用 `$(ROOT_DIR)/claude/` 而非寫死路徑。

#### Scenario: make claude 冗等性
- **WHEN** `make claude` 被執行多次
- **THEN** symlink 被正確建立或更新，不產生錯誤

### Requirement: 移除 backup/restore/clean 功能
Makefile SHALL 移除 `backup`、`restore`、`clean` 三個 target。`install` target SHALL 直接執行各模組安裝，不再依賴 backup。`uninstall` target SHALL 移除 backup 相關的提示文字。

#### Scenario: make install 不再自動備份
- **WHEN** 執行 `make install`
- **THEN** 系統直接安裝各模組，不建立備份目錄

#### Scenario: make help 不再顯示 backup 相關指令
- **WHEN** 執行 `make help`
- **THEN** 輸出中不包含 backup、restore、clean 指令

### Requirement: 簡化 .gitignore
根目錄的 `.gitignore` SHALL 將 `claude/commands/opsx/` 和 `claude/skills/openspec-*/` 排除規則的來源路徑從 `.claude/` 更新為 `claude/`。SHALL 新增 `.claude/*` 排除規則和 `!.claude/CLAUDE.md` allowlist 規則。

#### Scenario: 迁移後 repo 內不含 runtime 目錄
- **WHEN** Claude Code 相關設定以混合 symlink 方式從 `claude/` 部署
- **THEN** `claude/` 路徑下的 runtime 排除規則對應到正確的來源目錄
