# code-review

Upstream verbatim 的 `code-review` skill（來自 `https://github.com/mattpocock/skills`），並定義 `/opsx:apply` 完成實作後的 code review 觸發與 findings 分流流程。

## Purpose

提供 OpenSpec workflow 在 `opsx:apply` 完成後的品質把關。skill 本體為 Matt Pocock `code-review` 的 byte-identical vendor copy（內建 Standards / Spec 雙軸平行 sub-agents 流程），本 spec 只規範 vendor 一致性與 apply 流程的呼叫點、findings 分流、Fix Loop 行為。

## Requirements

### Requirement: code-review skill 為 upstream verbatim

`opencode/skills/code-review/` 目錄內容 MUST 與 `https://github.com/mattpocock/skills` main branch 的 `skills/engineering/code-review/` 完全一致（byte-identical，含 `SKILL.md` 與 `agents/`），MUST NOT 進行任何本地修改。日後同步上游更新 SHALL 以最新版直接覆蓋。

#### Scenario: 內容與 upstream 一致

- **WHEN** 比對 `opencode/skills/code-review/SKILL.md` 與 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/code-review/SKILL.md`
- **THEN** 兩者內容完全相同

#### Scenario: 同步為覆蓋操作

- **WHEN** upstream `skills/engineering/code-review/` 有新版本且執行同步
- **THEN** 本地目錄以 upstream 內容覆蓋，不產生本地 merge 或 patch

### Requirement: opsx:apply 完成實作後必須觸發 code review

`opencode/commands/opsx/apply.md` 的 Step 7（Code Review + Fix Loop）MUST 在所有 T* 通過 Final phase 後 invoke `code-review` skill，並於呼叫處提供三項 OpenSpec 適配資訊：

1. Spec source：active change 的 OpenSpec artifacts——`openspec/changes/<name>/proposal.md`、`openspec/changes/<name>/specs/`（所有 delta specs）、`openspec/changes/<name>/design.md`、`openspec/changes/<name>/tasks.md`
2. Fixed point：`git merge-base <change-start-commit> HEAD`
3. 無 issue tracker：跳過 tracker-based spec discovery，不提示執行 `/setup-matt-pocock-skills`

原「On completion or pause, show status」步驟維持編號 Step 8。

#### Scenario: apply.md Step 7 含 skill 引用與適配資訊

- **WHEN** 讀取 `opencode/commands/opsx/apply.md` 的 Step 7
- **THEN** 可見 invoke `code-review` skill 的指引，且同時提供 spec source（`openspec/changes/<name>/` artifacts）、fixed point（`git merge-base`）、無 issue tracker 三項資訊

#### Scenario: apply 完成後自動進入 code review

- **WHEN** `/opsx:apply` 流程的 Step 6 Final phase 全部 T* 通過
- **THEN** 流程 MUST 自動進入 Step 7（Code Review），MUST NOT 跳過直接顯示完成訊息

### Requirement: Code review findings 必須分流處理

`/opsx:apply` 流程對 `code-review` 的 findings MUST 分流：

- **CRITICAL**（Standards 或 Spec 軸）：詢問使用者是否修復；修復則進入 Fix Loop
- **WARNING / SUGGESTION**：列出但不阻塞，由使用者決定

#### Scenario: CRITICAL 詢問修復

- **WHEN** code review 回報任一軸的 CRITICAL finding
- **THEN** 流程 MUST 詢問使用者是否修復，不得靜默略過

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

### Requirement: AGENTS.md 必須記錄 apply 後必跑 code review 規範

全域指示檔 `opencode/AGENTS.md` MUST 包含「完成 `/opsx:apply` 後，必須執行 `code-review`（雙軸 sub-agents）通過才能建議 archive」精神的規範文字，skill 名使用 `code-review`（非 `openspec-code-review`）。

#### Scenario: AGENTS.md 包含必跑規範

- **WHEN** 讀取 `opencode/AGENTS.md`
- **THEN** MUST 可見提及 `code-review` 與 apply 後必跑、通過才能建議 archive 的規範文字
