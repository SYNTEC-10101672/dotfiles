# mattpocock-skills

從 `mattpocock/skills` vendor 指定 skills 到 dotfiles 的 `opencode/skills/` 目錄，並透過既有 symlink 部署讓 opencode 可用。user-invoked 的 `grill-me` / `grill-with-docs` 已遷移至 `opencode/commands/` slash commands（見 `writing-skills` 與本 spec 的 grill 系列 requirement）。

## Purpose

提供 8 個來自 `https://github.com/mattpocock/skills` 的 model-invoked skills（`grilling`、`writing-for-agents`、`domain-modeling`、`code-review`、`tdd`、`codebase-design`、`prototype`、`setup-matt-pocock-skills`），保留 upstream 內容與 invocation 分類，且不影響既有 skills；另以 6 個 slash commands（`grill-me`、`grill-with-docs`、`to-spec`、`to-tickets`、`implement`、`setup-matt-pocock-skills`）提供 user-invoked 流程（grill 系列為 grill 流程，matt 系列為 matt workflow）。
## Requirements
### Requirement: mattpocock vendor skill 目錄存在於正確路徑

系統 SHALL 在 `dotfiles/opencode/skills/` 下提供 4 個 skill 子目錄（model-invoked），每個子目錄必須包含一個 `SKILL.md` 檔案，內容來自 `https://github.com/mattpocock/skills` main 分支對應路徑的最新版本（byte-identical，含附屬檔案，本地不修改；同步 = 覆蓋）。

子目錄與 upstream 對應：
- `grilling/` ← `skills/productivity/grilling/`（含 `agents/`）
- `writing-for-agents/` ← `skills/productivity/writing-for-agents/`（含 `SKILL-MECHANICS.md`、`agents/`）
- `domain-modeling/` ← `skills/engineering/domain-modeling/`（含 `CONTEXT-FORMAT.md`、`ADR-FORMAT.md`、`agents/`）
- `code-review/` ← `skills/engineering/code-review/`（含 `agents/`）

`grill-me/` 與 `grill-with-docs/` 目錄 SHALL 不存在於 `opencode/skills/`（已遷移至 slash commands，見「grill 系列 slash commands 存在於 opencode/commands」requirement）。

#### Scenario: 4 個 SKILL.md 檔案都存在
- **WHEN** 安裝完成後檢查 `dotfiles/opencode/skills/`
- **THEN** 必須看到 `grilling/`、`writing-for-agents/`、`domain-modeling/`、`code-review/` 4 個子目錄，且每個子目錄內都有 `SKILL.md`

#### Scenario: SKILL.md 內容與 upstream 一致
- **WHEN** 比對 `dotfiles/opencode/skills/writing-for-agents/SKILL.md` 與 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md`
- **THEN** 兩者內容必須完全相同（vendor copy 不修改原檔）

#### Scenario: 附帶的 reference 檔案一併存在
- **WHEN** 檢查 `writing-for-agents/`、`domain-modeling/` 子目錄
- **THEN** `writing-for-agents/SKILL-MECHANICS.md`、`writing-for-agents/agents/openai.yaml`、`domain-modeling/CONTEXT-FORMAT.md`、`domain-modeling/ADR-FORMAT.md` 必須存在（這些是 SKILL.md 內連結或 invocation 設定的必要參考檔）

#### Scenario: 遷移的 grill skill 目錄不存在
- **WHEN** 執行 `ls dotfiles/opencode/skills/ | grep -E "^grill"`
- **THEN** 只列出 `grilling`（`grill-me` 與 `grill-with-docs` 不存在）

### Requirement: Skill 透過 symlink 即時可被 opencode 偵測

透過 `make opencode` 提供的 `~/.config/opencode/skills/ → dotfiles/opencode/skills/` 目錄 symlink，4 個 model-invoked vendor skill MUST 在下一個 opencode session 自動可用，不需手動重啟或修改任何 opencode 設定。

#### Scenario: symlink 即時生效
- **WHEN** 安裝完成後執行 `ls ~/.config/opencode/skills/`
- **THEN** 必須看到 `grilling`、`writing-for-agents`、`domain-modeling`、`code-review` 4 個項目（透過 symlink 透通顯示；`grill-me` 與 `grill-with-docs` 為 slash commands，不在 skills 目錄）

#### Scenario: SKILL.md frontmatter 格式相容
- **WHEN** 檢查每個 `SKILL.md` 的 YAML frontmatter
- **THEN** 必須包含 `name` 與 `description` 欄位（與既有 `openspec-*` / `tutoring` skills 格式一致），讓 oh-my-openagent 能正確解析

### Requirement: 不影響既有 skills

`dotfiles/opencode/skills/` 下的既有 skill 目錄（`openspec-*` 系列、`tutoring`，以及 `grilling`、`writing-for-agents`、`domain-modeling`、`code-review` 4 個 model-invoked mattpocock vendor skill）MUST NOT 被修改、刪除、或重新命名，除非有明確的 OpenSpec 變更提案授權。4 個 vendor skill 的內容更新（以 upstream 最新版覆蓋）屬本 capability 授權的維護行為，不構成修改。

#### Scenario: 既有 skills 完整保留
- **WHEN** 執行 `ls dotfiles/opencode/skills/`
- **THEN** 必須看到 `grilling`、`writing-for-agents`、`domain-modeling`、`code-review` 4 個 mattpocock vendor skill 目錄全部存在

#### Scenario: 子目錄名稱無衝突
- **WHEN** 檢查 `dotfiles/opencode/skills/` 的子目錄名稱清單
- **THEN** 不得有重複名稱（新增目錄不得與既有目錄同名）

### Requirement: 安裝來源可追溯

系統 SHALL 保留 upstream repo URL 與對應路徑資訊，讓日後手動重新 vendor 時有明確依據；資訊可記錄於 commit message、proposal.md、design.md，或本 spec 的 requirement 內容。

#### Scenario: commit message 含 upstream 資訊
- **WHEN** 檢視 git log 此變更的 commit
- **THEN** commit message 必須提及來源 `mattpocock/skills`（commit message 格式由 commit 階段決定，本 spec 不強制）

### Requirement: grill 系列 slash commands 存在於 opencode/commands

系統 SHALL 在 `opencode/commands/` 下提供 `grill-me.md` 與 `grill-with-docs.md` 兩個 slash command 檔案，結構為：

1. YAML frontmatter：`description`（沿用 upstream 原句）、`argument-hint: [topic to grill]`
2. `Topic to grill: $ARGUMENTS` 行
3. 指引行：`grill-me.md` 為 `Call the Skill tool with "grilling".`；`grill-with-docs.md` 為 `Call the Skill tool twice, for "grilling" and "domain-modeling".`（皆照搬 upstream SKILL.md body）

#### Scenario: 2 個 command 檔案存在於 opencode/commands/
- **WHEN** 執行 `ls opencode/commands/ | grep grill`
- **THEN** 列出 `grill-me.md` 與 `grill-with-docs.md`

#### Scenario: frontmatter 為 command 格式
- **WHEN** 檢查兩個 command 檔案的 YAML frontmatter
- **THEN** 含 `description` 與 `argument-hint` 欄位；不含 `disable-model-invocation`

#### Scenario: 指向的 skills 存在
- **WHEN** command 檔案內容引用 `grilling` 與 `domain-modeling`
- **THEN** `opencode/skills/grilling/SKILL.md` 與 `opencode/skills/domain-modeling/SKILL.md` 存在

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

