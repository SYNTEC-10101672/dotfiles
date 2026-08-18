# writing-skills

從 `mattpocock/skills` main 分支 `skills/in-progress/` vendor 三個 writing skills 到 dotfiles 的 Claude skills 目錄，並透過既有 symlink 部署。

## Purpose

提供 3 個來自 `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/` 的 writing skills（`writing-fragments`、`writing-shape`、`writing-beats`），保留 upstream 內容與 user-invoked 分類，且不影響既有 skills。

## Requirements

### Requirement: 三個 writing skill 檔案存在於正確路徑

系統 SHALL 在 `dotfiles/claude/skills/` 下提供 3 個 skill 子目錄，每個子目錄必須包含 `SKILL.md` 與 `agents/openai.yaml`，內容來自 `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/` 對應路徑，且與 upstream 完全一致（vendor copy 不修改原檔）。

子目錄與 upstream 對應：
- `writing-fragments/SKILL.md` + `writing-fragments/agents/openai.yaml` ← `skills/in-progress/writing-fragments/`
- `writing-shape/SKILL.md` + `writing-shape/agents/openai.yaml` ← `skills/in-progress/writing-shape/`
- `writing-beats/SKILL.md` + `writing-beats/agents/openai.yaml` ← `skills/in-progress/writing-beats/`

#### Scenario: 3 個 skill 目錄與 6 個檔案都存在
- **WHEN** 安裝完成後檢查 `/home/syntec/personal/dotfiles/claude/skills/`
- **THEN** 必須看到 `writing-fragments/`、`writing-shape/`、`writing-beats/` 3 個子目錄，且每個子目錄內都有 `SKILL.md` 與 `agents/openai.yaml`

#### Scenario: SKILL.md 內容與 upstream 完全一致
- **WHEN** 對每個 skill 執行 `diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/<skill>/SKILL.md) claude/skills/<skill>/SKILL.md`
- **THEN** diff 必須無輸出（內容 byte-level 相同）

#### Scenario: agents/openai.yaml 內容與 upstream 完全一致
- **WHEN** 對每個 skill 執行 `diff <(curl -s https://raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/<skill>/agents/openai.yaml) claude/skills/<skill>/agents/openai.yaml`
- **THEN** diff 必須無輸出

### Requirement: Skills 透過既有 symlink 部署並保留 user-invoked 分類

三個 writing skills MUST 透過 `claude-config-symlink` 提供的 `~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/` symlink 部署，在下一個 Claude Code / opencode session 自動可用。三者的 invocation 分類 MUST 維持 upstream 的 user-invoked 設計。

#### Scenario: symlink 透通顯示三個新 skill
- **WHEN** 安裝完成後執行 `ls ~/.claude/skills/ | grep writing-`
- **THEN** 必須列出 `writing-fragments`、`writing-shape`、`writing-beats`（透過 symlink 透通顯示）

#### Scenario: 三者皆為 user-invoked（disable-model-invocation: true）
- **WHEN** 檢查三個 `SKILL.md` 的 YAML frontmatter
- **THEN** 每個都必須包含 `disable-model-invocation: true`（AI 不可自行啟動，只能由使用者以 slash command 召喚）

#### Scenario: frontmatter 具備 name 與 description 欄位
- **WHEN** 解析三個 `SKILL.md` 的 YAML frontmatter
- **THEN** 每個都必須有 `name` 與 `description` 欄位（與既有 skills 格式一致，供 skill 解析器讀取）

### Requirement: 不影響既有 skills

安裝三個 writing skills MUST NOT 修改或移除 `dotfiles/claude/skills/` 下任何既有檔案（含 `mattpocock-skills` capability 所規範的 5 個 skills）。

#### Scenario: 既有 skills 完整無變動
- **WHEN** 安裝前後各執行一次 `ls ~/.claude/skills/`
- **THEN** 既有項目全部仍在，僅新增 `writing-fragments`、`writing-shape`、`writing-beats` 3 個項目
