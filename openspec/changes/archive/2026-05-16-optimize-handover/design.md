## Context

目前的 `/handover` command 是一個單一的厚重模板，產生 HANDOVER.md 作為交接文件。問題在於：
1. 每次 handover 覆蓋前一份 HANDOVER.md，跨 session 的歷史遺失
2. 與 OpenSpec artifacts 完全脫節，兩邊的狀態可能不一致
3. 文件過長時 AI 難以有效消化
4. 新 session 需要手動要求 AI 讀取

OpenSpec artifacts（tasks.md、design.md、proposal.md）是持久層，HANDOVER.md 應該是 session 層的薄入口。

## Goals / Non-Goals

**Goals:**
- handover 根據有無 active change 自動切換模式
- 薄入口模式下同步更新 OpenSpec artifacts
- HANDOVER.md 使用漸進式披露，保持簡短
- 新 session 自動偵測並恢復 context

**Non-Goals:**
- 不改變 OpenSpec 的 artifact 結構
- 不處理多個 active change 的複雜場景（交由 AI 自行判斷或詢問使用者）
- 不改變 handover 的觸發方式（仍是 `/handover`）

## Decisions

### 1. 雙模式設計而非固定模板

偵測 `openspec/changes/*/proposal.md` 判斷是否有 active change。有 → 薄入口模式；沒有 → 完整模式。

**替代方案**: 單一模板用條件區塊。缺點是模板過於複雜，AI 容易混淆。

### 2. Artifact 更新採附加式，不覆蓋

- tasks.md：只將 `[ ]` 改為 `[x]`，不動其他內容
- design.md：在 Decisions 區段追加新決策
- proposal.md：僅在 scope 確實變動時更新

### 3. HANDOVER.md 維持在 project root

它是 session 層的東西，不屬於任何一個 change。放在 root 方便偵測。

### 4. CLAUDE.md 加入自動偵測規則

在 project `.claude/CLAUDE.md` 加一條規則，session 開始時偵測 HANDOVER.md 存在就自動讀取。比手動控制更可靠，且可通過 CLAUDE.md 的內容判斷是否要恢復 context。

### 5. 移除冗餘區段

Modified Files、Reference Commands、Dependencies 等資訊可從 git log 和 git diff 取得，不需要寫入 HANDOVER.md。

## Risks / Trade-offs

- **Artifact 更新可能破壞手動編輯的內容** → handover 更新時只做精確的 targeted edit（打勾、追加），不做全文件覆蓋
- **自動偵測 HANDOVER.md 在不相关 session 會干擾** → CLAUDE.md 規則加入「偵測到時讀取」，AI 讀完後自然判斷是否需要恢復，不需要就不會影響
- **純探索模式沒有持久層，HANDOVER.md 仍會覆蓋** → 這是預期行為，純探索的 context 只需要最近一次的
