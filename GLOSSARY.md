# dotfiles

個人開發環境設定檔 repo：bash/zsh/nvim/git/herdr 設定與 Claude Code、OpenCode 的 agent 配置，透過 Makefile symlink 部署到 `~/.config/` 與 `$HOME`。

## Language

### AI 金鑰防護

**Secret Guard**:
OpenCode 層的三層金鑰洩漏防護機制（read deny、commit 掃描、push 確認），實作於 `opencode/plugins/guard.ts`（v2 plugin：`Plugin.define` + `ctx.tool.hook`）與 `opencode/opencode.json` 的 `permissions` 規則（v2 ordered array，last match wins；見 ADR-0008）。
_Avoid_: git 保護、金鑰保護單獨指稱此機制時

**fail-closed**:
`guard.ts` 在 gitleaks 缺失時拒絕所有 AI `git commit` 的行為方針 — 寧可擋掉 commit 也不讓防護靜默消失。
_Avoid_: fail-open（明確被否決的方案）

**staged 掃描**:
在 `git commit` 執行前用 `gitleaks protect --staged --redact` 掃描 staged diff 內容；`--redact` 確保錯誤訊息不含 secret 明文。
_Avoid_: 內容掃描（太泛）

### Skill 撰寫

**ambient 規則**:
已由 system prompt（全域 `AGENTS.md`）載入的規則；skills 與 commands 對其不做路徑引用也不重抄 — skill 需要的規則內文明示，ambient 的不需要任何 pointer。
_Avoid_: 「遵循 CLAUDE.md」（dangling pointer）、「引用全域設定」（指向永遠已載入的材料是零功 pointer）

**matt 系列**:
從 mattpocock/skills repo vendor 的 skills 與 commands，vendor 基準線記錄於 `opencode/VENDORED.md`。dual-entry（grilling、domain-modeling）裝法 = `skills/<name>/SKILL.md` 為內容 home、`commands/` 側以 `grill-me`/`grill-with-docs` 薄 wrapper 轉發；user-only 入口（teach、handoff、wayfinder、improve-codebase-architecture、setup-matt-pocock-skills、retro、wait-what、implement-spec、to-questionnaire，另有 to-spec、to-tickets、implement、writing 系列等 body 原文同步者）= 自包含 `commands/<name>.md`，內容內聯、無 skill 檔（見 ADR-0001）。其 `handoff` 是唯一的 session 交接機制（拋棄式：交接文件存 OS temp dir，用完即丟；跨 session 的持久層是 issue tracker 的 `.scratch/` tickets）。openspec 時代的 `handover`（HANDOVER.md）已隨 openspec 退役移除（見 ADR-0005）。
_Avoid_: 把 handoff 交接文件當持久層（要留的狀態寫進 tickets）

**vendor 基準線**:
vendored 檔案對齊的 upstream 版本基準（matt 系列：mattpocock/skills v1.3.1；humanlayer 系列：main @ `bba9d13`），記錄於 `opencode/VENDORED.md`；升級 = checkout upstream tag（humanlayer 無 tag，以 commit 為準）後逐項 diff，僅回補記錄過的包裝客製。
_Avoid_: upstream 版本單獨指稱此基準時

**user-only 入口**:
只由人以 slash command 觸發的工作流，形式為自包含 `commands/*.md`，不佔 skill listing。上游以 `disable-model-invocation` 表達此概念，但該 flag 在 opencode core 為 no-op，故以刪除 skill 檔達成零 ambient。
_Avoid_: user-invoked skill（本環境無此機制）

**dual-entry skill**:
model 與人都能觸發的 skill（如 grilling、domain-modeling）；description 常駐 system prompt 是 model 自主觸發與共用內容 home 的代價。
_Avoid_: 與 user-only 入口混用（判準：model 會不會自主觸發）

**wrapper command**:
`commands/*.md` 中只做 `$ARGUMENTS` 轉發給 dual-entry skill 的薄指令檔（frontmatter + 一行 Skill tool 呼叫）。僅 grill-me 與 grill-with-docs 使用；user-only 入口一律自包含。
_Avoid_: 把 wrapper 當 skill 本體稱呼（內容在 `skills/<name>/SKILL.md`）

### 終端機

**主力終端**:
日常使用的 terminal multiplexer，現為 herdr，也是唯一受組態的終端；tmux 模組已退役（見 ADR-0006），系統套件亦已移除（見 ADR-0009），回退路徑 = git history。
_Avoid_: 把 tmux 稱為 fallback 或並存雙主力（tmux 模組已移除，僅存於 git history）

**native agent observation**:
herdr 內建的 agent 偵測與狀態回報機制（detection manifests + sidebar rollup + toast/sound），涵蓋 opencode；為唯一的 agent 觀測來源。
_Avoid_: 與 tmux 時代的 `@claude_state` + notify scripts 觀測管線混稱（該管線已移除，僅存於 git history）

**tab ↔ window**:
herdr 的 tab 是 tmux window 的對應物（workspace 內的 tab row，位置可由 `ui.tab_bar_position` 設定，現為底部）；herdr workspace 是 sidebar 的專案空間，tmux 無對應物。
_Avoid_: 把 herdr tab 稱為 workspace（兩層結構，混用會讓 keybinding 討論失準）

**自動命名**:
tab 名稱自動反映該 tab 內正在執行的指令；手動改名優先於自動命名（鎖定至 tab 關閉，見 ADR-0003）。
_Avoid_: 與 tmux `automatic-rename` 混稱（tmux 以輪詢實作、本 repo 以 shell hooks 實作；herdr 0.9.3 無原生）

### OpenCode TUI

**session panel**:
OpenCode TUI 裡由 host 擁有 sizing/focus/fullscreen 的側邊 panel，plugin 只貢獻內容；NBA 比數顯示的載體，只能 在 session 內開啟。
_Avoid_: sidebar（指 TUI 內建的 session sidebar，另一個東西）、右半邊 panel（位置由 host 決定，不保證右側或 50% 寬）

**scoreboard**:
比賽層級的即時數據：對戰組合、比數、節次、game clock、比賽狀態（pre/in/post）；NBA panel 的顯示範圍。
_Avoid_: 即時數據（範圍模糊）、box score

**box score**:
單場球員數據（MIN/PTS/REB/AST 等）；NBA panel 的未來擴充，不屬於 scoreboard 範圍。
_Avoid_: 與 scoreboard 混用

**賽程日**:
panel 語境的「今天」＝NBA 官方 scoreboard 的日期基準（US Eastern）；台灣早上對到的是前一個賽程日。
_Avoid_: 台灣日曆天

### 部署

**deploy**:
`make <target>` 以 symlink 將 dotfiles 檔案連到 `$HOME` / `~/.config/` 對應位置的動作。
_Avoid_: install 指個別檔案複製時（本 repo 一律 symlink）
