## Why

explore mode 的 AI 常在討論途中未經 `/opsx:propose` 就直接實作，且 `openspec-explore` 與 `openspec-propose` 兩個 skill 對 `CONTEXT.md` 的寫入指示為 "right away / immediately"（只抄了 domain-modeling 的結論、跳過挑戰程序），與 explore skill 自身的 "Don't auto-capture" guardrail 矛盾，導致未經討論即寫檔。

## What Changes

- `claude/skills/openspec-explore/SKILL.md`：
  - L291 domain vocabulary 指示由 "write right away" 改為：詞彙 crystallize 時 invoke `domain-modeling` skill 走挑戰程序（challenge → resolve → write），resolved 後才寫入
  - 寫檔改為白名單制：explore mode 僅可寫 OpenSpec artifacts（`openspec/changes/**`）與經 domain-modeling 程序 resolved 的 `CONTEXT.md`；其他寫入請求一律引導至 `/opsx:propose`
  - 增加 few-shot 反例：示範「user 要求直接改 → 拒絕並引導 `/opsx:propose`」的正確回應
- `claude/skills/openspec-propose/SKILL.md`：
  - L120-121 "immediately / right away / Do not batch" 改為與 explore 相同的 domain-modeling 程序指示，規則單一來源

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `claude-config-symlink`：新增 explore / propose skill 對 `CONTEXT.md` 寫入程序與 explore mode 寫檔白名單的行為要求（此 change 修改 `claude/skills/` 下受 deploy 管理的檔案內容）

## Impact

- `claude/skills/openspec-explore/SKILL.md`（行為變更：寫檔限制 + 程序指示）
- `claude/skills/openspec-propose/SKILL.md`（行為變更：CONTEXT.md 寫入程序）
- `claude/skills/domain-modeling/SKILL.md`：不修改（resolve-then-write 為正確源頭）
- `~/.claude/CLAUDE.md`：不修改（使用者決議）
- wrapper `claude/commands/opsx/explore.md` / `propose.md`：不需變更（thin wrapper，內容本體在 skill）
