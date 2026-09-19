# Delta: skill-self-containment

## MODIFIED Requirements

### Requirement: Skills 與 commands 不引用全域指示檔

Skills 與 commands 的內容（含 frontmatter description）MUST NOT 以檔名或路徑引用全域指示檔（`CLAUDE.md` / `AGENTS.md`）。例外僅限文件類型語意（非對本 repo 全域指示檔的引用）：

1. 以文件類型詞彙提及（如 `writing-for-agents` 的 teaching material 中列舉 agent 消費的文件種類）
2. mattpocock vendor skills 的 upstream 內文以文件類型語意提及**目標 repo** 的指示檔（如 `setup-matt-pocock-skills` 教學如何挑選與編輯目標 repo 的 `AGENTS.md` / `CLAUDE.md`）；vendor 內容為 byte-identical 不可本地修改，此類引用由 upstream 語意決定

自撰（非 vendor）skills 與 commands 仍受本規範完全約束。

#### Scenario: 全 repo skills 與 commands 掃描

- **WHEN** 對 `opencode/skills/` 與 `opencode/commands/` 執行 `grep -rn "CLAUDE.md"`（排除 `writing-for-agents/` 與 `setup-matt-pocock-skills/`）
- **THEN** 結果為空（exit code 1，無輸出）

#### Scenario: 文件類型詞彙豁免

- **WHEN** 掃描 `opencode/skills/writing-for-agents/SKILL.md` 中的 `CLAUDE.md` 字眼
- **THEN** 保持原狀（其為「agent 消費的文件類型」列舉，非對本 repo 全域指示檔的引用）

#### Scenario: vendor skill 的目標 repo 指示檔語意豁免

- **WHEN** 掃描 `opencode/skills/setup-matt-pocock-skills/SKILL.md` 中的 `AGENTS.md` / `CLAUDE.md` 字眼
- **THEN** 保持 upstream 原狀（其為教學編輯目標 repo 指示檔的文件類型語意，且 vendor 內容 byte-identical 不可修改）
