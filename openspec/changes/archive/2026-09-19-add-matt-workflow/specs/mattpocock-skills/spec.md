# Delta: mattpocock-skills

## ADDED Requirements

### Requirement: matt workflow vendor skills 存在於 opencode/skills

系統 SHALL 在 `opencode/skills/` 下提供 4 個 vendor skill 子目錄，檔案內容與 upstream `https://github.com/mattpocock/skills` main 分支對應路徑 byte-identical，但排除 `agents/` 目錄（Codex UI metadata，opencode 端惰性；與既有 4 個 vendor skills 續留 `agents/` 的政策差異是自覺決策，理由記錄於 design.md D2）。

路徑對應（local ← `skills/engineering/` 前綴下的 upstream 路徑）：

- `tdd/`：SKILL.md、tests.md、mocking.md（3 檔）
- `codebase-design/`：SKILL.md、DEEPENING.md、DESIGN-IT-TWICE.md（3 檔）
- `prototype/`：SKILL.md、LOGIC.md、UI.md（3 檔）
- `setup-matt-pocock-skills/`：SKILL.md、domain.md、issue-tracker-github.md、issue-tracker-gitlab.md、issue-tracker-local.md、triage-labels.md（6 檔）

#### Scenario: 4 個 skill 目錄與 15 個檔案都存在

- **WHEN** 執行 `find opencode/skills/tdd opencode/skills/codebase-design opencode/skills/prototype opencode/skills/setup-matt-pocock-skills -type f | sort`
- **THEN** 輸出恰好 15 個路徑，涵蓋上述對應表的每一個檔案

#### Scenario: 檔案內容與 upstream 一致

- **WHEN** 對 15 個檔案逐一 `diff` upstream raw URL（`https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/<對應路徑>`）與本地檔案
- **THEN** 每一檔 diff 為空（byte-identical）

#### Scenario: 新資料夾不含 agents 目錄

- **WHEN** 執行 `find opencode/skills/tdd opencode/skills/codebase-design opencode/skills/prototype opencode/skills/setup-matt-pocock-skills -name openai.yaml`
- **THEN** 無輸出（exit code 1）

### Requirement: matt workflow slash commands 存在於 opencode/commands

系統 SHALL 在 `opencode/commands/` 下提供 4 個 slash command 檔案：

1. `to-spec.md`、`to-tickets.md`、`implement.md`：YAML frontmatter 僅含 `description`（沿用 upstream SKILL.md 原句），不含 `name` 與 `disable-model-invocation`；body 為 upstream `skills/engineering/<name>/SKILL.md` 的 body 照搬（略過 upstream frontmatter；允許的偏離僅 frontmatter 轉換一項，模式同 `writing-skills` capability）
2. `setup-matt-pocock-skills.md`：薄 wrapper —— frontmatter 同上（`description` 沿用 upstream 原句），body 指引載入並執行 `setup-matt-pocock-skills` skill

#### Scenario: 4 個 command 檔案存在

- **WHEN** 執行 `ls opencode/commands/ | grep -E "^(to-spec|to-tickets|implement|setup-matt-pocock-skills)\.md$"`
- **THEN** 列出 4 個檔名

#### Scenario: frontmatter 為 command 格式

- **WHEN** 檢查 4 個 command 檔的 YAML frontmatter
- **THEN** 每檔含 `description` 欄位；不含 `name` 與 `disable-model-invocation`

#### Scenario: 轉檔 commands 的 body 與 upstream 一致

- **WHEN** 分別比對 `to-spec.md`、`to-tickets.md`、`implement.md` 的 body 與 upstream `skills/engineering/<name>/SKILL.md` 的 body（frontmatter 除外）
- **THEN** 逐字一致

#### Scenario: wrapper 指向的 skill 存在

- **WHEN** 檢查 `opencode/commands/setup-matt-pocock-skills.md` 內容引用 `setup-matt-pocock-skills`
- **THEN** `opencode/skills/setup-matt-pocock-skills/SKILL.md` 存在

### Requirement: matt workflow 項目透過既有 symlink 部署

4 個新 skill 目錄與 4 個新 command 檔 SHALL 透過既有目錄級 symlink 部署鏈生效：`make opencode` 後，`~/.config/opencode/skills/` 可見 `tdd`、`codebase-design`、`prototype`、`setup-matt-pocock-skills`，`~/.config/opencode/commands/` 可見 4 個新 `.md` 檔。部署 SHALL NOT 需要任何 Makefile 或 opencode 設定變更。

#### Scenario: 部署透通

- **WHEN** 執行 `make opencode` 後檢查 `~/.config/opencode/skills/` 與 `~/.config/opencode/commands/`
- **THEN** skills 目錄列出 `tdd`、`codebase-design`、`prototype`、`setup-matt-pocock-skills`；commands 目錄列出 `to-spec.md`、`to-tickets.md`、`implement.md`、`setup-matt-pocock-skills.md`

#### Scenario: Makefile 無變更

- **WHEN** 比對本變更前後的 `Makefile`
- **THEN** 無差異（目錄級 symlink 涵蓋新檔案）
