# Design: migrate-config-to-opencode

## Context

### 環境現況（跨 task 共用事實）

- 使用者已解除 Claude 訂閱，日常工具為 opencode（Z.AI GLM provider，`GLM_API_KEY` 於 `~/.env`）。`~/.claude/` 內含 credentials/history/transcripts 等 runtime，**保留不刪**。
- 本 repo 現存兩套 AI 工具設定：
  - `claude/`：`CLAUDE.md`（全域指示檔，41 行，全文無 claude 字眼）、`settings.json`、`commands/`（9 檔含 `opsx/`）、`skills/`（12 目錄）、`scripts/`（4 檔）
  - `opencode/`：`opencode.json`、`package.json`、`oh-my-openagent.json`、`plugins/`（`guard.ts`、`notify.ts`）、`scripts/`（`notify-stop.sh`、`notify-waiting.sh`，與 `claude/scripts/claude-notify-*.sh` 內容 identical）
- 部署現況（Makefile）：
  - `make claude` → `~/.claude/`（`settings.json`、`CLAUDE.md` 單檔 + `commands`/`skills`/`scripts` 目錄 symlink）
  - `make opencode` → `~/.config/opencode/`（其中 `commands` symlink 借用 `$(ROOT_DIR)/claude/commands`）
  - `make scripts` → `~/bin/claude-glm`、`~/bin/claude-code-statusline`（來源 `claude/scripts/`）
- OpenCode 官方路徑（librarian 查證）：skills 原生 `~/.config/opencode/skills/`（複數）、commands `~/.config/opencode/commands/`、全域指示 `~/.config/opencode/AGENTS.md`。OpenCode 不讀 `~/.claude/commands/`；`~/.claude/CLAUDE.md` compat 為 V1 legacy，V2 靜默失效。
- 前置清理已完成（change `cleanup-claude-md-references`，commit `f0249db`）：`claude/skills/` 與 `claude/commands/` 內文零全域指示檔引用；唯一殘留的 "CLAUDE.md" 字眼在 `writing-for-agents/SKILL.md`（2 處文件類型詞彙列舉，`skill-self-containment` 豁免，不動）。
- 指示檔內文狀態：`claude/CLAUDE.md` 全文無 claude 字眼（mv 後零修改）；`.claude/CLAUDE.md` 有 3 處需改寫（Architecture 段、Individual modules 行的 `make claude`、New Machine Setup 段的 Claude Code plugins）。
- `opencode.json` 已使用 `@slkiser/opencode-quota` plugin + `experimental.quotaToast` 顯示 quota/model — claude 端 statusline 體系（`claude-glm`、`claude-code-statusline`、`/tmp/glm-quota-cache.json`）無 repo 內承接者，純刪。

### Constraints

- **先清理後搬遷**（session 決策）：搬遷驗證條件是「移動前後 session 行為一致」，內容修改與檔案移動不得混在同一 diff — 例外僅限兩個指示檔的必要改名改寫。
- `~/.claude/` runtime（非 symlink 部分）不動。
- 不修改 `oh-my-openagent.json` 的 `claude_code` 區塊（全 false，防禦性明示關閉）。

## Goals / Non-Goals

**Goals:**
- AI 工具設定單一命名空間：全部位於 `opencode/`（+ repo root `AGENTS.md`），部署單一 target `make opencode`
- `git mv` 保留歷史，`git log --follow` 可追溯
- 部署切換不斷頭：中間狀態（dangling symlink 窗口）限縮在單一 task 內
- Spec 體系與新拓撲一致：8 個 capability 移除、1 個新增、18 個改寫

**Non-Goals:**
- 不搬遷/清理 `~/.claude/` runtime（credentials、history、transcripts）
- 不重寫 skills/commands 內容（清理已完成，內文零修改）
- 不動 `opencode/plugins/`、`opencode/scripts/`、`opencode/oh-my-openagent.json`
- 不處理 opencode 本體或 plugin 的升級/設定變更

## Decisions

### D1：git mv 而非 copy + delete
`git mv` 保留 rename 紀錄與 `--follow` 歷史。copy + delete 會斷歷史，blame/bisect 對 settings 類檔案特別有用。
*Alternative*: copy + delete（被否決 — 斷歷史）。

### D2：兩個指示檔的對應關係
- `claude/CLAUDE.md` → `opencode/AGENTS.md`，部署為 `~/.config/opencode/AGENTS.md`（全域，所有 repo 的 session 生效）
- `.claude/CLAUDE.md` → root `AGENTS.md`（本 repo 的 project instructions，OpenCode 於 repo 目錄啟動時載入）
依據：OpenCode 全域指示檔官方路徑為 `~/.config/opencode/AGENTS.md`；project 層約定為 repo root `AGENTS.md`。

### D3：skills/commands 以「目錄 symlink」部署，AGENTS.md 單檔 symlink
沿用 `opencode` target 既有模式（`plugins`、`scripts` 目錄 symlink；`opencode.json` 等單檔 symlink）。skills 目錄整體 symlink 到 `~/.config/opencode/skills`；`AGENTS.md` 單檔 symlink 到 `~/.config/opencode/AGENTS.md`。與 `claude-config-symlink` 的混合策略同構，只是宿主換人。

### D4：遺孤 requirements 落戶表（`claude-config-symlink` 解散）
| 遺孤 | 落戶 | 理由 |
|---|---|---|
| 全域指示檔須載明 OpenSpec TDD 規範（`> 驗證：` 區塊、mark `[x]` 前跑 `openspec-tdd-verify`） | `self-contained-tasks` | 同型先例：該 spec 已有「全域指示檔 MUST 記錄禁代名詞規範」requirement |
| explore mode 寫檔白名單（僅 `openspec/changes/**` 與 `CONTEXT.md`） | `skill-authoring-governance` | skill 檔內容治理主題 |
| CONTEXT.md 寫入須走 domain-modeling 程序 | `skill-authoring-governance` | 同上 |
| Makefile 禁止 `backup`/`restore`/`clean` target | `dotfiles-install` | 該 spec 管 Makefile install/uninstall/check 行為 |
| `.gitignore` 排除規則（opsx/openspec-* 來源路徑） | 隨 capability 死亡 | 純歷史遺跡 — 該排除規則已不存在於 `.gitignore` |
*Alternative*: 新建 `agents-md-content` capability 統一收納（被否決 — 既有 specs 已有同型 requirement 先例，分散落戶語意更貼合各 spec 主題）。

### D5：attribution 規範改寫（`commit-rules-placement`）
刪除「AI attribution 由 `claude/settings.json` 機械控制」引用，不新增替代敘述。理由：spec 既有的「`commit.md` SHALL NOT 添加 `Co-Authored-By` 或任何 AI 署名 trailer」requirement 已自包含承載規則；opencode 預設不加 AI 署名，無需機械控制點。

### D6：capability removal 的 delta 表達
8 個死亡 capability 各產出 delta spec 檔，以 `## REMOVED Requirements` 列出全部 requirements（附 Reason/Migration），archive 時 specs sync 清空移除。`project-claude-md` → `project-agents-md` 以 REMOVED + ADDED 表達改名。

### D7：部署切換順序（不斷頭）
```
[repo 內，同一 task]
git mv ×4 + 刪除 ×3 + Makefile 改寫
        │
        ▼
make opencode   ← 重建 ~/.config/opencode/* symlinks（含新來源）
        │        （dangling 窗口：mv 到 make 之間，秒級）
        ▼
⏸ HARD CHECKPOINT：使用者開新 session 驗證
   - 全域指示檔生效（~/.config/opencode/AGENTS.md 載入）
   - skills/commands 可用（/opsx、/commit 等）
   - notify/BEL 正常
        │ 驗證通過
        ▼
拔 ~/.claude/ 五條 config symlinks（CLAUDE.md、settings.json、
commands、skills、scripts）＋ ~/bin/claude-glm、~/bin/claude-code-statusline
（~/.claude/ runtime 本體保留）
```
風險控制：mv + Makefile + `make opencode` 必須在同一 task 內連續執行；`make opencode` 的 `ln -sfn` 對 dangling symlink 會直接替換，無需先清。

### D8：`tmux-window-rename` 一併移除
該 capability 規範 `claude-glm` 啟動時的 tmux window 改名，屬 claude-glm 專屬行為，無 opencode 承接者（opencode 不透過 wrapper 啟動），隨 `claude-glm` 刪除而移除。

## Risks / Trade-offs

- [git mv 後、`make opencode` 前，`~/.config/opencode/commands` dangling] → 同一 task 內連續執行 mv → Makefile → `make opencode`，窗口秒級且僅影響「期間新開的 slash command 查詢」
- [本 session 自身跑在 opencode 上，套用當下 commands 來源切換] → `make opencode` 即時重建 symlink；已載入 context 的 skill 內容不受影響；checkpoint 後的新 session 為驗證基準
- [全域指示檔改名後，`~/.claude/CLAUDE.md` V1 compat 若仍在舊版 opencode 生效，拔 symlink 前新舊並存] → 切換順序已定：新 session 驗證 `~/.config/opencode/AGENTS.md` 生效後才拔舊鏈，不存在新舊不一致窗口
- [27 個 spec deltas 中路徑改寫量大，人工遺漏] → T* 以 grep 對 `openspec/specs/`（archive 後）掃 `claude/`、`~/.claude/` 殘留；artifact review gate 逐檔核對落戶表
- [`claude-task-notify`/`claude-waiting-indicator` 移除後 BEL/`@claude_state` 行為失去 spec 覆蓋] → 行為由 `opencode-native-notify` capability 承接（`plugins/notify.ts` 呼叫 `scripts/notify-*.sh`）；若 review 發現 script 細分行為（如 BEL 格式）未覆蓋，屬既有 gap，不在此 change 擴大範圍

## Migration Plan

1. Repo 變更（單一 commit）：git mv ×4 → 刪 ×3 → Makefile → `.gitignore` → README/SETUP.md/env.example
2. `make opencode`（部署新拓撲）
3. **HARD CHECKPOINT**：使用者開新 session 驗證（見 D7 清單）
4. 拔 `~/.claude/` 五條 config symlinks + `~/bin/claude-*` 兩條
5. `openspec archive`（specs sync：8 移除、1 新增、18 改寫）

Rollback：步驟 1-2 在 commit 前 `git checkout`；步驟 4 之後若需回滾，重建 symlinks（`make claude` 已刪，需手動 `ln -s` 或 revert commit 後 `make claude`）。

## Open Questions

（無 — A/B/C/D 決策已於 explore session 全部定案）
