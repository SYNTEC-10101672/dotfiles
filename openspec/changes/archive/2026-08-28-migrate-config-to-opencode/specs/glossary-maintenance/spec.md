# Delta Spec: glossary-maintenance

## MODIFIED Requirements

### Requirement: domain-modeling 不產生 ADR

`domain-modeling` skill SHALL NOT 提議、生成或維護 ADR（Architecture Decision Record）；架構決策一律記錄於各 change 的 `design.md`。`docs/adr/` 目錄與 `ADR-FORMAT.md` 不再屬於此 skill 的產出。

#### Scenario: domain-modeling 無 ADR 引用

- **WHEN** 檢視 `opencode/skills/domain-modeling/SKILL.md`
- **THEN** 內容不含任何 ADR 相關段落或連結

#### Scenario: grill-with-docs 描述與行為一致

- **WHEN** 檢視 `opencode/commands/grill-with-docs.md` 的 frontmatter description
- **THEN** 不含 ADR 字樣，僅保留 glossary（CONTEXT.md）維護
