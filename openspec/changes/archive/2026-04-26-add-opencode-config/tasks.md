## 測試

- [x] T1 `opencode/opencode.json` 存在於 dotfiles repo
  > 指令：`ls /home/s911336/Projects/dotfiles/opencode/opencode.json`
  > 預期：指令成功（exit 0），檔案存在

- [x] T2 `opencode/package.json` 存在於 dotfiles repo
  > 指令：`ls /home/s911336/Projects/dotfiles/opencode/package.json`
  > 預期：指令成功（exit 0），檔案存在

- [x] T3 `~/.config/opencode/opencode.json` 是 symlink 且指向 dotfiles
  > 指令：`readlink ~/.config/opencode/opencode.json`
  > 預期：輸出 `/home/s911336/Projects/dotfiles/opencode/opencode.json`

- [x] T4 `~/.config/opencode/package.json` 是 symlink 且指向 dotfiles
  > 指令：`readlink ~/.config/opencode/package.json`
  > 預期：輸出 `/home/s911336/Projects/dotfiles/opencode/package.json`

- [x] T5 `make opencode` 可冪等執行（重複執行不報錯）
  > 指令：`cd /home/s911336/Projects/dotfiles && make opencode && make opencode; echo "exit:$?"`
  > 預期：輸出包含 `✓ OpenCode` 且 `exit:0`

- [x] T6 `make check` 顯示 opencode.json 和 package.json symlink 狀態
  > 指令：`cd /home/s911336/Projects/dotfiles && make check | grep "opencode"`
  > 預期：輸出包含 `opencode.json` 和 `package.json` 的 `✓` 狀態行

- [x] T7 `make uninstall` 移除 opencode 設定 symlink
  > 指令：`cd /home/s911336/Projects/dotfiles && make uninstall && ls ~/.config/opencode/opencode.json 2>&1; echo "exit:$?"`
  > 預期：`exit:2`（檔案不存在）；執行後需重新執行 `make opencode` 還原

- [x] T8 SETUP.md 步驟 7 包含 plugin 自動安裝說明
  > 指令：`grep -c "自動\|auto" /home/s911336/Projects/dotfiles/docs/SETUP.md`
  > 預期：輸出 `1` 或以上

- [x] T9 README.md 的功能清單包含 opencode 條目
  > 指令：`grep -c "opencode" /home/s911336/Projects/dotfiles/README.md`
  > 預期：輸出 `1` 或以上

- [x] T10 README.md 的個別模組清單包含 `make opencode`
  > 指令：`grep -c "make opencode" /home/s911336/Projects/dotfiles/README.md`
  > 預期：輸出 `1` 或以上

- [x] T11 README.md 的專案結構圖包含 `opencode/` 目錄
  > 指令：`grep -c "opencode/" /home/s911336/Projects/dotfiles/README.md`
  > 預期：輸出 `1` 或以上

- [x] T12 `.claude/CLAUDE.md` 的個別模組清單包含 `make opencode`
  > 指令：`grep -c "make opencode" /home/s911336/Projects/dotfiles/.claude/CLAUDE.md`
  > 預期：輸出 `1` 或以上

- [x] T13 `.claude/CLAUDE.md` 的 Architecture 段落提及 `opencode/` 目錄
  > 指令：`grep -c "opencode" /home/s911336/Projects/dotfiles/.claude/CLAUDE.md`
  > 預期：輸出 `1` 或以上

## 實作

## 1. 建立 opencode/ 目錄與設定檔

- [x] 1.1 建立 `opencode/` 目錄，複製 `~/.config/opencode/opencode.json` 內容（→ T1）
- [x] 1.2 複製 `~/.config/opencode/package.json` 內容到 `opencode/package.json`（→ T2）

## 2. 更新 Makefile opencode target

- [x] 2.1 在 `opencode` target 新增對 `opencode.json` 和 `package.json` 的 `ln -sf` 指令（→ T3, T4, T5）

## 3. 更新 Makefile check target

- [x] 3.1 在 `check` target 的 OpenCode 驗證區塊新增 `opencode.json` 和 `package.json` symlink 狀態顯示（→ T6）

## 4. 更新 Makefile uninstall target

- [x] 4.1 在 `uninstall` target 新增移除 `opencode.json` 和 `package.json` symlink 的邏輯（→ T7）

## 5. 更新 SETUP.md

- [x] 5.1 在步驟 7（opencode）說明 `@slkiser/opencode-quota` plugin 於首次啟動時自動下載，無需手動 `npm install`（→ T8）

## 6. 更新 README.md

- [x] 6.1 功能特色清單新增 opencode 條目（→ T9）
- [x] 6.2 個別模組安裝清單新增 `make opencode`（→ T10）
- [x] 6.3 專案結構圖新增 `opencode/` 目錄與說明（→ T11）

## 7. 更新 .claude/CLAUDE.md

- [x] 7.1 個別模組清單新增 `make opencode`（→ T12）
- [x] 7.2 Architecture 段落說明 `opencode/` 目錄用途（→ T13）
