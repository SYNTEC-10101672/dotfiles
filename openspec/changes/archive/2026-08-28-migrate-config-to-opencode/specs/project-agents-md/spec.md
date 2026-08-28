# Delta Spec: project-agents-md

## ADDED Requirements

### Requirement: dotfiles 專案擁有 project-level AGENTS.md

專案 SHALL 在 repo root 維護 `AGENTS.md` 作為 project-level 指示檔。此檔案描述 dotfiles 專案本身，供 opencode 在此 repo 工作時載入。內容 SHALL 包含：專案概述、部署方式（`make install` 與各模組 target）、專案結構重點、新增設定模組的慣例。

#### Scenario: opencode 在 dotfiles repo 載入專案指令

- **WHEN** opencode 在 dotfiles repo 目錄下啟動
- **THEN** repo root `AGENTS.md` 被載入為 project-level 指令，提供專案相關的 context

#### Scenario: 與全域 AGENTS.md 共存

- **WHEN** opencode 在 dotfiles repo 工作
- **THEN** root `AGENTS.md`（project-level）和 `~/.config/opencode/AGENTS.md`（global，來源 `opencode/AGENTS.md`）同時生效

#### Scenario: 檔案受 git 追蹤

- **WHEN** 執行 `git status` 且 root `AGENTS.md` 有修改
- **THEN** 該檔案正常出現在 `git status` 中（非 ignore 對象）
