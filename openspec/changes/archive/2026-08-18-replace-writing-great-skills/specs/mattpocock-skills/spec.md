# Delta Spec: mattpocock-skills

## MODIFIED Requirements

### Requirement: 五個 mattpocock skill 檔案存在於正確路徑

系統 SHALL 在 `dotfiles/claude/skills/` 下提供 5 個 skill 子目錄，每個子目錄必須包含一個 `SKILL.md` 檔案，內容來自 `https://github.com/mattpocock/skills` main 分支對應路徑的最新版本。

子目錄與 upstream 對應：
- `grill-me/SKILL.md` ← `skills/productivity/grill-me/SKILL.md`
- `grilling/SKILL.md` ← `skills/productivity/grilling/SKILL.md`
- `writing-for-agents/SKILL.md` ← `skills/productivity/writing-for-agents/SKILL.md`（含 `SKILL-MECHANICS.md`、`agents/openai.yaml` 一併複製）
- `domain-modeling/SKILL.md` ← `skills/engineering/domain-modeling/SKILL.md`（含 `CONTEXT-FORMAT.md`、`ADR-FORMAT.md` 一併複製）
- `grill-with-docs/SKILL.md` ← `skills/engineering/grill-with-docs/SKILL.md`（含 `agents/openai.yaml` 一併複製）

#### Scenario: 5 個 SKILL.md 檔案都存在
- **WHEN** 安裝完成後檢查 `/home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `grill-me/`、`grilling/`、`writing-for-agents/`、`domain-modeling/`、`grill-with-docs/` 5 個子目錄，且每個子目錄內都有 `SKILL.md`

#### Scenario: SKILL.md 內容與 upstream 一致
- **WHEN** 比對 `dotfiles/claude/skills/writing-for-agents/SKILL.md` 與 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/writing-for-agents/SKILL.md`
- **THEN** 兩者內容必須完全相同（vendor copy 不修改原檔）

#### Scenario: 附帶的 reference 檔案一併複製
- **WHEN** 檢查 `writing-for-agents/`、`domain-modeling/`、`grill-with-docs/` 子目錄
- **THEN** `writing-for-agents/SKILL-MECHANICS.md`、`writing-for-agents/agents/openai.yaml`、`domain-modeling/CONTEXT-FORMAT.md`、`domain-modeling/ADR-FORMAT.md`、`grill-with-docs/agents/openai.yaml` 必須存在（這些是 SKILL.md 內連結或 invocation 設定的必要參考檔）

#### Scenario: 舊 skill 目錄與 GLOSSARY 不存在
- **WHEN** 檢查 `/home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須沒有 `writing-great-skills/` 子目錄；`writing-for-agents/` 內必須沒有 `GLOSSARY.md`（新版已將定義 inline，glossary 不再存在）

### Requirement: Skill 透過 symlink 即時可被 opencode 偵測

透過 `claude-config-symlink` 提供的 `~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/` symlink，安裝的 5 個 skill MUST 在下一個 opencode session 自動可用，不需手動重啟或修改任何 opencode 設定。

#### Scenario: symlink 即時生效
- **WHEN** 安裝完成後執行 `ls ~/.claude/skills/`
- **THEN** 必須看到 `grill-me`、`grilling`、`writing-for-agents`、`domain-modeling`、`grill-with-docs` 5 個項目（透過 symlink 透通顯示）

#### Scenario: SKILL.md frontmatter 格式相容
- **WHEN** 檢查每個 `SKILL.md` 的 YAML frontmatter
- **THEN** 必須包含 `name` 與 `description` 欄位（與既有 `openspec-*` / `tutoring` skills 格式一致），讓 oh-my-openagent 能正確解析

### Requirement: user-invoked 與 model-invoked 分類正確

安裝的 5 個 skill MUST 保留 upstream SKILL.md 的 invocation 分類：
- user-invoked（`disable-model-invocation: true`）：`grill-me`、`grill-with-docs`
- model-invoked（無 `disable-model-invocation` 或設為 false）：`grilling`、`domain-modeling`、`writing-for-agents`

#### Scenario: user-invoked skills 有正確的 frontmatter 標記
- **WHEN** 檢查 `dotfiles/claude/skills/grill-me/SKILL.md`、`grill-with-docs/SKILL.md` 的 frontmatter
- **THEN** 必須包含 `disable-model-invocation: true`

#### Scenario: user-invoked skills 有正確的 openai.yaml policy
- **WHEN** 檢查 `dotfiles/claude/skills/grill-me/agents/openai.yaml`、`grill-with-docs/agents/openai.yaml`
- **THEN** 必須包含 `policy.allow_implicit_invocation: false`

#### Scenario: model-invoked skills 沒有 disable 標記
- **WHEN** 檢查 `dotfiles/claude/skills/grilling/SKILL.md`、`domain-modeling/SKILL.md` 與 `writing-for-agents/SKILL.md` 的 frontmatter
- **THEN** 必須沒有 `disable-model-invocation: true`（或值不為 true）

#### Scenario: writing-for-agents 的 openai.yaml 允許 implicit invocation
- **WHEN** 檢查 `dotfiles/claude/skills/writing-for-agents/agents/openai.yaml`
- **THEN** 必須沒有 `policy.allow_implicit_invocation: false`（與 upstream model-invoked 分類一致）

### Requirement: 不影響既有 skills

`dotfiles/claude/skills/` 下的既有 skill 目錄（`openspec-*` 系列、`tutoring`、`openspec-code-review`，以及 `grill-me`、`grilling`、`writing-for-agents`、`domain-modeling`、`grill-with-docs` 5 個 mattpocock skill）MUST NOT 被修改、刪除、或重新命名，除非有明確的 OpenSpec 變更提案授權（`writing-great-skills` → `writing-for-agents` 的 rename 即由 `replace-writing-great-skills` 變更授權）。

#### Scenario: 既有 skills 完整保留
- **WHEN** 執行 `ls /home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `grill-me`、`grilling`、`writing-for-agents`、`domain-modeling`、`grill-with-docs` 5 個 mattpocock skill 目錄全部存在，且 `writing-great-skills` 不再出現（已由授權變更改名）

#### Scenario: 子目錄名稱無衝突
- **WHEN** 檢查 `dotfiles/claude/skills/` 的子目錄名稱清單
- **THEN** 不得有重複名稱（新增目錄不得與既有目錄同名）
