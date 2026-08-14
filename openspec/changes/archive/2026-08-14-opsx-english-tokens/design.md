## Context

### 環境架構
- `~/.claude/CLAUDE.md`、`~/.claude/skills/`、`~/.claude/commands/` 皆 symlink 到 `dotfiles/claude/` 對應路徑
- 所有 edit 與 commit 在 dotfiles repo 進行（`/home/syntec/personal/dotfiles`）

### Token 對照表

| 舊（中文） | 新（英文） |
|---|---|
| `## 測試` | `## Tests` |
| `## 實作` | `## Implementation` |
| `> 指令：` | `> Command:` |
| `> 預期：` | `> Expected:` |
| `> 備註：手動驗證` | `> Note: manual verification` |
| `（→ T<n>）` | `(→ T<n>)` |
| skill output `✓ T<n> 通過 → marked [x]` | `✓ T<n> passed → marked [x]` |
| skill output `✗ T<n> 失敗（見上方詳情）` | `✗ T<n> failed (see details above)` |
| skill output `通過：2/3　失敗：1/3` | `Passed: 2/3  Failed: 1/3` |
| skill output `## 驗證摘要（<phase> phase）` | `## Verification summary (<phase> phase)` |
| `> 驗證：`（legacy inline format） | **不改** — 偵測 literal 保留中文，guard message 改英文 |

### 受影響檔案（9 個）

| 類別 | 檔案 | 動作 |
|---|---|---|
| A — body 翻譯 | `claude/skills/openspec-tdd-verify/SKILL.md` | 全文中→英，含 frontmatter description |
| A — body 翻譯 | `claude/commands/opsx/tdd-verify.md` | intro + Input 中→英 |
| A — body 翻譯 | `claude/commands/opsx/re-verify.md` | intro + step 1-2 中→英 |
| B — token swap | `claude/skills/openspec-apply-change/SKILL.md` | `## 測試` → `## Tests`（2 處：line 71, 78）|
| B — token swap | `claude/skills/openspec-continue-change/SKILL.md` | 全部 token swap（line 105，含 `## 測試`/`## 實作`/`> 指令：`/`> 預期：`/`（→ T<n>）`）|
| B — token swap | `claude/commands/opsx/apply.md` | `## 測試` → `## Tests`（2 處：line 67, 74）|
| B — token swap | `claude/commands/opsx/continue.md` | 全部 token swap（line 101，同 continue-change）|
| B — token swap | `claude/commands/handover.md` | `## 實作` → `## Implementation`（1 處：line 37）|
| C — 刪段 | `claude/CLAUDE.md` | 刪除整段 `## OpenSpec 規範`（5 條規則）|

## Goals / Non-Goals

**Goals:**
- opsx skills 與 commands 中的 structural token 統一為英文
- `openspec-tdd-verify` skill body、`opsx/tdd-verify`、`opsx/re-verify` command 的 instruction 由中文翻譯為英文
- 刪除 CLAUDE.md `## OpenSpec 規範` — 規則已在 skills 中定義（single source of truth）

**Non-Goals:**
- 不翻譯 artifact content（tasks.md / design.md / proposal 的 prose 維持繁體中文，遵循 CLAUDE.md `## 文件規範`）
- 不 migrate 其他 repo 既有的 active changes（3 個，皆已完成）
- 不新增 `## 測試` legacy guard（現有 `> 驗證：` guard 保留）
- 不修改 `openspec/specs/claude-config-symlink/spec.md` 中過時的 `> 驗證：` reference

## Decisions

### D1: 刪除 CLAUDE.md `## OpenSpec 規範` 而非 token swap

CLAUDE.md 的 5 條規則全部已在 skills 中定義：
- `## 測試`/`## 實作` 格式 → `openspec-continue-change:105`、`openspec-propose:103`
- apply 後 call tdd-verify → `openspec-apply-change:78`
- 不可用代名詞 → `openspec-propose:76,78,84`
- design.md `### Context` → `openspec-propose:103`
- archive 前跑 code-review → `openspec-apply-change:108`

保留 CLAUDE.md 版本是 duplication，違反 single source of truth。刪除後 skills 為唯一 source。

### D2: 不新增 `## 測試` legacy guard

現有 `> 驗證：` guard 已涵蓋最舊格式。新增 `## 測試` guard 增加 skill 複雜度，效益有限。

### D3: artifact content 維持繁體中文

structural token 是 model parsing 的錨點，英文更可靠。content prose 是人類閱讀的，遵循 CLAUDE.md `## 文件規範` 維持繁體中文，技術術語保持英文。

## Risks / Trade-offs

- **其他 repo 的 3 個 active change 使用舊中文 token** → tdd-verify skill 找不到 `## Tests` block，使用者需手動 migrate。風險低：那些是已完成任務。
- **Parity spec clause 反轉** → 原 `openspec-skill-command-parity` requirement "literal format token SHALL 保留原貌" 語意反轉為 "SHALL 使用英文"。direction 明確，無歧義。
- **Archived changes 仍用舊 token** → 不影響（immutable history，tdd-verify 不讀 archive）。
