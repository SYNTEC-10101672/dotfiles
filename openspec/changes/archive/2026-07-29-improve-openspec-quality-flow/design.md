## Context

這個 change 修改 OpenSpec workflow 的兩個關鍵階段（propose 與 apply），目的是讓 fresh AI session（apply 階段）能讀到 self-contained 的 tasks.md，並在實作完成後接受雙軸 code review。

### 跨 task 共用的環境事實

修改對應檔案與位置（fresh AI 不需另外查 codebase）:

- `~/.claude/skills/openspec-propose/SKILL.md`
  - 第 78-80 行: Step 4c「If an artifact requires user input (unclear context)」
  - 第 108 行: Guardrail「If context is critically unclear, ask the user - but prefer making reasonable decisions to keep momentum」← 致命反規則
  - 第 82-86 行: Step 5「Show final status」(將改編號為 Step 7)
- `~/.claude/skills/openspec-apply-change/SKILL.md`
  - 第 75 行起: Step 6「TDD 三階段實作流程」(Red / Green / Final)
  - 第 101 行起: Step 7「On completion or pause, show status」← 將改編號為 Step 8
- `~/.claude/CLAUDE.md`
  - 第 45 行: `## OpenSpec 規範` 段開頭
- `~/.claude/skills/openspec-code-review/` ← 全新目錄，目前不存在
- 既有 skills 目錄現有 13 個（`openspec-apply-change` / `openspec-archive-change` / `openspec-bulk-archive-change` / `openspec-continue-change` / `openspec-explore` / `openspec-ff-change` / `openspec-new-change` / `openspec-onboard` / `openspec-propose` / `openspec-sync-specs` / `openspec-tdd-verify` / `openspec-verify-change` / `tutoring`）

### 借鏡來源

Matt Pocock skills repo (`https://github.com/mattpocock/skills`, commit `2ab958093e83e0ec752e6c1c5932da465bf23e0c`):

- `skills/productivity/grilling/SKILL.md` - 提供「fact vs decision」規則（能在環境查到的事實必查、需要人決定的才問）
- `skills/engineering/code-review/SKILL.md` - 提供雙軸平行 sub-agents 設計（Standards + Spec）與 Fowler 12 smells baseline

## Goals / Non-Goals

**Goals:**

- propose 階段強制 fact lookup，產出無代名詞的 tasks.md
- apply 階段完成實作後，自動觸發雙軸 code review（Standards + Spec）
- code review 發現 CRITICAL 時進入 fix loop，fix 後重跑 Final phase 測試確認沒退化
- CLAUDE.md 加上規範，讓規則跨 session 持久化

**Non-Goals:**

- ❌ 不修改 `openspec-explore`（使用者決定 explore 維持發散性格）
- ❌ 不在 `openspec-apply` 加 Ambiguity Audit（使用者評估文件已審過，不需要 safety net）
- ❌ 不改變 `openspec-tdd-task-format` 的 T* 雙欄位格式（`## 測試` / `## 實作` 結構維持）
- ❌ 不改變 `openspec-tdd-verify` 的 Red/Green/Final 三階段邏輯（介面不變）
- ❌ 不改變 `openspec-verify-change`（仍是手動 review change 一致性的入口，職責與新 code-review skill 不同）
- ❌ 不引入 router skill（如 `openspec-ask`，留待後續 change）
- ❌ 不引入 CONTEXT.md 機制（留待後續 change）

## Decisions

### D1: Fact Lookup 放在 propose 而非 apply

**選擇**: 在 `openspec-propose` 加 Step 5（Fact Lookup）+ Step 6（Self-Containment Gate），原「Show final status」改編號為 Step 7。

**理由**:
- 使用者明確要求「規劃與實作分開，實作保留 fresh session」
- 在 propose 修正可讓源頭產出正確文件，所有後續 apply session 都受惠
- 放 apply 端是治標（每次 fresh AI 都要重做 audit），propose 是治本

**Alternatives 考慮**:
- 放 apply 端當 safety net → 棄，因使用者評估 propose 文件已審過不需要
- 兩端都放 → 棄，避免重複成本

### D2: 用 fact-vs-decision 規則取代「prefer decisions」反規則

**選擇**: 刪除 `openspec-propose/SKILL.md:108` 的「prefer making reasonable decisions to keep momentum」，替換為「fact 必查、decision 才問」規則。

**理由**:
- 反規則直接告訴 AI「自己腦補別打擾」，是代名詞滿天飛的元兇
- Matt 的 grilling skill 證明「fact 用查、decision 用問」是有效的紀律
- 規則簡單可執行：遇到名詞先查、查不到才問

**Alternatives 考慮**:
- 保留反規則只加 Fact Lookup → 棄，兩條規則會打架
- 用更複雜的 stance 描述 → 棄，簡單規則更易遵循

### D3: 雙軸 code review 用平行 sub-agents

**選擇**: `openspec-code-review` 內部用兩個平行 sub-agents（Standards + Spec），各自產出報告不合併。

**理由**:
- Standards（repo 慣例 + Fowler smells）與 Spec（是否符合 OpenSpec artifacts）是兩個正交視角
- 平行避免互相汙染（Matt code-review skill 明確指出：「one axis can mask the other」）
- 兩軸分開呈現讓使用者看到全貌，不是被 rerank 過的單一排序

**Alternatives 考慮**:
- 單軸 review → 棄，會漏掉其中一個視角的問題
- 序列式 review → 棄，慢且第一軸的結論會影響第二軸

### D4: Standards 軸用 CLAUDE.md「程式碼規範」段 + 固定 Fowler 12 baseline

**選擇**: Standards 軸的標準來源是：
1. `~/.claude/CLAUDE.md` 的「程式碼規範」段（使用者既有規範）
2. repo CODING_STANDARDS.md / CONTRIBUTING.md（若存在）
3. 固定 Fowler 12 smells baseline（sub-agent 必帶，無論 repo 是否有文件）

**理由**:
- CLAUDE.md 是現有 source of truth，不需新建
- Fowler 12 smells 是 Matt 驗證過的固定防線，即使 repo 沒寫文件也有基本把關
- 規則「repo 標準蓋過 smell baseline」避免誤報（repo 明確接受的 pattern 不 flag）

**Alternatives 考慮**:
- 只用 CLAUDE.md → 棄，無基本防線，repo 沒寫的東西沒人 review
- 只用 Fowler baseline → 棄，忽略既有規範

### D5: Fix Loop 重跑 Final phase 而非 Red+Green+Final 全部

**選擇**: code review 發現 CRITICAL 後 fix，重跑時只跑 `openspec-tdd-verify` 的 Final phase（全部 T*），不重跑 Red / Green。

**理由**:
- Final phase 已涵蓋全部 T*，等同 full test suite run
- Red phase 是「實作前確認失敗」的 gate，實作已存在不需要重跑
- Green phase 是 per-task 驗證，fix 後目標是確認「沒退化」而非「重新驗證每個 task」

**Alternatives 考慮**:
- 重跑全部三階段 → 棄，冗餘且 Red phase 在已有實作下無意義
- 只跑被 fix 影響的 T* → 棄，判定影響範圍是 heuristic 問題，Final phase 較安全

### D6: code-review 的「Spec source」用 OpenSpec change artifacts

**選擇**: Spec 軸比對來源是 `openspec/changes/<name>/` 下的 proposal / specs / design / tasks。

**理由**:
- 這是 OpenSpec workflow 的 source of truth
- 不需要外部 issue tracker（Matt 原版用 GitHub issue）
- 與 `openspec-verify-change` 職責區分：verify-change 是「一致性檢查」（單軸），新 code-review 是「Standards + Spec 雙軸」

**Alternatives 考慮**:
- 用 git commit message 中的 issue ref → 棄，dotfiles repo 不用 issue tracker
- 與 verify-change 合併 → 棄，破壞既有 skill 介面

## Risks / Trade-offs

- **[propose 變慢 30-50%]** → Mitigation: 換得 fresh AI apply 不卡，整體時間仍下降。使用者已知情並接受（explore 階段確認）
- **[Fact Lookup 對概念性 task（如設計新結構）可能過度要求]** → Mitigation: Self-Containment Gate 加但書「概念性 task 要附 schema/pseudocode/檔案結構，不是 prose」給予明確替代
- **[code-review 雙 sub-agent 平行增加 token 成本]** → Mitigation: 每軸限 400 字（Matt 原版相同上限），可控
- **[Fix Loop 理論上可能無限循環]** → Mitigation: CRITICAL 通常一次修完；使用者可中斷；WARNING/SUGGESTION 不阻塞
- **[Fowler 12 smells 可能誤報（heuristic 性質）]** → Mitigation: 規則明訂「有 documented repo standard 時 standard 蓋過 smell」「略過 tooling 已強制的東西」
- **[新 skill `openspec-code-review` 是 model-invoked 但無 trigger 測試]** → Mitigation: 透過 `openspec-apply-change` 的 Step 7 內部 prose invocation 觸發（"Run openspec-code-review"），等於 user-invoked 流程內部呼叫，不需依賴自動觸發
