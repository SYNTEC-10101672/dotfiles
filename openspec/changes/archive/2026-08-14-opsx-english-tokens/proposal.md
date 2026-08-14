## Why

opsx skills 與 commands 中混合中英文：instruction body 部分用中文撰寫（`openspec-tdd-verify` skill、`opsx/tdd-verify`、`opsx/re-verify` command），format token 也用中文（`## 測試`、`## 實作`、`> 指令：`、`> 預期：`）。這造成兩個問題：

1. **Skill 可靠度**：`writing-great-skills` 的 leading word 原則指出，model pretraining 以英文為主，英文 structural token 被 reliably match 的機率更高。中文 token 降低 invocation 與 parsing 可靠度。
2. **Single source of truth 違反**：CLAUDE.md `<OpenSpec 規範>` section 與 skills 之間存在 duplication — 格式定義同時出現在 CLAUDE.md 和 `openspec-continue-change` / `openspec-propose` 等 skills 裡。改一邊忘改另一邊就是這次問題的根因。

## What Changes

- **BREAKING** — tasks.md format token 全面改英文：
  - `## 測試` → `## Tests`
  - `## 實作` → `## Implementation`
  - `> 指令：` → `> Command:`
  - `> 預期：` → `> Expected:`
  - `> 備註：手動驗證` → `> Note: manual verification`
  - `（→ T<n>）` → `(→ T<n>)`（fullwidth → halfwidth parentheses）
- 將 `openspec-tdd-verify` skill body、`opsx/tdd-verify` command、`opsx/re-verify` command 的中文 instruction 翻譯為英文
- 將 `openspec-apply-change`、`openspec-continue-change` skill 及對應 command 中引用的中文 token swap 為英文
- 將 `handover` command 中引用的 `## 實作` token swap 為 `## Implementation`
- **刪除** CLAUDE.md 整段 `<OpenSpec 規範>` — 這些規則已在 skills 中定義，CLAUDE.md 為 redundancy
- artifact content（tasks.md / design.md / proposal 的 prose）維持繁體中文撰寫，僅 structural token 改英文

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `openspec-tdd-task-format`：format token 由中文改為英文（`## Tests` / `## Implementation` / `> Command:` / `> Expected:`）
- `openspec-tdd-verify`：skill 語言由中文改為英文；token reference 同步更新
- `openspec-skill-command-parity`：反轉 line 53 normative clause — token 由「SHALL 原貌保留中文」改為「SHALL 使用英文 format identifier」；其餘 parity 要求不變

## Impact

- **Skill / command 檔案**（9 個）：`claude/skills/openspec-{tdd-verify,apply-change,continue-change}/SKILL.md`、`claude/commands/opsx/{tdd-verify,re-verify,apply,continue}.md`、`claude/commands/handover.md`
- **CLAUDE.md**：刪除 `<OpenSpec 規範>` section
- **既有 active changes**：其他 repo 有 3 個 active change 使用舊中文 token 格式，此 change 不處理 migrate（tdd-verify skill 現有 `> 驗證：` legacy guard 會偵測舊格式並停止）
- **Archived changes**：不影響（immutable history）
