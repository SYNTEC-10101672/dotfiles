# mattpocock-skills

從 `mattpocock/skills` vendor 指定 skills 到 dotfiles 的 Claude skills 目錄，並透過既有 symlink 部署讓 opencode 可用。user-invoked 的 `grill-me` / `grill-with-docs` 已遷移至 `claude/commands/` slash commands（見 `writing-skills` 與本 spec 的 grill 系列 requirement）。

## Purpose

提供 3 個來自 `https://github.com/mattpocock/skills` 的 model-invoked skills（`grilling`、`writing-for-agents`、`domain-modeling`），保留 upstream 內容與 invocation 分類，且不影響既有 skills；另以 2 個 slash commands（`grill-me`、`grill-with-docs`）提供 user-invoked 的 grill 流程。

## Requirements

### Requirement: 五個 mattpocock skill 檔案存在於正確路徑

系統 SHALL 在 `dotfiles/claude/skills/` 下提供 3 個 skill 子目錄（model-invoked），每個子目錄必須包含一個 `SKILL.md` 檔案，內容來自 `https://github.com/mattpocock/skills` main 分支對應路徑的最新版本。

子目錄與 upstream 對應：
- `grilling/SKILL.md` ← `skills/productivity/grilling/SKILL.md`
- `writing-for-agents/SKILL.md` ← `skills/productivity/writing-for-agents/SKILL.md`（含 `SKILL-MECHANICS.md`、`agents/openai.yaml` 一併複製）
- `domain-modeling/SKILL.md` ← `skills/engineering/domain-modeling/SKILL.md`（含 `CONTEXT-FORMAT.md`、`ADR-FORMAT.md` 一併複製）

`grill-me/` 與 `grill-with-docs/` 目錄 SHALL 不存在於 `claude/skills/`（已遷移至 slash commands，見「grill 系列以 slash commands 提供」requirement）。

#### Scenario: 3 個 SKILL.md 檔案都存在
- **WHEN** 安裝完成後檢查 `/home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `grilling/`、`writing-for-agents/`、`domain-modeling/` 3 個子目錄，且每個子目錄內都有 `SKILL.md`

#### Scenario: SKILL.md 內容與 upstream 一致
- **WHEN** 比對 `dotfiles/claude/skills/writing-for-agents/SKILL.md` 與 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md`
- **THEN** 兩者內容必須完全相同（vendor copy 不修改原檔）

#### Scenario: 附帶的 reference 檔案一併複製
- **WHEN** 檢查 `writing-for-agents/`、`domain-modeling/` 子目錄
- **THEN** `writing-for-agents/SKILL-MECHANICS.md`、`writing-for-agents/agents/openai.yaml`、`domain-modeling/CONTEXT-FORMAT.md`、`domain-modeling/ADR-FORMAT.md` 必須存在（這些是 SKILL.md 內連結或 invocation 設定的必要參考檔）

#### Scenario: 遷移的 grill skill 目錄不存在
- **WHEN** 執行 `ls dotfiles/claude/skills/ | grep -E "^grill"`
- **THEN** 只列出 `grilling`（`grill-me` 與 `grill-with-docs` 不存在）

### Requirement: grill 系列以 slash commands 提供

系統 SHALL 在 `claude/commands/` 下提供 `grill-me.md` 與 `grill-with-docs.md` 兩個 slash command 檔案，結構為：

1. YAML frontmatter：`description`（沿用 upstream 原句）、`argument-hint: [topic to grill]`
2. `Topic to grill: $ARGUMENTS` 行
3. 指引行：`grill-me.md` 為 `Call the Skill tool with "grilling".`；`grill-with-docs.md` 為 `Call the Skill tool twice, for "grilling" and "domain-modeling".`（皆照搬 upstream SKILL.md body）

#### Scenario: 2 個 command 檔案存在於 claude/commands/
- **WHEN** 執行 `ls claude/commands/ | grep grill`
- **THEN** 列出 `grill-me.md` 與 `grill-with-docs.md`

#### Scenario: frontmatter 為 command 格式
- **WHEN** 檢查兩個 command 檔案的 YAML frontmatter
- **THEN** 含 `description` 與 `argument-hint` 欄位；不含 `disable-model-invocation`

#### Scenario: 指向的 skills 存在
- **WHEN** command 檔案內容引用 `grilling` 與 `domain-modeling`
- **THEN** `claude/skills/grilling/SKILL.md` 與 `claude/skills/domain-modeling/SKILL.md` 存在

### Requirement: Skill 透過 symlink 即時可被 opencode 偵測

透過 `claude-config-symlink` 提供的 `~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/` symlink，保留的 3 個 model-invoked skill MUST 在下一個 opencode session 自動可用，不需手動重啟或修改任何 opencode 設定。

#### Scenario: symlink 即時生效
- **WHEN** 安裝完成後執行 `ls ~/.claude/skills/`
- **THEN** 必須看到 `grilling`、`writing-for-agents`、`domain-modeling` 3 個項目（透過 symlink 透通顯示；`grill-me` 與 `grill-with-docs` 已遷移至 `claude/commands/`，不在 skills 目錄）

#### Scenario: SKILL.md frontmatter 格式相容
- **WHEN** 檢查每個 `SKILL.md` 的 YAML frontmatter
- **THEN** 必須包含 `name` 與 `description` 欄位（與既有 `openspec-*` / `tutoring` skills 格式一致），讓 oh-my-openagent 能正確解析

### Requirement: 不影響既有 skills

`dotfiles/claude/skills/` 下的既有 skill 目錄（`openspec-*` 系列、`tutoring`、`openspec-code-review`，以及 `grilling`、`writing-for-agents`、`domain-modeling` 3 個 model-invoked mattpocock skill）MUST NOT 被修改、刪除、或重新命名，除非有明確的 OpenSpec 變更提案授權。

#### Scenario: 既有 skills 完整保留
- **WHEN** 執行 `ls /home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `grilling`、`writing-for-agents`、`domain-modeling` 3 個 mattpocock skill 目錄全部存在

#### Scenario: 子目錄名稱無衝突
- **WHEN** 檢查 `dotfiles/claude/skills/` 的子目錄名稱清單
- **THEN** 不得有重複名稱（新增目錄不得與既有目錄同名）

### Requirement: 安裝來源可追溯

系統 SHALL 保留 upstream repo URL 與對應路徑資訊，讓日後手動重新 vendor 時有明確依據；資訊可記錄於 commit message、proposal.md、design.md，或本 spec 的 requirement 內容。

#### Scenario: commit message 含 upstream 資訊
- **WHEN** 檢視 git log 此變更的 commit
- **THEN** commit message 必須提及來源 `mattpocock/skills`（commit message 格式由 commit 階段決定，本 spec 不強制）
