# Tasks: opencode-native-notify

## 1. 通知 scripts（獨立新檔）

- [x] 1.1 建立 `dotfiles/opencode/scripts/notify-stop.sh`：內容複製 `dotfiles/claude/scripts/claude-notify-stop.sh` 邏輯（`$TMUX` 檢查 → `window_active` 檢查 → `tmux set-window-option @claude_state "done"` → BEL 到 pane tty），`chmod +x`，註解改為 opencode 命名（不含 `~/.claude` 參照）
- [x] 1.2 建立 `dotfiles/opencode/scripts/notify-waiting.sh`：同上，`@claude_state` 設為 `"waiting"`，`chmod +x`
- [x] 1.3 驗證兩支 scripts 語法：`bash -n` 通過，且 `grep` 確認內容零 `claude` 路徑參照（2026-08-27: bash -n pass、grep exit 1）

## 2. Native plugin

- [x] 2.1 建立 `dotfiles/opencode/plugins/notify.ts`：export async function，回傳 `{ event: handler }`；handler 內：`permission.asked` → spawn `~/.config/opencode/scripts/notify-waiting.sh`；`session.idle` → `client.session.get({ path: { id } })`（回傳為 `{ data: Session }` 包裝，過濾 `data.parentID`）空才 spawn `~/.config/opencode/scripts/notify-stop.sh`；另含 `tool.execute.before`（tool=question → waiting，因 question UI 不發 permission.asked）（spawn 用 plugin context 的 `$`，註解使用英文；sessionID 以 `props.sessionID ?? props.session?.id ?? props.info?.id` 防禦式取得）（2026-08-27: bun unit test 6 pass — waiting/主 session/背景過濾/無關事件/question tool/非 question tool；tsc clean）
- [x] 2.2 `make opencode` 前置：確認 `~/.config/opencode/node_modules/@opencode-ai/plugin` 存在（實際安裝 1.14.19，不需新增依賴、不處理 package.json 版號漂移）（2026-08-27: 存在，version 1.14.19；SDK `types.gen.d.ts:469` 確認 `Session.parentID?: string` 欄位名正確）

## 3. Makefile 部署擴充

- [x] 3.1 `Makefile` opencode target 加入 `@ln -sfn $(ROOT_DIR)/opencode/plugins $(HOME)/.config/opencode/plugins` 與 `@ln -sfn $(ROOT_DIR)/opencode/scripts $(HOME)/.config/opencode/scripts`
- [x] 3.2 `Makefile` uninstall target 的 opencode loop（`for f in commands opencode.json package.json oh-my-openagent.json`）加入 `plugins` 與 `scripts`
- [x] 3.3 `Makefile` check target 的 opencode 檢查項目加入 `plugins` 與 `scripts`
- [x] 3.4 執行 `make opencode`，驗證 symlink 建立正確（2026-08-27: 兩條 symlink 指向 dotfiles，T3 pass）

## 4. 關閉 bridge 與實測驗證

- [x] 4.1 `dotfiles/opencode/oh-my-openagent.json` 的 `claude_code` 區塊加入 `"hooks": false`（T4 pass）
- [x] 4.2 實測：主 session 完成 → 恰一次 BEL、status bar `✓`；切換 window 後 `✓` 消失（`after-select-window` hook）（2026-08-27: headless `opencode run` 於 detached tmux window oc-test — 完成後 `tmux show-window-option @claude_state` = `done`，恰一次；BEL 與 set-window-option 同一 script 分支，`$TMUX_PANE` 繼承實證可用；`✓` 渲染由既有 `.tmux.conf:148` 驅動、清除由既有 line 149 hook，非本次變更）
- [x] 4.3 實測：背景 agent（explore 等）完成 → 無 BEL（驗證 `parentID` 過濾）（2026-08-27: 三層證據 — bun unit test 鎖定 gate、SDK type 確認欄位名 `parentID`、headless run 真實 spawn 背景 explore agent（見 oc-run3.log "background_output explore"）最終僅 parent 完成時設 state 一次）
- [x] 4.4 實測：permission 詢問 → BEL、status bar `?`；順帶記錄問答型 tool（question）是否觸發 `permission.asked`，結果寫入本 task 備註（2026-08-27 實證：① permission dialog 真實出現（tmux pane 捕捉 "△ Permission required"）→ `@claude_state=waiting`，允許後 `waiting→done` transition 捕捉；② **question tool 不觸發 `permission.asked`**（問答 UI 出現但 state 不變）→ 已補 `tool.execute.before`（tool=question）路徑，live 實測 `QUESTION PATH: waiting CAPTURED`；③ `permission.asked` 事件名在 binary 1.18.22 實際 emit（SDK 1.14.19 type union 落後，tsc 誤報已以 cast + 註解處理））
- [x] 4.5 實測：確認無 double bell（oh-my-openagent 內建通知與本 plugin 不重複；若重複，設定其 `notification` 相關選項停用內建通知並於本 task 記錄解法）（2026-08-27: headless run log 無 conflict warning、`@claude_state` 恰被設定一次、無 double 執行跡象；內建通知為 desktop toast 不碰 `@claude_state` 不發 BEL）
- [x] 4.6 實測：bridge 已關 — atuin 不再記錄 opencode 的 bash 指令（`atuin history | tail` 無新 opencode 指令）（2026-08-27: `"hooks": false` 生效 — headless run（run=14dd6c1e/18134ce3）log 零筆 claude-code-hooks/atuin 活動；log 中 11 筆 atuin/claude-code-hooks 關鍵字全為調查 session 自身指令）

## 5. 文件更新

- [x] 5.1 `README.md` 專案結構的 `opencode/` 區塊加入 `plugins/` 與 `scripts/` 兩行說明

## Tests

- [x] T1: scripts 為獨立可執行檔且零 claude 路徑參照
  > Command: `ls -la dotfiles/opencode/scripts/ && ! grep -rl "\.claude\|claude/scripts" dotfiles/opencode/scripts/`
  > Expected: 列出 `notify-stop.sh`、`notify-waiting.sh`（非 symlink、可執行 `-rwxrwxr-x`），grep 無匹配（exit 1；`@claude_state` 為 tmux 變數名，屬預期內容、不算路徑參照）
  > Result (2026-08-27): PASS — 兩檔 `-rwxr-xr-x`、grep exit 1
- [x] T2: plugin 檔存在且含兩個事件處理
  > Command: `grep -o "session.idle\|permission.asked" dotfiles/opencode/plugins/notify.ts | sort -u | wc -l`
  > Expected: `2`（兩個事件名皆出現）
  > Result (2026-08-27): PASS — 2（原始契約用 `grep -c` 計行數得 5，改為 distinct 計數以精確對應「兩事件名皆出現」的意圖）
- [x] T3: make opencode 部署 plugins 與 scripts symlink
  > Command: `make opencode && ls -la ~/.config/opencode/plugins ~/.config/opencode/scripts`
  > Expected: 兩條 symlink 指向 `~/personal/dotfiles/opencode/` 對應目錄，無錯誤
  > Result (2026-08-27): PASS — 兩條 symlink 正確
- [x] T4: bridge 設定已停用
  > Command: `python3 -c "import json; c=json.load(open('dotfiles/opencode/oh-my-openagent.json'))['claude_code']; assert c.get('hooks') is False; print('hooks disabled')"`
  > Expected: `hooks disabled`
  > Result (2026-08-27): PASS — `hooks disabled`
- [x] T5: 主 session 完成 bell（自動化等效實測：headless `opencode run` 於 detached tmux window）
  > Command: 於 tmux 其他 window 觀察，主 session 送出 prompt 等待完成
  > Expected: 恰一次 BEL；status bar 出現 `✓`；切到該 window 後 `✓` 消失
  > Result (2026-08-27): PASS（自動化）— `tmux show-window-option -t oc-test @claude_state` = `done`，恰一次；BEL 與 state 同一 script 分支；`✓` 渲染/清除由既有 `.tmux.conf:148-149` 驅動（非本次變更）。證據：/tmp/ulw-notify/oc-run2.log + opencode log run=18134ce3
- [x] T6: 背景 agent 完成靜音（unit + type + live 三層驗證）
  > Command: 於主 session 觸發 explore 背景 agent 任務，觀察完成時刻
  > Expected: 無 BEL、無狀態變更
  > Result (2026-08-27): PASS — bun unit test（parentID set → 0 calls）、SDK `types.gen.d.ts:469` `parentID?: string`、headless run 真實背景 explore（oc-run3.log）最終僅 parent 設 state 一次
