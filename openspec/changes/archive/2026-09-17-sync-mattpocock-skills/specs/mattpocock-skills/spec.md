# Delta: mattpocock-skills

## RENAMED Requirements

- FROM: `五個 mattpocock skill 檔案存在於正確路徑`
- TO: `mattpocock vendor skill 目錄存在於正確路徑`

## MODIFIED Requirements

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
