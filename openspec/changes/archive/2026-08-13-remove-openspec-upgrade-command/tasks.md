## 測試

- [x] T1 > 指令：`ls /home/syntec/personal/dotfiles/openspec/specs/openspec-upgrade-command/ 2>&1`
      > 預期：輸出 `No such file or directory`（目錄已不存在）

- [x] T2 > 指令：`ls /home/syntec/personal/dotfiles/claude/commands/opsx/upgrade.md 2>&1`
      > 預期：輸出 `No such file or directory`（command 定義檔已不存在）

- [x] T3 > 指令：`ls /home/syntec/personal/dotfiles/claude/commands/opsx/ | sort | tr '\n' ' '`
      > 預期：輸出 13 個檔案，不含 `upgrade.md`：`apply.md archive.md bulk-archive.md continue.md explore.md ff.md new.md onboard.md propose.md re-verify.md sync.md tdd-verify.md verify.md`

- [x] T4 > 指令：`grep -rl 'openspec-upgrade-command\|opsx:upgrade\|opsx/upgrade' /home/syntec/personal/dotfiles/openspec/specs/ 2>&1`
      > 預期：exit code 1，無任何輸出（active specs 內無殘留引用）

## 實作

- [x] 1.1 刪除 `openspec/specs/openspec-upgrade-command/` 整個目錄（→ T1）
- [x] 1.2 確認 `claude/commands/opsx/upgrade.md` 已不存在（本 change 前已刪除，此為驗證）（→ T2）
- [x] 1.3 確認其餘 13 個 opsx commands 完好（→ T3）
- [x] 1.4 確認 active specs 無殘留引用（→ T4）
