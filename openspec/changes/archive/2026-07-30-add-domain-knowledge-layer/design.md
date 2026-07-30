## Context

### 環境事實

- 全域 CLAUDE.md：`dotfiles/claude/CLAUDE.md`，透過 `claude-config-symlink` capability symlink 到 `~/.claude/CLAUDE.md`，每個 Claude Code / opencode session 自動載入
- skills 目錄：`dotfiles/claude/skills/`，symlink 到 `~/.claude/skills/`
- grill-with-docs upstream 來源：`https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs`，包含 `SKILL.md` 與 `agents/openai.yaml` 兩個檔案
- 既有相關 skills（均已在 `mattpocock-skills` capability 中規範）：
  - `grill-me`（user-invoked, `disable-model-invocation: true`）：純 grilling session，不落地任何檔案
  - `grilling`（model-invoked）：訪談引擎，是 grill-me 與 grill-with-docs 的共用核心
  - `domain-modeling`（model-invoked）：寫入 `CONTEXT.md` 與 ADR，含 `CONTEXT-FORMAT.md`、`ADR-FORMAT.md` 參考檔
- 目前 `mattpocock-skills` capability（`openspec/specs/mattpocock-skills/spec.md`）規範 4 個 vendor skill，多個 requirement 硬編碼「4 個」與具體名稱清單

## Goals / Non-Goals

**Goals:**
- 建立 cross-change 領域知識層的生產端（grill-with-docs）與消費端（CLAUDE.md 規則）
- grill-with-docs 作為「正式建立知識」的明確入口，保證 domain-modeling 在 grill session 中活躍
- 消費規則靠 CLAUDE.md 硬載入，零額外 setup、零間接層

**Non-Goals:**
- 不改 domain-modeling 的 invocation 分類（維持 model-invoked，保留及時捕捉）
- 不移植 mattpocock 的 setup-matt-pocock-skills 或 `docs/agents/domain.md` 三段鏈
- 不為 openspec 工作流加 CONTEXT.md 整合（知識層獨立於 openspec）
- 不修改 `grill-me`、`grilling`、`domain-modeling` 任何既有 skill 的內容

## Decisions

### Decision 1: grill-with-docs 直接 vendor mattpocock 原版

選擇直接複製 upstream 的 `SKILL.md`（內容為 `Run a /grilling session, using the /domain-modeling skill.`）與 `agents/openai.yaml`，不改內容。

**Alternative**：改造現有 grill-me 讓它每次都呼叫 domain-modeling。否決理由——不是每次拷問都值得落地（有時只是快速釐清想法），保留 grill-me 作純拷問、grill-with-docs 作正式入口，給使用者明確開關。

### Decision 2: 消費規則放全域 CLAUDE.md，不走三段鏈

選擇直接在 `dotfiles/claude/CLAUDE.md` 新增一條領域知識消費規則段落。

**Alternative**：移植 mattpocock 的 setup-matt-pocock-skills → `docs/agents/domain.md` → CLAUDE.md `## Agent skills` 三段鏈。否決理由——繼承脆弱點（靜默失敗無信號、讀取時機窄、純指示非強制），且多一層間接檔案需維護。CLAUDE.md 本身就是每個 session 必讀的硬性載入點，直接在裡面寫規則是最短路徑。

### Decision 3: domain-modeling 維持 model-invoked

選擇不對 domain-modeling 加 `disable-model-invocation: true`。

**理由**：及時捕捉的價值——實作（apply）階段釐清的術語也能自動落地，不必等正式 grill session。domain-modeling 本身有「term resolved 才寫」的紀律 + ADR 三條門檻（hard to reverse + surprising + real trade-off），不是無腦寫入。CONTEXT.md 可見可編輯，寫錯可手動修正。

### Decision 4: CLAUDE.md 規則採靜默設計

規則採用「CONTEXT.md 不存在則靜默繼續」的設計（對齊 mattpocock `docs/agents/domain.md` 的 consumer rules），確保沒有 CONTEXT.md 的 repo 不受影響、不產生噪音。

## Risks / Trade-offs

- **[CLAUDE.md 規則是自然語言指示，AI 可能不遵循]** → CLAUDE.md 是 session 最高優先級指示來源，遵循度最高；無程式層面強制是所有 skill-based 指示的本質限制，無法完全消除
- **[domain-modeling model-invoked 可能在不成熟時機寫入半成品]** → CONTEXT.md 是可見可編輯的檔案，寫入半成品可手動修正；代價遠低於「什麼都不留下」
- **[grill-with-docs 與 grill-me 行為可能重疊]** → 差別在確定性：grill-with-docs 保證 domain-modeling 活躍（明確 `using`），grill-me 靠 AI 自主觸發（機率性）；使用者按場景選擇
