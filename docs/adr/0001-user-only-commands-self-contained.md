---
status: accepted
---

# User-only 入口自包含，skills 僅留 dual-entry

mattpocock/skills 上游以 `disable-model-invocation` 區分 user-invoked / model-invoked skills，但實測（2026-09-22，opencode 1.18.22 + OmO 4.19.4）core 與 OmO 都不讀此 flag——所有附 description 的 skill 一律列在每個 session 的 system prompt。因此 user-only 入口（teach、handoff、wayfinder、improve-codebase-architecture、setup-matt-pocock-skills）改為自包含 `commands/*.md` 並刪除對應 `skills/<name>/`，把每個入口的 ambient 成本從兩條（skill listing + command listing）降為一條；grilling 與 domain-modeling 因內容共用（grill-me / grill-with-docs）、opsx 流程以 Skill tool 引用（domain-modeling）、以及 designed model-invocation，保留為 skills。

## Considered Options

- 維持 skill + 薄 wrapper（上游形狀）：放棄——上游 repo 根本沒有 wrapper command 層，「結構 parity」不成立；且 ambient 無法降低。
- `permission.skill: <name>: deny` 藏 skill：拒絕——deny 連 Skill tool 載入都擋掉，轉發會壞。

## Consequences

- 上游 sync 改為手動 diff 移植；更新時另開 session 評估範圍。
- teach、improve-codebase-architecture、setup-matt-pocock-skills 的附屬 formats / templates 以 fenced blocks 內聯進 command md；上游更新這些檔時需同步對應區塊。
- skill 附帶的 `agents/openai.yaml`（Codex harness 用，本環境無消費者）隨目錄刪除。
- `disable-model-invocation` 在本地語境視為無效裝飾；若未來 opencode / OmO 開始支援，可重新評估（supersede 本 ADR）。
