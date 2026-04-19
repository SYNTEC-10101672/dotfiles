## Why

OpenSpec 的 tasks.md 目前缺乏明確的驗收條件，Claude 實作完 task 後無法機械性地確認功能是否正常，導致「完成」的定義模糊。需要一個輕量的 TDD 機制，讓每個 task 在產出時就定義好驗證方式，實作後確認通過才算真正完成。

## What Changes

- `~/.claude/CLAUDE.md`（全域）新增兩條 OpenSpec 規範：
  - tasks.md 每個 task 必須包含 `> 驗證：` 區塊
  - 實作後呼叫 `openspec-tdd-verify` skill，通過才 mark `[x]`
- 新增 `claude/skills/openspec-tdd-verify/SKILL.md`：執行 task 的驗證區塊，處理通過、失敗、無法驗證三種情境
- 新增 `claude/commands/opsx/tdd-verify.md`：對應的 `/opsx:tdd-verify` slash command

## Capabilities

### New Capabilities

- `openspec-tdd-verify`: 讀取 task 的 `> 驗證：` 區塊，執行驗證指令，通過才 mark `[x]`，失敗則暫停回報

### Modified Capabilities

- `claude-config-symlink`: 全域 CLAUDE.md 新增 OpenSpec TDD 規範兩條

## Impact

- `claude/CLAUDE.md`：新增規範，影響所有使用 OpenSpec 的 project
- `claude/skills/`：新增一個 skill 目錄
- `claude/commands/opsx/`：新增一個 command 檔案
- Makefile 無需修改（`skills/` 和 `commands/` 整個目錄已是 symlink）
