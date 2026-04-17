## ADDED Requirements

### Requirement: dotfiles 專案擁有 project-level CLAUDE.md
專案 SHALL 在 `.claude/CLAUDE.md` 建立 project-level 指令檔。此檔案描述 dotfiles 專案本身，供 Claude Code 在此 repo 工作時載入。內容 SHALL 包含：專案概述、部署方式（`make install`）、新增設定模組的慣例、專案結構重點。

#### Scenario: Claude Code 在 dotfiles repo 載入專案指令
- **WHEN** Claude Code 在 dotfiles repo 目錄下啟動
- **THEN** `.claude/CLAUDE.md` 被載入為 project-level 指令，提供專案相關的 context

#### Scenario: 與全域 CLAUDE.md 共存
- **WHEN** Claude Code 在 dotfiles repo 工作
- **THEN** `.claude/CLAUDE.md`（project-level）和 `~/.claude/CLAUDE.md`（global）同時生效

### Requirement: .gitignore 保護 .claude/ 目錄
`.gitignore` SHALL 使用 allowlist 模式：忽略 `.claude/*` 下所有檔案，但排除 `.claude/CLAUDE.md`。確保 Claude Code 未來在 `.claude/` 下產生的任何 runtime 檔案不會被 git 追蹤。

#### Scenario: Claude Code 在 .claude/ 下產生新檔案
- **WHEN** Claude Code 在 `.claude/` 下建立新檔案（如 `settings.local.json`）
- **THEN** 該檔案被 `.gitignore` 排除，不出現在 `git status` 中

#### Scenario: CLAUDE.md 仍被追蹤
- **WHEN** 使用者修改 `.claude/CLAUDE.md`
- **THEN** 該檔案正常出現在 `git status` 中，可被 commit
