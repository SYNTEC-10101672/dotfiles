## 1. 修改 CLAUDE.md

- [x] 1.1 在 `claude/CLAUDE.md` 新增 `## OpenSpec 規範` 段落，加入 tasks.md 格式規則與 TDD 實作規範兩條
  > 驗證：確認 `claude/CLAUDE.md` 包含 `## OpenSpec 規範`、`> 驗證：` 格式說明、`openspec-tdd-verify` 呼叫規則

## 2. 新增 openspec-tdd-verify skill

- [x] 2.1 建立 `claude/skills/openspec-tdd-verify/SKILL.md`，內容包含：讀取 `> 驗證：` 區塊、執行驗證指令、通過 mark `[x]`、失敗暫停回報、無法驗證 log 後 mark `[x]`、缺少區塊暫停要求補上
  > 驗證：確認 `claude/skills/openspec-tdd-verify/SKILL.md` 存在且包含四種情境（通過、失敗、無法驗證、缺少區塊）的處理步驟

## 3. 新增 opsx:tdd-verify command

- [x] 3.1 建立 `claude/commands/opsx/tdd-verify.md`，作為 `/opsx:tdd-verify` slash command，呼叫 `openspec-tdd-verify` skill
  > 驗證：確認 `claude/commands/opsx/tdd-verify.md` 存在，且 `ls ~/.claude/commands/opsx/tdd-verify.md` 可見（symlink 生效）
