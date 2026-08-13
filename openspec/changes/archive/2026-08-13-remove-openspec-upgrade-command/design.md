## Context

- 被移除的對象：`openspec/specs/openspec-upgrade-command/spec.md`（3 個 requirements、8 個 scenarios）
- 對應的 command 定義檔 `claude/commands/opsx/upgrade.md` 已於本 change 建立前手動刪除（透過 symlink 共享至 `~/.claude/commands/opsx/` 與 `~/.config/opencode/commands/opsx/`，deletion 存於當前 diff）
- 歸檔的歷史 change `openspec/changes/archive/2026-04-26-upgrade-openspec-tdd-workflow/` 記錄了當初新增此 capability 的過程，屬不可變歷史紀錄，不在本 change 範圍內

## Goals / Non-Goals

**Goals:**
- 移除 `openspec-upgrade-command` capability 的全部 requirements，使 spec 與實作狀態一致

**Non-Goals:**
- 不修改已歸檔的歷史 change（`archive/2026-04-26-upgrade-openspec-tdd-workflow/`）
- 不移除其他 opsx commands（僅移除 upgrade 相關 capability）
- 不清理 `.claude/transcripts/` 中的歷史對話紀錄

## Decisions

### 決策：整支刪除 spec 目錄而非保留空殼

`openspec-upgrade-command` 的 3 個 requirements 全數移除後，spec 將無任何內容。選擇刪除整個 `openspec/specs/openspec-upgrade-command/` 目錄而非保留空的 spec.md，避免留下無意義的空檔案。

**理由**：OpenSpec 的 capability 目錄存在的意義是承載 requirements，requirements 全空時目錄也無存在價值。

## Risks / Trade-offs

- **[風險] 未來 OpenSpec 上游恢復活躍更新後需要重新建立升級流程** → 緩解：歸檔的歷史 change 與 git history 保留了完整設計細節，需要時可參考重建。
