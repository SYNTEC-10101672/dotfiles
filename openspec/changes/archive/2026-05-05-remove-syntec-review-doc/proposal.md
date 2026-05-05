## Why

`syntec:review-doc` command 已移至 `~/personal/projects_dotfiles` 專案統一維護，繼續在 dotfiles repo 保留會造成重複定義與維護負擔。

## What Changes

- 移除 `claude/commands/syntec/review-doc.md`（command 與 skill 本體）
- 移除 `claude/commands/syntec/` 目錄（移除後為空）
- 移除 `openspec/specs/syntec-review-doc-command/`（對應 spec）

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

（無）

## Impact

- `~/.claude/commands/syntec/review-doc.md` symlink 將失效（目標檔案消失），需確認 symlink 狀況
- `/syntec:review-doc` slash command 與 `syntec:review-doc` skill 將從 Claude Code 中消失
- 功能本體已在 `~/personal/projects_dotfiles` 維護，不影響實際使用
