## ADDED Requirements

### Requirement: 新增 openspec-code-review skill

系統 MUST 新增 skill `~/.claude/skills/openspec-code-review/SKILL.md`，提供雙軸平行 sub-agents 的 code review 能力。

skill description MUST 包含足夠 trigger 片段讓 model-invoked 自動觸發可行（包含「review a change」「review since」「code review」等 leading words）。

skill MUST 定義以下流程：

1. Pin the fixed point（使用 `git merge-base <change-start-commit> HEAD`）
2. Identify spec source（OpenSpec change artifacts：proposal / specs / design / tasks）
3. Identify standards sources（CLAUDE.md 程式碼規範段 + repo CODING_STANDARDS.md 若有 + Fowler 12 smells baseline）
4. Spawn 兩個 sub-agents 平行（Standards + Spec，單一訊息 兩個 task 呼叫）
5. Aggregate 兩軸報告，MUST NOT 合併或重新排名

#### Scenario: skill 檔案存在且包含必要結構

- **WHEN** 讀取 `~/.claude/skills/openspec-code-review/SKILL.md`
- **THEN** MUST 包含 frontmatter（name, description）、雙軸定義、5 步流程、Fowler 12 smells baseline 列表

#### Scenario: skill 可被 openspec-apply 內部 prose invocation 觸發

- **WHEN** `openspec-apply-change` 的 Step 7 執行「呼叫 `openspec-code-review` skill」
- **THEN** skill MUST 被載入並執行雙軸 review

### Requirement: Apply 完成實作後必須觸發 code review

`openspec-apply-change/SKILL.md` MUST 在 Step 6（TDD 三階段）之後、原 Step 7（顯示狀態）之前，新增「Step 7 Code Review + Fix Loop」。

觸發條件：所有 T* 通過 Final phase。

Step 7 MUST 呼叫 `openspec-code-review` skill 進行雙軸 review，並根據 findings 分流處理：

- **CRITICAL**（Standards 或 Spec）：詢問使用者是否修，修則進 Fix Loop
- **WARNING / SUGGESTION**：列出但不阻塞，由使用者決定

原 Step 7「On completion or pause, show status」MUST 改編號為 Step 8。

#### Scenario: apply 完成後自動進入 code review

- **WHEN** `openspec-apply-change` 的 Step 6 Final phase 全部 T* 通過
- **THEN** 流程 MUST 自動進入 Step 7（Code Review），MUST NOT 跳過直接顯示完成訊息

#### Scenario: 原 Step 7 改編號為 Step 8

- **WHEN** 讀取 `openspec-apply-change/SKILL.md`
- **THEN** 「On completion or pause, show status」MUST 標示為 Step 8（原為 Step 7）

### Requirement: Code review 必須以雙軸平行 sub-agents 執行

`openspec-code-review` MUST 在單一訊息中同時 spawn 兩個 sub-agent（使用 `general-purpose` subagent type）：

- **Standards sub-agent**：檢查 diff 是否違反 CLAUDE.md 程式碼規範 + Fowler 12 smells baseline。每條 finding 區分 hard violation vs judgement call。有 documented repo standard 時，standard 蓋過 smell baseline。略過 tooling 已強制的東西。400 字內。
- **Spec sub-agent**：檢查 diff 是否 faithful 實作 OpenSpec change artifacts（proposal / specs / design / tasks）。找出「spec 要求但缺漏」「scope creep」「實作錯誤」。每條 quote spec line。400 字內。

兩軸報告 MUST 各自獨立呈現（`## Standards` 與 `## Spec`），MUST NOT 合併或重新排名。

#### Scenario: 兩個 sub-agent 平行執行

- **WHEN** `openspec-code-review` 進入 Step 4（spawn sub-agents）
- **THEN** MUST 在單一 assistant message 中同時發出兩個 task tool call（不可序列執行）

#### Scenario: 兩軸報告分開呈現

- **WHEN** aggregate 階段產出最終報告
- **THEN** 報告 MUST 有「## Standards」與「## Spec」兩個獨立段，MUST NOT 有「合併排名」或「單一 winner」

### Requirement: Standards 軸必須使用 CLAUDE.md + Fowler 12 baseline

Standards sub-agent 的標準來源 MUST 包含：

1. `~/.claude/CLAUDE.md` 的「程式碼規範」段（讀後再改 / 精準產出 / 最小變更 / 等）
2. repo CODING_STANDARDS.md / CONTRIBUTING.md（若存在）
3. 固定 Fowler 12 smells baseline（sub-agent 必帶，無論 repo 是否有文件）：
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

規則：

- repo documented standard 永遠蓋過 smell baseline（如 repo 明確接受某 smell，suppress）
- 每个 smell 是 heuristic（labelled），MUST NOT 當 hard violation
- 略過 tooling 已強制的東西（如 linter 已檢查的格式）

#### Scenario: repo 標準覆蓋 smell baseline

- **WHEN** Standards sub-agent 發現一個 diff hunk 觸發「Primitive Obsession」smell，但 repo 的 CODING_STANDARDS.md 明確接受該 pattern
- **THEN** sub-agent MUST suppress 該 finding（不列入報告）

#### Scenario: Fowler baseline 在無 repo 文件時仍作用

- **WHEN** repo 沒有 CODING_STANDARDS.md 也沒有 CONTRIBUTING.md
- **THEN** Standards sub-agent MUST 仍以 CLAUDE.md 程式碼規範段 + Fowler 12 baseline 兩個來源檢查

### Requirement: Spec 軸必須對比 OpenSpec change artifacts

Spec sub-agent 的比對來源 MUST 為當前 change 的 OpenSpec artifacts：

- `openspec/changes/<name>/proposal.md`
- `openspec/changes/<name>/specs/<capability>/spec.md`（所有 delta specs）
- `openspec/changes/<name>/design.md`
- `openspec/changes/<name>/tasks.md`

sub-agent MUST 找出三類問題：

1. spec 要求但實作缺漏或部分實作
2. diff 中存在 spec 未要求的行為（scope creep）
3. 實作看起來錯誤（與 spec 描述不符）

每條 finding MUST quote 對應的 spec line。

#### Scenario: 找出 spec 要求但缺漏

- **WHEN** Spec sub-agent 發現 proposal.md 列出「支援 dark mode」但 diff 中無相關實作
- **THEN** finding MUST 列出，並 quote proposal.md 的對應行

#### Scenario: 找出 scope creep

- **WHEN** Spec sub-agent 發現 diff 中新增了一個 spec 未提到的 config 選項
- **THEN** finding MUST 列出標為 scope creep，並指出 spec 中無對應要求

### Requirement: Fix Loop 必須重跑 Final phase 測試

當 code review 有 CRITICAL 被 fix 時，MUST 進入 Fix Loop：

1. 套用修復
2. 重新呼叫 `openspec-tdd-verify` skill，傳入 Final phase（執行所有 T*）
3. 全綠 → 進 Step 8（顯示狀態）
4. 仍有失敗 → 回 Fix Loop

MUST NOT 重跑 Red phase 或 Green phase（Final phase 已涵蓋全 T*，等同 full test suite run）。

#### Scenario: fix 後重跑 Final phase 全綠

- **WHEN** Fix Loop 套用修復後，重跑 Final phase 所有 T* 通過
- **THEN** 流程 MUST 進入 Step 8（顯示狀態），可建議 archive

#### Scenario: fix 後 Final phase 仍失敗

- **WHEN** Fix Loop 套用修復後，重跑 Final phase 有 T* 失敗
- **THEN** 流程 MUST 回到 Fix Loop 步驟 a（繼續修），MUST NOT 直接跳到 Step 8

### Requirement: CLAUDE.md 必須記錄 apply 後必跑 code review 規範

`~/.claude/CLAUDE.md` 的「OpenSpec 規範」段 MUST 新增以下規範：

> 完成 `opsx:apply` 後，必須執行 `openspec-code-review`（雙軸 sub-agents）通過才能建議 archive；若 code-review 有 fix，fix 後必須重跑 Final phase tests 確認沒退化

#### Scenario: CLAUDE.md 包含必跑規範

- **WHEN** 讀取 `~/.claude/CLAUDE.md` 的「OpenSpec 規範」段
- **THEN** MUST 可見「完成 opsx:apply 後必須執行 openspec-code-review」的規範文字
