# Delta Spec: writing-skills

三個 writing skills（`writing-fragments` / `writing-shape` / `writing-beats`）從 `claude/skills/` 遷移至 `claude/commands/` slash commands，user-invoked 語意改由 command 機制保證。

## MODIFIED Requirements

### Requirement: 三個 writing skill 檔案存在於正確路徑

系統 SHALL 在 `claude/commands/` 下提供 3 個 slash command 檔案：`writing-fragments.md`、`writing-shape.md`、`writing-beats.md`。每個檔案結構 SHALL 為：

1. YAML frontmatter：`description`（沿用 upstream 原句）、`argument-hint`（writing 系列：`[raw material path]` 或 `[fragments-save-path]`）
2. `$ARGUMENTS` 行：`writing-fragments.md` 為 `Fragments save path: $ARGUMENTS`；`writing-beats.md` 與 `writing-shape.md` 為 `Raw material file: $ARGUMENTS`
3. Body：`<what-to-do>` 與 `<supporting-info>` 內容自 upstream `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/<skill>/SKILL.md` 原文照搬（僅略過 skill frontmatter）

除了 frontmatter 轉換與新增的 `$ARGUMENTS` 行，body 內容 SHALL 與 upstream `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/<skill>/SKILL.md` 的 body 一致（允許的偏離僅限此兩項，記錄於 design.md）。

`claude/skills/` 下 SHALL 不再有 `writing-fragments/`、`writing-shape/`、`writing-beats/` 目錄。

#### Scenario: 3 個 command 檔案存在於 claude/commands/
- **WHEN** 執行 `ls claude/commands/ | grep writing-`
- **THEN** 列出 `writing-fragments.md`、`writing-beats.md`、`writing-shape.md`

#### Scenario: 舊 skill 目錄已移除
- **WHEN** 執行 `ls claude/skills/ | grep writing-`
- **THEN** 只列出 `writing-for-agents`（三個遷移的 skill 目錄不存在）

#### Scenario: frontmatter 為 command 格式
- **WHEN** 檢查 3 個 command 檔案的 YAML frontmatter
- **THEN** 含 `description` 與 `argument-hint` 欄位；不含 `name` 與 `disable-model-invocation`

#### Scenario: body 與 upstream 一致（允許偏離除外）
- **WHEN** 比對 `claude/commands/writing-beats.md` 的 `<what-to-do>` / `<supporting-info>` 區塊與 upstream `skills/in-progress/writing-beats/SKILL.md` 對應區塊
- **THEN** 內容逐字一致（frontmatter 與 `$ARGUMENTS` 行除外）

### Requirement: Skills 透過既有 symlink 部署並保留 user-invoked 分類

三個 writing commands SHALL 透過既有部署鏈生效：`claude-config-symlink`（`claude/commands` → `~/.claude/commands`）與 `opencode-commands-symlink`（`claude/commands` → `~/.config/opencode/commands`）。user-invoked 語意 SHALL 由 slash command 機制本身保證（commands 只能由使用者觸發），不再依賴 `disable-model-invocation` flag。

#### Scenario: Claude Code 部署透通
- **WHEN** 執行 `ls ~/.claude/commands/ | grep writing-`
- **THEN** 列出 `writing-fragments.md`、`writing-beats.md`、`writing-shape.md`

#### Scenario: OpenCode 部署透通
- **WHEN** 執行 `ls ~/.config/opencode/commands/ | grep writing-`
- **THEN** 列出 `writing-fragments.md`、`writing-beats.md`、`writing-shape.md`

#### Scenario: command 檔不含 skill 殘留標記
- **WHEN** 對 3 個 command 檔執行 `grep -l "disable-model-invocation" claude/commands/writing-*.md`
- **THEN** 無匹配（user-invoked 由 command 機制保證，無需 flag）

## REMOVED Requirements

### Requirement: 不影響既有 skills
**Reason**: 此 requirement 保護的安裝一次性 context（vendor 三個 skills 到 `claude/skills/`）已結束；遷移後此 capability 的檔案不在 `claude/skills/`，對 skills 目錄的保護由 `mattpocock-skills` capability 的對應 requirement 涵蓋。
**Migration**: 無需遷移 — 對 `claude/skills/` 的完整性要求由 `mattpocock-skills` spec 繼續規範。
