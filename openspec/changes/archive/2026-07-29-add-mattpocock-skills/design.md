## Context

- **Repo**：`/home/syntec/personal/dotfiles`（變更根目錄）
- **Skills 真實位置**：`/home/syntec/personal/dotfiles/claude/skills/`（vendored，進 git）
- **Symlink 機制**：`~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/`（由 `claude-config-symlink` capability 提供，本變更不修改）
- **opencode 載入機制**：oh-my-openagent plugin 在每個 session 開始時掃描 `~/.claude/skills/*/SKILL.md`，根據 YAML frontmatter 決定 user-invoked 或 model-invoked
- **既有 skills**：`openspec-*` 系列（13 個）+ `tutoring` + `openspec-code-review`，全部 vendored
- **Upstream source**：`https://github.com/mattpocock/skills`（MIT 授權）
- **無 submodule**：dotfiles repo 的 `.gitmodules` 不存在，所有 skills 都是 plain files

## Goals / Non-Goals

**Goals:**

- 在 `dotfiles/claude/skills/` 安裝 4 個 mattpocock skill（grill-me、grilling、writing-great-skills、domain-modeling），檔案來源為 mattpocock/skills repo main 分支
- 保持 vendor copy 的乾淨度：不修改任何 SKILL.md 內容（讓日後重新 vendor 時 diff 乾淨）
- 透過既有 symlink 機制即時生效，無需修改 opencode 或 claude 設定

**Non-Goals:**

- 不安裝其他 mattpocock skills（grill-with-docs、teach、to-spec、implement、code-review、prototype、research、tdd、diagnosing-bugs、resolving-merge-conflicts、codebase-design、wayfinder、triage、ask-matt、handoff、setup-matt-pocock-skills、to-tickets、domain-modeling 已選）
- 不設定自動更新 upstream 的腳本或 cron
- 不修改任何既有 SKILL.md（包含 openspec-* 與 tutoring）
- 不在各專案 CLAUDE.md 加「讀 CONTEXT.md」指令（屬於各專案自己的設定，非 dotfiles 層級職責）
- 不修改 `~/.claude/CLAUDE.md` 或 `dotfiles/claude/CLAUDE.md`

## Decisions

### Decision 1: 採用 vendor copy，不用 `npx skills` installer 或 git submodule

**選 vendor copy 的理由：**
- 與既有 `openspec-*` / `tutoring` skills 一致（全部都是 vendored plain files）
- 完全控制要裝哪幾個（只需 4 個，不需要整包 repo）
- 檔案路徑精確可控（直接寫入 `dotfiles/claude/skills/`）
- 透過既有 symlink 機制即時生效，不需額外設定

**Alternatives considered:**
- `npx skills@latest add mattpocock/skills`：互動式 installer，會問「裝在哪個 agent」但 opencode 不在選項；可能噴不需要的設定檔到不對的位置；無法精確控制只裝 4 個
- Git submodule 整個 mattpocock/skills repo：為 4 個 skill 拖整個 repo；submodule 維護痛；與現有 vendored 風格不一致；`.gitmodules` 從無到有增加複雜度

### Decision 2: 不修改任何 SKILL.md 內容

保持 vendor copy 與 upstream 一致，理由：
- 日後重新 vendor 時 diff 乾淨，一眼看出 upstream 改了什麼
- 若需客製（例如把 model-invoked 降級為 user-invoked），改在 dotfiles 層級的 wrapper 或 CLAUDE.md 指令，不污染原檔
- 符合「最小變更」原則

### Decision 3: 只裝 4 個，明確排除其他

**裝的 4 個與理由：**
| Skill | Invocation | 為什麼裝 |
|---|---|---|
| grill-me | user | explore 後的嚴苛驗證關卡 |
| grilling | model | grill-me 的核心依賴（thin wrapper） |
| writing-great-skills | user | 寫 skill / CF 文件時的設計參考 |
| domain-modeling | model | 主動維護 CONTEXT.md 與 ADR |

**排除清單與理由：**
| 排除 | 理由 |
|---|---|
| grill-with-docs | 與 grill-me 重疊；domain-modeling 已裝可自動介入；日後需要再補裝一個檔即可 |
| teach | 無明確使用情境（非寫教材用途） |
| to-spec / to-tickets / implement / code-review / wayfinder / triage | 與既有 openspec-* workflow 高度重疊，會造成流程分裂 |
| prototype / research / handoff / diagnosing-bugs / tdd | 目前無需求；未來按需補裝 |
| setup-matt-pocock-skills | per-repo 設定工具，非 opencode skill 機制 |
| codebase-design / ask-matt / resolving-merge-conflicts | 與既有工具不符或無需求 |

### Decision 4: 不設定自動更新策略

Upstream 更新由人工觸發：需要時自行 `git clone mattpocock/skills` 到 `/tmp`，diff 比對後手動覆蓋。理由：
- 與 openspec-* skills 現況一致（也是手動維護）
- 避免自動更新帶來非預期的行為改變
- mattpocock skills 變動頻率不高，自動化成本不划算

### Decision 5: 不在本變更處理 CONTEXT.md 載入策略

`domain-modeling` 會在當前 repo 懶建立 `CONTEXT.md` 與 `docs/adr/`，但「是否在 session 開始自動讀取」屬於各專案自己的 CLAUDE.md / AGENTS.md 設定，不是 dotfiles 層級職責。本變更只負責安裝 skill 本身，CONTEXT.md 載入策略由各專案自行決定。

## Risks / Trade-offs

- **[Risk] model-invoked skills 增加 context load** → `grilling` 與 `domain-modeling` 的 description 會進入每個 session 的 context。Mitigation：兩者 description 都很短（< 100 字），影響有限；若實測發現 agent 誤觸發頻繁，可手動在 SKILL.md 加 `disable-model-invocation: true` 降級為 user-invoked（會破壞 vendor 乾淨度，屆時再評估）
- **[Risk] domain-modeling 在非預期情境寫出 CONTEXT.md** → 它會在 agent 判斷「討論領域詞彙」時自動建立檔案。Mitigation：第一次發生時審視內容正確性；若太吵可降級為 user-invoked
- **[Risk] upstream 版本漂移** → 無自動更新，可能錯過重要 fix。Mitigation：可接受；需要時手動重新 vendor
- **[Trade-off] vendor copy 失去 upstream 自動同步** → 換取完全控制、精簡安裝、與既有 skills 一致的維護模式
- **[Trade-off] grill-me 不會自動讀 CONTEXT.md** → 因為沒有 grill-with-docs 的 wrapper。Mitigation：domain-modeling（model-invoked）會在相關情境自動介入；必要時可事後補裝 grill-with-docs
