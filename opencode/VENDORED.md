# VENDORED

第三方 skills/commands 的 vendor 基準線記錄（matt 系列、humanlayer 系列）：每個 vendored 項目的 upstream path、版本基準、包裝形式與本地客製。包裝形式詞彙（model skill、dual-entry、user-only 入口、wrapper command）定義於 repo 根目錄 `GLOSSARY.md`；user-only 入口自包含化的決策見 ADR-0001。

**目前基準：[mattpocock/skills](https://github.com/mattpocock/skills) v1.3.1**（升級方式：checkout upstream tag 後逐項 diff，僅回補記錄於此的客製）。

## Skills（`opencode/skills/`）

Upstream frontmatter 保持原文（含 `name:`）；目錄內含 upstream 的參考檔。狀態「zero-diff」= 與 upstream v1.3.1 對應目錄 `diff -r` 為零。

| skill | upstream path | 形式 | v1.3.1 狀態 | 客製 |
|---|---|---|---|---|
| codebase-design | `skills/engineering/codebase-design` | model skill | SKILL.md + 參考檔同步 | `agents/openai.yaml` 未 vendor |
| code-review | `skills/engineering/code-review` | model skill | zero-diff | 無 |
| diagnosing-bugs | `skills/engineering/diagnosing-bugs` | model skill | zero-diff | 無 |
| domain-modeling | `skills/engineering/domain-modeling` | model skill（dual-entry 內容 home） | zero-diff | 無（`CONTEXT-FORMAT.md` 已隨 v1.3.1 改名 `GLOSSARY-FORMAT.md`，見 ADR-0004） |
| grilling | `skills/productivity/grilling` | model skill（dual-entry，grill-me / grill-with-docs 的內容來源） | zero-diff | 無 |
| prototype | `skills/engineering/prototype` | model skill | SKILL.md + 參考檔同步 | `agents/openai.yaml` 未 vendor |
| research | `skills/engineering/research` | model skill | zero-diff | 無 |
| tdd | `skills/engineering/tdd` | model skill | zero-diff | 無（v1.3.1 sync 補回 `agents/openai.yaml`） |
| writing-for-agents | `skills/productivity/writing-for-agents` | model skill | zero-diff | 無 |

## Commands（`opencode/commands/`）

User-only 入口的改裝規則（ADR-0001）：剝除 `name:` 與 `disable-model-invocation`，其餘內文保持 upstream 原文；需要參數的加 `argument-hint` 與 `$ARGUMENTS` 帶入行；upstream 引用的獨立參考檔以 `````markdown` fenced block 內聯為附錄，`[file](./file.md)` 連結改寫為 in-page anchor。

| command | upstream path | 形式 | v1.3.1 狀態 | 客製 |
|---|---|---|---|---|
| grill-me | `skills/productivity/grill-me` | wrapper command | — | 薄轉發：`$ARGUMENTS` → Skill tool `grilling`（body 非 upstream 原文） |
| grill-with-docs | `skills/engineering/grill-with-docs` | wrapper command | — | 薄轉發：`$ARGUMENTS` → Skill tool `grilling` + `domain-modeling`（body 非 upstream 原文） |
| handoff | `skills/productivity/handoff` | user-only 自包含 | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（next session purpose） |
| implement | `skills/engineering/implement` | user-only 自包含 | body 原文同步 | 僅剝 frontmatter |
| implement-spec | `skills/engineering/implement-spec` | user-only 自包含 | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（spec or tickets） |
| improve-codebase-architecture | `skills/engineering/improve-codebase-architecture` | user-only 自包含 | body + 附錄同步 | 剝 frontmatter；`HTML-REPORT.md` 內聯為 `#html-report-format` 附錄（內容逐字一致） |
| retro | `skills/engineering/retro` | user-only 自包含 | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（session，預設 current） |
| setup-matt-pocock-skills | `skills/engineering/setup-matt-pocock-skills` | user-only 自包含 | body + 附錄同步 | 剝 frontmatter；5 個參考檔（issue-tracker github/gitlab/local、triage-labels、domain）內聯為附錄（內容逐字一致，anchor 連結化） |
| teach | `skills/productivity/teach` | user-only 自包含 | body + 附錄同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`；4 個 format 附錄內聯（內容逐字一致；RESOURCES-FORMAT 內 `[SKILL.md](./SKILL.md)` 一處連結改寫為 `#philosophy` in-page anchor） |
| to-questionnaire | `skills/productivity/to-questionnaire` | user-only 自包含 | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（questionnaire topic） |
| to-spec | `skills/engineering/to-spec` | user-only 自包含 | body 原文同步 | 僅剝 frontmatter |
| to-tickets | `skills/engineering/to-tickets` | user-only 自包含 | body 原文同步 | 僅剝 frontmatter |
| wait-what | `skills/productivity/wait-what` | user-only 自包含 | body 原文同步 | 僅剝 frontmatter（無參數語意，不加 `argument-hint`） |
| wayfinder | `skills/engineering/wayfinder` | user-only 自包含 | body 原文同步 | 僅剝 frontmatter |
| writing-beats | `skills/in-progress/writing-beats` | user-only 自包含（upstream in-progress bucket） | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（raw material path） |
| writing-fragments | `skills/in-progress/writing-fragments` | user-only 自包含（upstream in-progress bucket） | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（fragments-save-path） |
| writing-shape | `skills/in-progress/writing-shape` | user-only 自包含（upstream in-progress bucket） | body 原文同步 | 剝 frontmatter；`argument-hint` + `$ARGUMENTS`（raw material path） |

## humanlayer 系列（`opencode/commands/`）

**來源：[humanlayer/skills](https://github.com/humanlayer/skills)** main @ `bba9d13`（2026-09-12；upstream 無 release tag，以 commit 為基準，升級 = 對 commit diff）。

| command | upstream path | 形式 | 客製 |
|---|---|---|---|
| show-me | `plugins/show-me/skills/show-me/SKILL.md` | user-only 自包含 | 剝 `name:`/`disable-model-invocation`，改掛 opencode command `description`；加 terminal 環境說明行（inline Mermaid 不渲染）；Mermaid inline 節改寫為 .md artifact（`mkdir -p /tmp/opencode/show-me`、寫 `{description}.md`、印路徑 — VSCode markdown preview 觀看、GitHub-paste-ready）；HTML artifact 同目錄寫 `{description}.html` + 印路徑、移除 `open`（headless server）；text 格式、diff、guidance 保持 upstream 原文 |

## 暫不採用

| upstream skill | 理由 |
|---|---|
| `engineering/ask-matt` | upstream 的 user-invoked router（指引該用哪個 skill）；本環境 skills 由 OmO 分類排程、總覽即本檔，router 無額外價值 |
| `engineering/pr` | PR body 撰寫（model-invoked）；PR 產出情境罕見，需要時再 vendor |
| `engineering/wizard` | 產生互動式 bash wizard 引導人工步驟（provisioning、credentials）；目前無對應使用場景 |
| `engineering/triage` | issue 分診狀態機（五個 triage label）；本環境 issue tracker 為 local markdown（`.scratch/`，狀態以 `Status:` 行記錄，見 `docs/agents/issue-tracker.md`），label 體系用不上 |

## 自製（非 vendored，不在 vendor 基準內）

- `commands/commit`、`commands/eli5`：自製 command。

## 注意事項

- wrapper command（grill-me、grill-with-docs）的 body 是本地薄轉發，升級時不受 upstream body diff 影響，但轉發目標 skill（grilling、domain-modeling）的內容要同步。
- user-only 入口附錄以 `````markdown` fence 內聯；upstream 更新參考檔時需同步對應附錄區塊（ADR-0001 記錄的後果）。
