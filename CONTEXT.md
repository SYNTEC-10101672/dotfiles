# dotfiles

個人開發環境設定檔 repo：bash/zsh/nvim/git/tmux 設定與 Claude Code、OpenCode 的 agent 配置，透過 Makefile symlink 部署到 `~/.config/` 與 `$HOME`。

## Language

### AI 金鑰防護

**Secret Guard**:
OpenCode 層的三層金鑰洩漏防護機制（read deny、commit 掃描、push 確認），實作於 `opencode/plugins/guard.ts` 與 `opencode/opencode.json` 的 `permission` 區塊。
_Avoid_: git 保護、金鑰保護單獨指稱此機制時

**fail-closed**:
`guard.ts` 在 gitleaks 缺失時拒絕所有 AI `git commit` 的行為方針 — 寧可擋掉 commit 也不讓防護靜默消失。
_Avoid_: fail-open（明確被否決的方案）

**staged 掃描**:
在 `git commit` 執行前用 `gitleaks protect --staged --redact` 掃描 staged diff 內容；`--redact` 確保錯誤訊息不含 secret 明文。
_Avoid_: 內容掃描（太泛）

### Commit 授權

**Commit Gate**:
OpenCode 層的 AI `git commit` 授權機制：偵測 `git commit`（含 `-C`、chain、env prefix 形狀），未授權 session 一律擋下並指示模型繼續任務，實作於 `opencode/plugins/commit-gate.ts`。
_Avoid_: commit guard（與 Secret Guard 混淆）

**authorized session**:
使用者執行過 `/commit` 的 session；其間 AI 的 `git commit` 放行（仍過 Secret Guard）。授權隨任何其他 slash command 執行或 session 結束失效，不繼承給 subagent。
_Avoid_: 白名單 session（誤導為持久清單）

### Skill 撰寫

**ambient 規則**:
已由 system prompt（全域 `AGENTS.md`）載入的規則；skills 與 commands 對其不做路徑引用也不重抄 — skill 需要的規則內文明示，ambient 的不需要任何 pointer。
_Avoid_: 「遵循 CLAUDE.md」（dangling pointer）、「引用全域設定」（指向永遠已載入的材料是零功 pointer）

**matt 系列**:
從 mattpocock/skills repo vendor 的 skills。dual-entry（grilling、domain-modeling）裝法 = `skills/<name>/SKILL.md` + `commands/<name>.md` 薄 wrapper；user-only 入口（teach、handoff、wayfinder、improve-codebase-architecture、setup-matt-pocock-skills）= 自包含 `commands/<name>.md`，內容內聯、無 skill 檔（見 ADR-0001）。其 `handoff` 是拋棄式跨 agent 交接（文件存 OS temp dir，用完即丟）；repo 內 session 交接走 `handover`（HANDOVER.md + OpenSpec artifacts）。
_Avoid_: handoff / handover 互換（拋棄式跨 agent vs repo session 交接是兩回事）

**user-only 入口**:
只由人以 slash command 觸發的工作流，形式為自包含 `commands/*.md`，不佔 skill listing。上游以 `disable-model-invocation` 表達此概念，但該 flag 在 opencode 為 no-op（core 與 OmO 皆不讀），故以刪除 skill 檔達成零 ambient。
_Avoid_: user-invoked skill（本環境無此機制）

**dual-entry skill**:
model 與人都能觸發的 skill（如 grilling、domain-modeling）；description 常駐 system prompt 是 model 自主觸發與共用內容 home 的代價。
_Avoid_: 與 user-only 入口混用（判準：model 會不會自主觸發）

**wrapper command**:
`commands/*.md` 中只做 `$ARGUMENTS` 轉發給 dual-entry skill 的薄指令檔（frontmatter + 一行 Skill tool 呼叫）。僅 grill-me 與 grill-with-docs 使用；user-only 入口一律自包含。
_Avoid_: 把 wrapper 當 skill 本體稱呼（內容在 `skills/<name>/SKILL.md`）

### 終端機

**主力終端**:
日常使用的 terminal multiplexer，現為 herdr；tmux 為 fallback（設定凍結：壞了修、不演進，見 ADR-0002）。
_Avoid_: 把 tmux 稱為主力、把 fallback 說成並存雙主力

**native agent observation**:
herdr 內建的 agent 偵測與狀態回報機制（detection manifests + sidebar rollup + toast/sound），涵蓋 opencode。
_Avoid_: 與 tmux 時代的 `@claude_state` + notify scripts 觀測管線混稱（那是 fallback 專屬 hack）

**tab ↔ window**:
herdr 的 tab 是 tmux window 的對應物（workspace 內的 tab row，位置可由 `ui.tab_bar_position` 設定，現為底部）；herdr workspace 是 sidebar 的專案空間，tmux 無對應物。
_Avoid_: 把 herdr tab 稱為 workspace（兩層結構，混用會讓 keybinding 討論失準）

### 部署

**deploy**:
`make <target>` 以 symlink 將 dotfiles 檔案連到 `$HOME` / `~/.config/` 對應位置的動作。
_Avoid_: install 指個別檔案複製時（本 repo 一律 symlink）
