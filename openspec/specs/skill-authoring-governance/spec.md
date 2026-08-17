# skill-authoring-governance

Agent skill 檔案的 authoring 治理規則，確保任何 skill 修改前先載入 `/writing-great-skills` 規範。

## Purpose

規範 agent skill 檔案（SKILL.md 及其附屬檔案）的修改流程，要求修改前必須先載入 `/writing-great-skills` skill，且規則不綁定特定資料夾路徑。

## Requirements

### Requirement: 修改 agent skill 前必須載入 writing-great-skills

任何 session 在修改或新增 agent skill 檔案（SKILL.md 及其附屬檔案）之前，MUST 先載入 `/writing-great-skills` skill 並依其規範執行。此規則不綁定特定資料夾路徑，適用於 repo 內任何位置的 skill 檔案。

規則來源記錄於 `claude/CLAUDE.md` 的「Skills 維護規範」一節。

#### Scenario: 修改既有 skill 前載入規範

- **WHEN** 使用者要求修改 `claude/skills/` 下任一 SKILL.md
- **THEN** 該 session 在進行任何編輯前先載入 `/writing-great-skills`

#### Scenario: 規則不綁路徑

- **WHEN** skill 檔案未來搬移到 `claude/` 以外的位置且被要求修改
- **THEN** 規則仍然適用，因為表述為「任何 agent skill」而非特定路徑

#### Scenario: CLAUDE.md 包含規則文字

- **WHEN** 檢視 `claude/CLAUDE.md`
- **THEN** 內容包含「Skills 維護規範」一節，且明確指向 `/writing-great-skills`
