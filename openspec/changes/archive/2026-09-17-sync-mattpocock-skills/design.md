# Design: sync-mattpocock-skills

## Context

- Upstream repo：`https://github.com/mattpocock/skills` main branch。路徑對應：
  - `skills/productivity/grilling/` → `opencode/skills/grilling/`
  - `skills/productivity/writing-for-agents/` → `opencode/skills/writing-for-agents/`
  - `skills/engineering/domain-modeling/` → `opencode/skills/domain-modeling/`
  - `skills/engineering/code-review/` → `opencode/skills/code-review/`（新增）
- 現況差異（已 diff 驗證）：`grilling` 為舊行為版（一次一題）；`domain-modeling` = upstream 減 ADR（commit `6526874` 拔除）；`writing-for-agents` 僅標點風格差異；`openspec-code-review` 為 Matt 舊版濃縮改編（Fowler 12 smells 只有名字、spec source 寫死 OpenSpec 路徑）。
- `opencode/commands/opsx/apply.md` line 98 現為 `` Invoke `openspec-code-review` skill to review the diff with parallel sub-agents. ``
- Pre-existing drifts：`openspec/specs/mattpocock-skills/spec.md` 要求 `domain-modeling/ADR-FORMAT.md` 存在（現實已刪）；`openspec/specs/openspec-code-review/spec.md` 要求 `opencode/AGENTS.md` 記錄必跑規範（現實從未寫入）。

## Goals / Non-Goals

**Goals:**
- 4 個 vendor skills（`grilling`、`writing-for-agents`、`domain-modeling`、`code-review`）與 upstream main **byte-identical**
- OpenSpec 適配（spec source、fixed point、無 tracker）集中於 `opsx/apply.md` 呼叫處，vendor 檔案零本地修改
- 修正兩個 pre-existing spec drift（`ADR-FORMAT.md`、AGENTS.md 規範行）

**Non-Goals:**
- 不建 sync 機制（manifest / `make skills-sync`，使用者明確排除；未來同步以手動覆蓋 + `diff` 驗證）
- 不移植新 skills（`prototype`、`teach`、`retro`、`research`、`to-tickets`、`implement`、`tdd` 等，屬後續變更）
- 不動 `opencode/commands/` 既有檔案（`opsx/apply.md` 除外）；`grill-me.md`、`grill-with-docs.md` 已同步、`handover.md` 為客製品，皆不動
- 不廢棄、不改動 `openspec-tdd-verify`、`openspec-artifact-review`、`openspec-sync-specs`、`tutoring`

## Decisions

### D1: Vendor verbatim 原則（含 `agents/` 目錄）
Vendor skill 目錄一律 byte-identical 複製（含 `agents/openai.yaml`），同步 = 覆蓋，零 merge。`agents/` 保留的依據：`openspec/specs/mattpocock-skills/spec.md` 明訂 `agents/openai.yaml` 必須存在——先前討論中「不帶 agents/」的暫定決定讓位給既有 spec。本地 patch（對照 `6526874` 的 ADR 拔除）已被證實是 sync pain 的來源，本設計終結該模式。

### D2: OpenSpec 適配在 call site，不在 skill
Matt `code-review` step 2（spec source 偵測）本有「a path the user passed as an argument」分支：`opsx:apply` 的 Step 7 呼叫處直接提供三項資訊——(a) spec source 為 active change artifacts（`openspec/changes/<name>/`）、(b) fixed point 為 `git merge-base <change-start-commit> HEAD`、(c) 無 issue tracker（跳過 tracker-based discovery，不觸發 `/setup-matt-pocock-skills` 提示）。skill 的 `description` 不加 `/opsx:apply` 觸發分支——apply.md 是 by-name invocation，不依賴 model-invoked 觸發。

### D3: ADR 恢復 = 直接覆蓋（撤銷 `6526874`）
拔 ADR 的理由（decisions live in design.md）隨 workflow 願景轉向（評估 Matt workflow）而不再成立；upstream 最新版即含 ADR 支援（`ADR-FORMAT.md` + "Offer ADRs sparingly" 三條件），覆蓋即恢復，同時修復 `mattpocock-skills` spec 的 drift。

### D4: Capability 更名 `openspec-code-review` → `code-review`
Skill 更名後 capability 名若沿用舊名將永遠錯位。以 REMOVED（舊 capability 全部 requirements）+ ADDED（新 capability `code-review`）平移：apply 後觸發、findings 分流、Fix Loop、AGENTS.md 規範等 contract 原文平移，skill 結構 requirements 改為「upstream verbatim」導向。

### D5: AGENTS.md 補必跑規範
`opencode/AGENTS.md` 補一行「完成 `/opsx:apply` 後必須執行 `code-review`」規範（skill 名用新名），修正 pre-existing drift。

### D6: `grilling` 行為變更（一輪多題）為接受的前件
互動節奏由「一次一題」改為「一輪多題帶建議答案」，使用者已同意試用；若需「每輪上限 N 題」之類約束，屬未來變更（且將違反 D1 verbatim 原則，屆時需重新設計）。

## Risks / Trade-offs

- `grilling` 行為變更需適應期（D6）。
- `code-review` 於非 apply 場景手動呼叫（如 "review since main"）且 repo 無 tracker 時，會走 skill 的 fallback 問使用者 spec 位置——可接受，skill 內建此分支。
- 刪除 `openspec-code-review` 後若有未掃到的殘留引用會 dangling——以 T* 全 `opencode/` grep 驗證歸零。
