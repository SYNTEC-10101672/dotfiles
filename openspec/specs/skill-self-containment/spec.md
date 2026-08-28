# skill-self-containment

Skills 與 commands 的內容自足性規範：已由 system prompt 載入的 ambient 規則不做路徑引用也不重抄；skill 功能所需的規則必須在內文明示。

## Purpose

規範 `claude/skills/` 與 `claude/commands/` 的自足性：ambient 規則（已由全域指示檔載入）引用是零功 pointer，MUST NOT 出現；skill 功能依賴的規則 MUST 內文明示，不依賴讀者另行載入全域指示檔。

## Requirements

### Requirement: Skills 與 commands 不引用全域指示檔

Skills 與 commands 的內容（含 frontmatter description）MUST NOT 以檔名或路徑引用全域指示檔（`CLAUDE.md` / `AGENTS.md`）。唯一例外：以文件類型詞彙提及（如 `writing-for-agents` 的 teaching material 中列舉 agent 消費的文件種類）。

#### Scenario: 全 repo skills 與 commands 掃描

- **WHEN** 對 `claude/skills/` 與 `claude/commands/` 執行 `grep -rn "CLAUDE.md"`（排除 `writing-for-agents/`）
- **THEN** 結果為空（exit code 1，無輸出）

#### Scenario: 文件類型詞彙豁免

- **WHEN** 掃描 `claude/skills/writing-for-agents/SKILL.md` 中的 `CLAUDE.md` 字眼
- **THEN** 保持原狀（其為「agent 消費的文件類型」列舉，非對本 repo 全域指示檔的引用）

### Requirement: Skill 功能所需的規則內文明示

Skill 或 command 的功能若依賴某條規則，該規則 MUST 在該 skill/command 內文明示（自足），MUST NOT 依賴讀者另行載入全域指示檔。衝突裁決（此文件與既有規則衝突時何者優先）MUST 正面陳述（如「衝突時以此為準」），MUST NOT 以否定語氣表達。

#### Scenario: eli5 疊加語意

- **WHEN** 讀取 `claude/commands/eli5.md`
- **THEN** 開頭含「疊加於既有規則，衝突時以此為準」且不含 `CLAUDE.md` 字眼；路徑／指令／config 精確要求以正面句保留
