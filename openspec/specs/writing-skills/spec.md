# writing-skills

三個 writing skills（`writing-fragments` / `writing-shape` / `writing-beats`）以 slash commands 形式存在於 `opencode/commands/`，並透過 `opencode-commands-symlink` 部署鏈提供給 OpenCode。

## Purpose

提供 3 個源自 `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/` 的 writing commands（`writing-fragments`、`writing-shape`、`writing-beats`），保留 upstream 內容（允許 frontmatter 轉換與 `$ARGUMENTS` 行兩項偏離），user-invoked 語意由 slash command 機制保證。
## Requirements
### Requirement: 三個 writing commands 存在於 opencode/commands

系統 SHALL 在 `opencode/commands/` 下提供 3 個 slash command 檔案：`writing-fragments.md`、`writing-shape.md`、`writing-beats.md`。每個檔案結構 SHALL 為：

1. YAML frontmatter：`description`（沿用 upstream 原句）、`argument-hint`（writing 系列：`[raw material path]` 或 `[fragments-save-path]`）
2. `$ARGUMENTS` 行：`writing-fragments.md` 為 `Fragments save path: $ARGUMENTS`；`writing-beats.md` 與 `writing-shape.md` 為 `Raw material file: $ARGUMENTS`
3. Body：`<what-to-do>` 與 `<supporting-info>` 內容自 upstream `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/<skill>/SKILL.md` 原文照搬（僅略過 skill frontmatter）

除了 frontmatter 轉換與新增的 `$ARGUMENTS` 行，body 內容 SHALL 與 upstream `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/<skill>/SKILL.md` 的 body 一致（允許的偏離僅限此兩項，記錄於 design.md）。

`opencode/skills/` 下 SHALL 不再有 `writing-fragments/`、`writing-shape/`、`writing-beats/` 目錄。

#### Scenario: 3 個 command 檔案存在於 opencode/commands/
- **WHEN** 執行 `ls opencode/commands/ | grep writing-`
- **THEN** 列出 `writing-fragments.md`、`writing-beats.md`、`writing-shape.md`

#### Scenario: 舊 skill 目錄已移除
- **WHEN** 執行 `ls opencode/skills/ | grep writing-`
- **THEN** 只列出 `writing-for-agents`（三個遷移的 skill 目錄不存在）

#### Scenario: frontmatter 為 command 格式
- **WHEN** 檢查 3 個 command 檔案的 YAML frontmatter
- **THEN** 含 `description` 與 `argument-hint` 欄位；不含 `name` 與 `disable-model-invocation`

#### Scenario: body 與 upstream 一致（允許偏離除外）
- **WHEN** 比對 `opencode/commands/writing-beats.md` 的 `<what-to-do>` / `<supporting-info>` 區塊與 upstream `skills/in-progress/writing-beats/SKILL.md` 對應區塊
- **THEN** 內容逐字一致（frontmatter 與 `$ARGUMENTS` 行除外）

### Requirement: writing commands 透過 opencode-commands-symlink 部署

三個 writing commands SHALL 透過既有部署鏈生效：`opencode-commands-symlink`（`opencode/commands` → `~/.config/opencode/commands`）。user-invoked 語意 SHALL 由 slash command 機制本身保證（commands 只能由使用者觸發），不再依賴 `disable-model-invocation` flag。

#### Scenario: OpenCode 部署透通
- **WHEN** 執行 `ls ~/.config/opencode/commands/ | grep writing-`
- **THEN** 列出 `writing-fragments.md`、`writing-beats.md`、`writing-shape.md`

#### Scenario: command 檔不含 skill 殘留標記
- **WHEN** 對 3 個 command 檔執行 `grep -l "disable-model-invocation" opencode/commands/writing-*.md`
- **THEN** 無匹配（user-invoked 由 command 機制保證，無需 flag）

