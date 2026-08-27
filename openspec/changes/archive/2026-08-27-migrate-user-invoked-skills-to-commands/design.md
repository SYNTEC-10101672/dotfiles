# Design: migrate-user-invoked-skills-to-commands

## Context

- 部署鏈已存在且不修改：`claude/commands` 目錄透過 `claude-config-symlink` symlink 到 `~/.claude/commands`（Claude Code）與 `~/.config/opencode/commands`（OpenCode，見 `opencode-commands-symlink` spec）。新檔案放進 `claude/commands/` 即自動部署到兩工具。
- OpenCode 1.18.22 的 skill 機制：`disable-model-invocation` 不在認識的 frontmatter 欄位內（只認 `name`/`description`/`license`/`compatibility`/`metadata`），skills 也無法由使用者以 slash 觸發 — 這是遷移動機。
- 本環境 OpenCode 跑 oh-my-openagent plugin，`opencode/oh-my-openagent.json` 的 `claude_code.skills: false` 使 `~/.claude/skills/` 的 skills 完全不註冊。此為**另一個獨立變更**的範圍，本次不處理，但影響見「已知限制」。

## Goals / Non-Goals

**Goals**
- 5 個 user-invoked 檔案以 slash commands 提供，Claude Code 與 OpenCode 皆可由使用者觸發
- writing 系列（full content）自包含：command 檔即完整 workflow，不依賴 skill 載入
- 內容偏離 upstream 的部分最小且明確（frontmatter、`$ARGUMENTS` 行，僅此兩項）

**Non-Goals**
- 不搬 `grilling`、`writing-for-agents`、`domain-modeling`（model-invoked，skill 語意正確）
- 不修改 `oh-my-openagent.json`、不處理 openspec-* skills 在 OpenCode 的註冊問題
- 不改 Makefile / symlink 部署鏈
- 不為 5 個新 commands 建立 agent 專屬設定（用預設 agent）

## Decisions

### D1: 全文搬遷，不用 thin wrapper（適用 writing 系列）

`openspec-skill-command-parity` 的 thin-wrapper 模式（command → 載入 skill）不採用。理由：
1. 該模式的 skill 端必須可被載入；本環境 OpenCode 的 skill 載入被 `claude_code.skills: false` 關閉，wrapper 會斷
2. 這 5 個檔案的語意是 user-triggered prompt template，正是 command 的原生形態；`disable-model-invocation: true` 在 Claude Code 端的效果（不出現在 model 的可用清單）command 天生等效
3. 少一層間接、少 5 個檔案要維護對應

grill 系列 upstream 本身就是 thin wrapper（指向 `/grilling` skill），照搬即維持 1 句話 + `$ARGUMENTS` 行。

### D2: frontmatter 轉換規則

| Skill frontmatter | Command frontmatter |
|---|---|
| `name: writing-beats` | 刪除（command 名稱 = 檔名去掉 `.md`） |
| `description: ...` | 保留原句（讀者從 model 變為選單中的使用者，原句已足夠） |
| `disable-model-invocation: true` | 刪除（command 機制天生 user-only） |
| （新增） | `argument-hint`：writing 系列 `[raw material path]` / `[fragments-save-path]`；grill 系列 `[topic to grill]` |

`argument-hint` 是 Claude Code 認識的欄位（選單顯示輸入提示）；OpenCode 忽略不認識的欄位，無害。

### D3: `$ARGUMENTS` 行的設計

OpenCode command template 以 `$ARGUMENTS` 佔位符替換使用者輸入；Claude Code 同樣支援。沒有此佔位符，`/writing-beats ~/notes/pile.md` 後面的路徑會丟失。

寫在 body 第一行（frontmatter 之後、`<what-to-do>` 之前）：
- `writing-fragments.md` → `Fragments save path: $ARGUMENTS`
- `writing-beats.md` / `writing-shape.md` → `Raw material file: $ARGUMENTS`
- `grill-me.md` / `grill-with-docs.md` → `Topic to grill: $ARGUMENTS`

原 SKILL.md 的「If the user did not pass a path, ask once」邏輊保留在 body — 正好處理 `$ARGUMENTS` 為空（使用者沒帶參數）的 case。

### D4: 刪除包含 `agents/openai.yaml` 的整個 skill 目錄

5 個 skill 目錄各含 `agents/openai.yaml`（upstream 的 OpenAI invocation policy，內容為 `policy.allow_implicit_invocation: false`）。commands 機制沒有對應的 agents 目錄約定，此檔隨目錄刪除，user-only 語意由 command 機制保證。

### D5: vendoring 偏離記錄

遷移後 5 個檔案脫離「與 upstream byte-level 一致」的 vendor 約定。允許的偏離（且僅此兩項）：
1. Frontmatter 整段替換（見 D2）
2. 新增一行 `$ARGUMENTS` 行（見 D3）

Body 其餘內容照搬。日後 upstream 更新時，手動比對 body 區塊合併。

**實作期修訂（re-vendor）**：實作時發現 upstream 在 2026-08-18 初次 vendor 後已有更新（writing 系列 em-dash 清理、grill 系列改為 Skill tool 措辭、`grill-with-docs` description 改提 ADR 與 glossary）。經使用者決策，5 個 command 的 body 改抓遷移當下的 live upstream main（非本地舊 snapshot）。契約性質：T7 與 upstream 的比對對象是 live main branch — moving target，未來 upstream 再變更時 T7 會再失敗，屆時以 re-vendor 變更處理。

## Known Limitations

- `grill-me` / `grill-with-docs` commands 指向 `/grilling` 與 `/domain-modeling` skills。在 OpenCode 端，`claude_code.skills: false` 未開啟前這兩個 skills 載不到，commands 無法完整執行（Claude Code 端正常）。writing 系列 command 自包含，兩端皆正常。這是已知限制，不是本變更的缺陷；解除條件是另一個變更開啟 skills 註冊。

## Migration Plan

1. 建立 5 個 command 檔（內容轉換規則如上）
2. 刪除 5 個 skill 目錄
3. `make claude` + `make opencode` 重跑（其實 symlink 已在，僅驗證透通）
4. 驗證（見 tasks.md Tests）

風險低：git 版控下全可逆；不觸碰任何共用 config。
