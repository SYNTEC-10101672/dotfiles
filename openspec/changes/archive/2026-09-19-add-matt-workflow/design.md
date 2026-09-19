# Design: add-matt-workflow

## Context

- 既有狀態：`mattpocock-skills` capability 已 vendor 4 個 skills（`grilling`、`writing-for-agents`、`domain-modeling`、`code-review`，byte-identical 含 `agents/`）與 2 個 grill commands（`grill-me.md`、`grill-with-docs.md`）。
- 探索結論（本次對話）：Matt 推薦工作流五件套中，`to-spec` / `to-tickets` / `implement` 未移植；依賴鏈為 `implement` → `tdd` → `codebase-design`（條件），`to-spec` / `to-tickets` → tracker 設定（`setup-matt-pocock-skills` 產出）；`prototype` 為 UI/邏輯設計討論的選配（使用者要）。
- 部署事實：`Makefile` 的 `opencode` target 對 `commands/`、`skills/` 做目錄級 symlink（`ln -sfn`），新檔案零部署成本、冪等。
- 使用者決策：與 OpenSpec workflow 並存試用（未來可能全面轉移）；vendor 內容一字不差（方便日後對 upstream diff）；保持英文；`agents/openai.yaml` 丟棄；tracker 用 local markdown（per-repo 由 setup 決定，不動公司 Jira）。

### 環境事實（共享）

- Upstream：`https://github.com/mattpocock/skills` @ `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`（main，2026-09-19 抓取驗證）
- Upstream 路徑前綴：skills 一律在 `skills/engineering/<name>/`；raw 檔案基底 URL 為 `https://raw.githubusercontent.com/mattpocock/skills/main/skills/engineering/`

## Goals / Non-Goals

**Goals:**

- 補完五件套工作流：4 個新 slash commands + 4 個新 skill 資料夾（15 檔）
- Vendor 內容 byte-identical（skills 整檔照搬；commands 僅 frontmatter 轉換），日後同步 upstream = 直接覆蓋 + diff
- `skill-self-containment` spec 豁免條款跟上 vendor 內容現實

**Non-Goals:**

- 不修改既有 4 個 vendor skills 與其他 skills/commands（含其 `agents/openai.yaml` 政策）
- 不移植非鏈上 skills（`diagnosing-bugs`、`triage`、`research`、`wayfinder`、`ask-matt`、`wizard`、`to-questionnaire`、`wait-what`、`teach`、`resolving-merge-conflicts`、`improve-codebase-architecture`）
- 不做 Jira / GitHub / GitLab tracker 整合（local markdown 即可，tracker 選擇是 per-repo 的 setup 決策）
- 不移除、不調整 OpenSpec workflow 及其 AGENTS.md 規則鏈

## Decisions

### D1: user-invoked → `commands/`（單檔），model-invoked → `skills/`（資料夾）

- `to-spec.md`、`to-tickets.md`、`implement.md`：opencode command 是單一 .md 檔，這三個 upstream skill 無附檔，直接落為單檔 command。結構沿用 `writing-skills` spec 確立的模式：YAML frontmatter（`description` 沿用 upstream 原句；不含 `name`、`disable-model-invocation`）+ body 照搬 upstream SKILL.md（略過 upstream frontmatter）。允許的偏離僅 frontmatter 轉換一項。
- `setup-matt-pocock-skills`：skill 本體引用「seed templates in this skill folder」（6 個附檔），單檔 command 裝不下 → 實體放 `skills/setup-matt-pocock-skills/`（整檔照搬），command 端 `setup-matt-pocock-skills.md` 為薄 wrapper（指引 load 該 skill 並執行），與 `grill-with-docs.md` 的薄指揮模式同一招。
- 替代方案（拒絕）：三個單檔 skill 也做成「資料夾 + wrapper」以保留 upstream 的 `agents/openai.yaml` —— 多一層間接卻只為保留一個已決定丟棄的惰性檔，不值。

### D2: 新資料夾排除 `agents/openai.yaml`

- 已驗證四份 openai.yaml 的完整內容：僅 `interface.display_name` / `short_description`（Codex UI 標籤）與 `policy.allow_implicit_invocation`（setup 的 Codex 端 user-invoked 開關）。無 subagent 定義、無行為內容（subagent 行為都以 prose 寫在各 SKILL.md 本文，opencode 端已由 `opsx:apply` 對 `code-review` 的使用驗證可行）。
- 既有 4 個 vendor skills 依原 requirement（byte-identical 含附屬檔案）續留 openai.yaml —— 新舊政策差異是自覺決策：舊不動（無授權變更）、新排除（本 change 決策）。

### D3: `skill-self-containment` 豁免條款

- `setup-matt-pocock-skills/SKILL.md` 本文大量提及 `AGENTS.md` / `CLAUDE.md`（教學如何挑選與編輯**目標 repo** 的指示檔）。這是文件類型語意，不是引用本 repo 的全域指示檔 —— 與 `writing-for-agents` 的既有豁免同類。
- Delta：MODIFIED「Skills 與 commands 不引用全域指示檔」requirement，例外清單加入 vendor skills；對應 grep 驗證情境的排除清單同步擴充。
- 其餘 13 個新檔與 3 個新 commands 經查無 `CLAUDE.md` / `AGENTS.md` 字眼，不受影響。

### D4: Upstream provenance 與同步程序

- 來源與 commit 記於本檔 Context。日後更新程序：對 upstream main 重新抓取對應路徑覆蓋（同步 = 覆蓋，同既有 spec 政策），diff 基準點 = `c55ee460`。路徑對應表見 specs delta 的 requirement 內容。

### D5: 語言

- Vendor 檔案保持英文原狀（byte-identical 的必然結果，亦為使用者決策）。各目標 repo 消費端產物（spec / ticket 內文）的語言由目標 repo 自行規範，本 change 不約束。

## Risks / Trade-offs

- [upstream 演進使 vendor 內容過時] → 同步 = 覆蓋政策 + provenance commit 記錄（D4），更新是單一機械動作
- [兩條工作流並存的 vocab 混淆（OpenSpec task vs Matt ticket）] → 使用者明確選擇並存試用；OpenSpec 流的 AGENTS.md 規則鏈（`/opsx:apply` → `code-review` → archive）完全未動，不受影響
- [setup 會在目標 repo 的 AGENTS.md / CLAUDE.md 加 `## Agent skills` 區塊] → setup 本身設計為 in-place update 且不覆蓋使用者編輯；目標 repo 的行為，非本 repo 的事
- [body 內 "Call the Skill tool" 等 Claude 用語在 opencode 的相容性] → 既有 `grill-with-docs.md` 已以同模式上線使用，屬已驗證路徑
- [新舊 openai.yaml 政策不一致造成日後困惑] → D2 明記差異與理由；若日後要統一（例如舊 4 個也刪），另開 change

## Migration Plan

1. 從 upstream raw URL 抓取 15 個 skill 檔案落地 `opencode/skills/{tdd,codebase-design,prototype,setup-matt-pocock-skills}/`
2. 建立 3 個轉檔 commands + 1 個薄 wrapper 至 `opencode/commands/`
3. 更新 `README.md` 的 `opencode/` 結構列舉
4. `make opencode`（冪等）
5. 驗證 T1–T6 全綠
6. Rollback：`git checkout` 回復工作區 + `make opencode`（symlink 指向不變，內容回復即生效；新資料夾若要連部署端清除，`make uninstall && make opencode` 亦冪等重建）

## Open Questions

（無 —— 探索階段已全部決策）
