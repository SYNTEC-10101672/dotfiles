## ADDED Requirements

### Requirement: 混合 symlink 部署 ~/.claude
系統 SHALL 使用混合 symlink 策略部署 `~/.claude/`：單檔 config 用單檔 symlink，目錄型 config 用目錄 symlink，runtime 目錄不 symlink（由 Claude Code 在本機建立）。

以下項目 SHALL 被 symlink：
- **單檔**：`settings.json`、`CLAUDE.md`、`.gitignore`
- **目錄**：`commands/`、`skills/`、`scripts/`

其他所有目錄（plugins, debug, sessions, projects, session-env, telemetry, cache, paste-cache, backups, logs, shell-snapshots, todos, tasks, plans, file-history, ide）SHALL NOT 被 symlink。

所有 symlink SHALL 使用 `$(ROOT_DIR)` 作為來源路徑，不寫死路徑。

#### Scenario: 全新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 不存在
- **THEN** 系統建立 `~/.claude/` 目錄，並建立 config 檔案和目錄的 symlink

#### Scenario: 在已有環境上重新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 已存在且含 symlink
- **THEN** 系統更新 symlink，不移除已有的 runtime 目錄

#### Scenario: 在 container 中部署
- **WHEN** dotfiles repo 被 volume mount 到 container 內任意路徑（例如 `~/shared_zone/dotfiles/`），並從該路徑執行 `make install`
- **THEN** 系統透過 `ROOT_DIR` 自動解析正確的 repo 路徑，建立正確的 symlink

### Requirement: Makefile claude target 使用混合 symlink
Makefile 的 `claude` target SHALL 建立 `~/.claude/` 為真實目錄，然後為 config 檔案建立單檔 symlink，為 config 目錄建立目錄 symlink。symlink 來源 SHALL 使用 `$(ROOT_DIR)` 而非寫死路徑。

#### Scenario: make claude 冪等性
- **WHEN** `make claude` 被執行多次
- **THEN** symlink 被正確建立或更新，不產生錯誤

### Requirement: 簡化 .gitignore
根目錄的 `.gitignore` SHALL 移除所有 `.claude/` 子目錄的 runtime 排除規則（plugins/, debug/, sessions/, projects/ 等），因為這些目錄不再會出現在 repo 中。SHALL 保留 symlink 目錄內外部管理項目的排除規則（例如 `commands/opsx/`、`skills/openspec-*/`）。

#### Scenario: 遷移後 repo 內不含 runtime 目錄
- **WHEN** `.claude/` 以混合 symlink 方式部署
- **THEN** repo 的 `.claude/` 路徑下不存在任何 runtime 目錄
