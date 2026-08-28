# Delta Spec: project-claude-md

## REMOVED Requirements

### Requirement: dotfiles 專案擁有 project-level CLAUDE.md

**Reason**: `.claude/CLAUDE.md` 隨 claude CLI 退役搬遷至 repo root `AGENTS.md`（opencode 的 project-level 指示檔約定）。

**Migration**: 由新 capability `project-agents-md` 承接，路徑與載入機制更新為 root `AGENTS.md`，內容大綱要求不變。

### Requirement: .gitignore 保護 .claude/ 目錄

**Reason**: `.claude/` 目錄整體消失（`CLAUDE.md` 搬至 root `AGENTS.md`、`settings.json` 刪除），allowlist 保護對象不存在。

**Migration**: 無承接（`.gitignore` 的 `.claude/*`、`!.claude/CLAUDE.md`、`!.claude/settings.json` 三行直接刪除；root `AGENTS.md` 為一般追蹤檔案，無須 ignore 規則）。
