# Delta Spec: openspec-code-review

## MODIFIED Requirements

### Requirement: 新增 openspec-code-review skill

系統 MUST 提供 skill `dotfiles/opencode/skills/openspec-code-review/SKILL.md`（部署於 `~/.config/opencode/skills/openspec-code-review/SKILL.md`），提供雙軸平行 sub-agents 的 code review 能力。

skill description MUST 包含足夠 trigger 片段讓 model-invoked 自動觸發可行(包含「review a change」「review since」「code review」等 leading words)。

skill MUST 定義以下流程:

1. Pin the fixed point(使用 `git merge-base <change-start-commit> HEAD`)
2. Identify spec source(OpenSpec change artifacts:proposal / specs / design / tasks)
3. Identify standards sources(repo documented coding standards(CODING_STANDARDS.md / CONTRIBUTING.md)若有 + Fowler 12 smells baseline)
4. Spawn 兩個 sub-agents 平行(Standards + Spec,單一訊息 兩個 task 呼叫)
5. Aggregate 兩軸報告,MUST NOT 合併或重新排名

#### Scenario: skill 檔案存在且包含必要結構

- **WHEN** 讀取 `~/.config/opencode/skills/openspec-code-review/SKILL.md`
- **THEN** MUST 包含 frontmatter(name, description)、雙軸定義、5 步流程、Fowler 12 smells baseline 列表

#### Scenario: skill 可被 openspec-apply 內部 prose invocation 觸發

- **WHEN** `openspec-apply-change` 的 Step 7 執行「呼叫 `openspec-code-review` skill」
- **THEN** skill MUST 被載入並執行雙軸 review

### Requirement: Standards 軸必須使用 documented repo standards + Fowler 12 baseline

Standards sub-agent 的標準來源 MUST 為:

1. repo CODING_STANDARDS.md / CONTRIBUTING.md(若存在)
2. 固定 Fowler 12 smells baseline(sub-agent 必帶,無論 repo 是否有文件):
   - Mysterious Name
   - Duplicated Code
   - Feature Envy
   - Data Clumps
   - Primitive Obsession
   - Repeated Switches
   - Shotgun Surgery
   - Divergent Change
   - Speculative Generality
   - Message Chains
   - Middle Man
   - Refused Bequest

來源清單 MUST NOT 包含全域指示檔(`~/.config/opencode/AGENTS.md` 等 system prompt 材料)。

規則:

- repo documented standard 永遠蓋過 smell baseline(如 repo 明確接受某 smell,suppress)
- 每个 smell 是 heuristic(labelled),MUST NOT 當 hard violation
- 略過 tooling 已強制的東西(如 linter 已檢查的格式)

`openspec-apply-change` 引用 Standards axis CRITICAL severity 時 MUST 使用相同語言("violates a documented repo standard / major Fowler smell"),兩個 skill 不得使用不同字眼指稱同一軸。

#### Scenario: repo 標準覆蓋 smell baseline

- **WHEN** Standards sub-agent 發現一個 diff hunk 觸發「Primitive Obsession」smell,但 repo 的 CODING_STANDARDS.md 明確接受該 pattern
- **THEN** sub-agent MUST suppress 該 finding(不列入報告)

#### Scenario: Fowler baseline 在無 repo 文件時仍作用

- **WHEN** repo 沒有 CODING_STANDARDS.md 也沒有 CONTRIBUTING.md
- **THEN** Standards sub-agent MUST 仍以 Fowler 12 baseline 檢查(唯一來源),MUST NOT 回退到全域指示檔

#### Scenario: severity 用語跨文件對齊

- **WHEN** 讀取 `openspec-apply-change/SKILL.md` 的 Standards axis CRITICAL 定義
- **THEN** 表述 MUST 為 "violates a documented repo standard / major Fowler smell",與 `openspec-code-review` 的來源語言一致

## ADDED Requirements

### Requirement: AGENTS.md 必須記錄 apply 後必跑 code review 規範

全域指示檔 `opencode/AGENTS.md`（部署為 `~/.config/opencode/AGENTS.md`）的「OpenSpec 規範」段 MUST 包含以下規範:

> 完成 `opsx:apply` 後,必須執行 `openspec-code-review`(雙軸 sub-agents)通過才能建議 archive;若 code-review 有 fix,fix 後必須重跑 Final phase tests 確認沒退化

#### Scenario: AGENTS.md 包含必跑規範

- **WHEN** 讀取 `opencode/AGENTS.md` 的「OpenSpec 規範」段
- **THEN** MUST 可見「完成 opsx:apply 後必須執行 openspec-code-review」的規範文字

## REMOVED Requirements

### Requirement: CLAUDE.md 必須記錄 apply 後必跑 code review 規範

**Reason**: `~/.claude/CLAUDE.md` 隨搬遷改名為 `opencode/AGENTS.md`（部署於 `~/.config/opencode/AGENTS.md`）。

**Migration**: 由 ADDED requirement「AGENTS.md 必須記錄 apply 後必跑 code review 規範」承接，規範文字不變。
