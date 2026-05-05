## 測試

- [x] T1 確認 `claude/commands/syntec/review-doc.md` 已不存在
  > 指令：`test ! -f claude/commands/syntec/review-doc.md && echo OK`
  > 預期：輸出 `OK`

- [x] T2 確認 `claude/commands/syntec/` 目錄已不存在
  > 指令：`test ! -d claude/commands/syntec && echo OK`
  > 預期：輸出 `OK`

- [x] T3 確認 `openspec/specs/syntec-review-doc-command/` 已不存在
  > 指令：`test ! -d openspec/specs/syntec-review-doc-command && echo OK`
  > 預期：輸出 `OK`

- [x] T4 確認 `~/.claude/commands/syntec/` 下無懸空 symlink
  > 指令：`find ~/.claude/commands/syntec -xtype l 2>/dev/null | wc -l`
  > 預期：輸出 `0`（或目錄不存在）

## 實作

- [x] 1.1 刪除 `claude/commands/syntec/review-doc.md`（→ T1）
- [x] 1.2 刪除 `claude/commands/syntec/` 目錄（→ T2）
- [x] 1.3 刪除 `openspec/specs/syntec-review-doc-command/` 目錄（→ T3）
- [x] 1.4 清除 `~/.claude/commands/syntec/` 下的懸空 symlink（→ T4）
