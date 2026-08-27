## Context

使用者觀察到兩個行為問題：

1. **explore mode 越權實作**：`/opsx:explore` 進行中，AI 討論到一半未經 `/opsx:propose` 就直接寫 code。原因有三：
   - skill 內容只在進場注入一次，長對話中指令注意力衰減（recency bias）
   - `claude/skills/openspec-explore/SKILL.md` L14 開了 "capturing thinking" 例外，模型會把小修改類比成 capture；「remind them to exit」是抽象規則，無示範
   - L291 最後一條 guardrail 命令 "write into `CONTEXT.md` right away"，與 L133 "Don't auto-capture" 自相矛盾，親手把 "never write" 弱化成 "almost never write"
2. **CONTEXT.md 寫入跳過程序**：`openspec-explore` L291 與 `openspec-propose` L120-121 指示 "right away / immediately / Do not batch"，只抄了 `claude/skills/domain-modeling/SKILL.md` 的「立刻寫」結論，跳過它的挑戰程序（challenge fuzzy terms → 具體 scenario 逼出邊界 → resolved 才寫）。現況也只文字指路 `CONTEXT-FORMAT.md`，未要求 invoke domain-modeling skill。

現有檔案結構（`openspec/specs/openspec-skill-command-parity/spec.md`）：skill 為單一真相來源，command 為 thin wrapper。本 change 只改 skill 檔案，wrapper 不動。

## Goals / Non-Goals

**Goals:**

- explore skill 的寫檔規則改為白名單制，消除內部矛盾
- explore / propose 的 `CONTEXT.md` 寫入統一走 domain-modeling 程序（resolve-then-write），規則單一來源
- 以 few-shot 示範「拒絕直接實作、引導 `/opsx:propose`」的具體回應，取代抽象 remind

**Non-Goals:**

- 不修改 `claude/skills/domain-modeling/SKILL.md`（resolve-then-write 是正確源頭）
- 不修改 `~/.claude/CLAUDE.md`（使用者決議不加 OpenSpec flow backing）
- 不做機械式防護（PreToolUse hook 擋寫入）— 文字修法先驗證，不夠再談
- 不修改 wrapper `claude/commands/opsx/explore.md` / `propose.md`（thin wrapper 原則）

## Decisions

### D1：寫檔白名單制，直接修 L14 與 Guardrails 段落

L14 改為明確白名單：explore mode 可寫 `openspec/changes/**`（OpenSpec artifacts）與 `CONTEXT.md`（須經 D2 程序）；「capturing thinking, not implementing」的模糊例外刪除，改列具體副檔名與路徑。Guardrails 的 "Don't implement" 條目同步列白名單。

- 為何不用 hook 擋：state lifecycle（marker 建立清除）有額外風險，文字修法成本一個檔案，先驗證效果。
- 為何不是隻刪例外句：模型對 example 的遵循大於抽象規則，白名單 + few-shot（D3）雙管。

### D2：CONTEXT.md 寫入改為 invoke domain-modeling 程序

兩個 skill 的 "right away / immediately" 段落改為：詞彙 crystallize 時 invoke `domain-modeling` skill（至少：先讀同 skills 目錄下 `domain-modeling` 的 `SKILL.md` 與 `CONTEXT-FORMAT.md` 再寫），走挑戰程序，resolved 後才寫入。

- 為何不改成 offer-first（每寫必問）：domain-modeling 原設計同意內建在討論裡（挑戰 → 使用者選定 → resolved），多問一次是重工；程式移植完整，規則單一來源。
- 為何要求 invoke skill 而非只改文字指路：現況「format per CONTEXT-FORMAT.md」沒強制讀檔，模型可能不讀就腦補 format。

### D3：few-shot 反例放「Handling Different Entry Points」段

在 `openspec-explore/SKILL.md` 的 entry-point 範例區新增一組對話：user 說「那你直接改一改」→ 正確回應示範拒絕並引導 `/opsx:propose`。放在範例區而非 Guardrails，與既有對話範例同格式，模型 pattern-match 效果最好。

### D4：spec delta 掛 `claude-config-symlink` capability

`openspec/specs/` 現有 capability 中，`claude-config-symlink` 涵蓋 `claude/` 目錄下受 deploy 管理檔案的行為要求，skill 檔案屬於此範疇，以 ADDED requirements 描述新行為。

## Risks / Trade-offs

- [文字修法對長對話的 recency bias 效果有限] → 白名單與 few-shot 已提高遵循度；若實測仍越權，再評估 PreToolUse hook（本 change 不做）
- [invoke domain-modeling skill 在不支援 skill 工具的環境不可執行] → 指示寫成「invoke，或至少先讀 SKILL.md 與 CONTEXT-FORMAT.md」，fallback 明確
- [explore 白名單限縮可能擋住使用者臨時要求的合法寫檔] → 這是意圖行為：引導至 `/opsx:propose`，使用者明確堅持時可 exit explore mode

## Migration Plan

1. 修改兩個 SKILL.md（deploy 為 symlink，改完即生效，無需額外部署）
2. 驗證：grep 確認舊字眼（right away / immediately / Do not batch）已消失、白名單與 few-shot 存在
3. Rollback：`git revert` 兩個檔案即可

## Open Questions

（無 — scope 已與使用者在 explore 階段確認）
