# mattpocock-skills

從 `mattpocock/skills` vendor 指定 skills 到 dotfiles 的 Claude skills 目錄，並透過既有 symlink 部署讓 opencode 可用。

## Purpose

提供 4 個來自 `https://github.com/mattpocock/skills` 的 productivity / engineering skills，保留 upstream 內容與 invocation 分類，且不影響既有 skills。

## Requirements

### Requirement: 四個 mattpocock skill 檔案存在於正確路徑

系統 SHALL 在 `dotfiles/claude/skills/` 下提供 4 個 skill 子目錄，每個子目錄必須包含一個 `SKILL.md` 檔案，內容來自 `https://github.com/mattpocock/skills` main 分支對應路徑的最新版本。

子目錄與 upstream 對應：
- `grill-me/SKILL.md` ← `skills/productivity/grill-me/SKILL.md`
- `grilling/SKILL.md` ← `skills/productivity/grilling/SKILL.md`
- `writing-great-skills/SKILL.md` ← `skills/productivity/writing-great-skills/SKILL.md`（含 `GLOSSARY.md` 一併複製）
- `domain-modeling/SKILL.md` ← `skills/engineering/domain-modeling/SKILL.md`（含 `CONTEXT-FORMAT.md`、`ADR-FORMAT.md` 一併複製）

#### Scenario: 4 個 SKILL.md 檔案都存在
- **WHEN** 安裝完成後檢查 `/home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `grill-me/`、`grilling/`、`writing-great-skills/`、`domain-modeling/` 4 個子目錄，且每個子目錄內都有 `SKILL.md`

#### Scenario: SKILL.md 內容與 upstream 一致
- **WHEN** 比對 `dotfiles/claude/skills/grill-me/SKILL.md` 與 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/productivity/grill-me/SKILL.md`
- **THEN** 兩者內容必須完全相同（vendor copy 不修改原檔）

#### Scenario: 附帶的 reference 檔案一併複製
- **WHEN** 檢查 `writing-great-skills/` 與 `domain-modeling/` 子目錄
- **THEN** `writing-great-skills/GLOSSARY.md`、`domain-modeling/CONTEXT-FORMAT.md`、`domain-modeling/ADR-FORMAT.md` 必須存在（這些是 SKILL.md 內 `[file](./X.md)` 連結的必要參考檔）

### Requirement: Skill 透過 symlink 即時可被 opencode 偵測

透過 `claude-config-symlink` 提供的 `~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/` symlink，新安裝的 4 個 skill MUST 在下一個 opencode session 自動可用，不需手動重啟或修改任何 opencode 設定。

#### Scenario: symlink 即時生效
- **WHEN** 安裝完成後執行 `ls ~/.claude/skills/`
- **THEN** 必須看到 `grill-me`、`grilling`、`writing-great-skills`、`domain-modeling` 4 個項目（透過 symlink 透通顯示）

#### Scenario: SKILL.md frontmatter 格式相容
- **WHEN** 檢查每個 `SKILL.md` 的 YAML frontmatter
- **THEN** 必須包含 `name` 與 `description` 欄位（與既有 `openspec-*` / `tutoring` skills 格式一致），讓 oh-my-openagent 能正確解析

### Requirement: user-invoked 與 model-invoked 分類正確

安裝的 4 個 skill MUST 保留 upstream SKILL.md 的 invocation 分類：
- user-invoked（`disable-model-invocation: true`）：`grill-me`、`writing-great-skills`
- model-invoked（無 `disable-model-invocation` 或設為 false）：`grilling`、`domain-modeling`

#### Scenario: user-invoked skills 有正確的 frontmatter 標記
- **WHEN** 檢查 `dotfiles/claude/skills/grill-me/SKILL.md` 與 `writing-great-skills/SKILL.md` 的 frontmatter
- **THEN** 必須包含 `disable-model-invocation: true`

#### Scenario: model-invoked skills 沒有 disable 標記
- **WHEN** 檢查 `dotfiles/claude/skills/grilling/SKILL.md` 與 `domain-modeling/SKILL.md` 的 frontmatter
- **THEN** 必須沒有 `disable-model-invocation: true`（或值不為 true）

### Requirement: 不影響既有 skills

本變更 MUST NOT 修改、刪除、或重新命名 `dotfiles/claude/skills/` 下任何既有檔案（包含 `openspec-*` 系列、`tutoring`、`openspec-code-review`）。新安裝的 4 個子目錄名稱 MUST NOT 與既有子目錄衝突。

#### Scenario: 既有 skills 完整保留
- **WHEN** 安裝前後分別執行 `ls /home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 既有項目（openspec-apply-change、openspec-archive-change、...、tutoring 等 15 個）必須完全相同；只能多出 4 個新項目

#### Scenario: 子目錄名稱無衝突
- **WHEN** 檢查新安裝的 4 個子目錄名稱
- **THEN** `grill-me`、`grilling`、`writing-great-skills`、`domain-modeling` 不在既有的 15 個子目錄名稱清單中

### Requirement: 安裝來源可追溯

系統 SHALL 保留 upstream repo URL 與對應路徑資訊，讓日後手動重新 vendor 時有明確依據；資訊可記錄於 commit message、proposal.md、design.md，或本 spec 的 requirement 內容。

#### Scenario: commit message 含 upstream 資訊
- **WHEN** 檢視 git log 此變更的 commit
- **THEN** commit message 必須提及來源 `mattpocock/skills`（commit message 格式由 commit 階段決定，本 spec 不強制）
