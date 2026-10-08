# NOTES.md

教學工作區的 working notes（使用者偏好、安排決策）。

## 工作區安排決策

- 教學工作區放在 `docs/teach-herdr/`（不是 repo root）：避免污染 dotfiles 根目錄，符合 repo 既有 `docs/` 慣例。
- 未來 `/teach` session：以 `docs/teach-herdr/` 為 teaching workspace root（AGENTS.md 已加 pointer）。
- 原始參考資料 `reference/herdr-skill-0.9.3.md` 是 `herdr --skill` 的逐字輸出（版本綁定 0.9.3），升級 herdr 後應重新產出一份並註記版本差異。

## 使用者偏好

- 語言：繁體中文，技術術語英文。檔案路徑、指令、config 值原樣精確。
- 已是 herdr 日常使用者（keybinding 熟、config 已建制）——課程跳過基礎，直接進 agent automation / worktree / socket API。
- 環境事實：herdr 0.9.3、gruvbox theme、zsh + tab 自動命名 hooks（ADR-0003）。
- 使用者同時跑多個 opencode instance（`herdr agent list` 可見即時範例）——課程練習可用真實 agents，但要無害（scratch 任務、`--no-focus`）。
- **Matt 工作流整合（2026-10-05 確認）**：課程要與 Matt skills（/to-spec、/to-tickets、/implement、/code-review）接軌；方案 B = 機制課與應用課分離（0003 為 Matt pipeline 專課）。
- **Commit 策略 (b)**：worktree agents 只做不 commit（ticket constraints 註明），使用者在主 checkout 統一 review + /commit。熟練後可升級 (a) 各自提交。

## 課程路線圖（ZPD 順序）

1. **0001 — agent 協作 loop**（已完成 2026-10-05）：`agent prompt/wait` + 五狀態 + TARGET 語法（split → start → prompt --wait → read）
2. **0002 — worktree workspaces**（已完成 2026-10-05）：`herdr worktree create/open/remove`、workspace group、`--trust-repository` 語意
3. **0003 — Matt 工作流 × herdr**（已完成 2026-10-05）：ticket → worktree per ticket → `agent prompt` 遞送 /implement（絕對路徑）→ 策略 (b) 審核收斂 → merge/remove。兩大 gotcha：.scratch gitignored、worktree agent 的 commit 邊界。demo ticket 保留於 `.scratch/teach-0003-pipeline/issues/01-demo-ticket.md`（drill 用）
4. **0004 — pane orchestration（非 agent 程序）**：`pane run/wait-output/read`、四種 read source、與 agent loop 的分工
5. **0005 — detection 深入**：`agent explain`、detection manifests、local override（`~/.config/herdr/agent-detection/<agent>.toml`）——`agent wait` 可靠度的基礎
6. **0006 — socket API 直呼**：newline-delimited JSON、`herdr api` 查 schema、`agent.prompt` 帶 wait object（race-free）、event subscription
7. **0007 — session 持久度**：named sessions（實驗隔離）、detach/restart/handoff 對照表、native agent session restore（opencode `--session <id>`）

凍結中（mission out of scope，解凍時說一聲）：
- remote machines（`herdr machine`、`--machine` prefix、跨機 agent 控制）→ 入口：blog「Connecting the machines」
- plugin 生態（1,445 個 community plugins）與 plugin 開發
- Herdr Cloud（尚未開放）

## 待辦

- ~~librarian 官方文件調查~~（已完成，RESOURCES.md 已補齊；worktree 文件位置已確認）
- Lesson 0004（pane orchestration）待使用者 /teach 繼續時撰寫
- herdr 升級後：重產 `reference/herdr-skill-<version>.md` 並 diff
- demo ticket（`.scratch/teach-0003-pipeline/`）若被清掉，重新建立後 0003 drill 才能用（格式見 NOTES 驗證記錄與 lesson 內文）

## 驗證記錄

- 2026-10-05：Lesson 0001 的 drill 在使用者環境完整跑通（split wK:p2 → `agent start trainee --kind opencode` → `prompt --wait` 返回 done → read 找到 "OK"（3.0s）→ `pane close`）。教材中的「預期輸出」皆來自此次真實執行。
- 2026-10-05：Lesson 0002 的 drill 完整跑通（dotfiles repo：`worktree create --branch teach-0002` → wN、checkout 在 ~/.herdr/worktrees/dotfiles/teach-0002 → `workspace close wN` 後 checkout 留存 → `worktree open` 重新接成新 workspace wP → `worktree remove` 刪 checkout → `git branch -d teach-0002`）。發現：使用者已在 appkernel 手動維護多個 git worktrees（appkernel_ATEST_8947、appkernel_GTK、appkernel_review）——已作為 Lesson 0002 的 hook 與「收編」加分題。
- 2026-10-05：Lesson 0003 的整條 Matt pipeline 實測跑通（`.scratch/teach-0003-pipeline/issues/01-demo-ticket.md` → `worktree create --branch teach-pipe-01` = workspace wQ → `agent start impl-01` → `agent prompt impl-01 "/implement <絕對路徑>"` → tab 標題變「Implementing work from 01-demo-ticket.md」證實 /implement 被執行 → 51.6s 返回 done → `git status` 僅 `?? docs/PIPELINE-DEMO.txt`（策略 b 遵守，agent 主動回報未 commit 之偏離）→ `worktree remove --force` + `branch -d` 清理）。demo ticket 保留供 drill。
- 2026-10-05（補充機制驗證）：`agent prompt` 遞送 `/eli5 ...` 至另一 opencode，mode 在該 session 生效——slash 指令經 prompt 傳遞可執行（0003 派工機制的基礎）。
