# Proposal: add-matt-workflow

## Why

Matt Pocock 推薦的工作流五件套（`grill-with-docs` → `to-spec` → `to-tickets` → `implement` → `code-review`）目前只移植了頭尾（grill 系列、`code-review`），中間的 spec → tickets → implement 管線缺席，無法跑完整流程。使用者想讓這條工作流與既有 OpenSpec workflow 並存試用，作為未來可能全面轉移的評估路徑。

## What Changes

- 新增 4 個 vendor skill 資料夾至 `opencode/skills/`（body 與 upstream byte-identical，排除 `agents/openai.yaml`）：
  - `tdd/`：SKILL.md + tests.md + mocking.md（`implement` 的硬依賴）
  - `codebase-design/`：SKILL.md + DEEPENING.md + DESIGN-IT-TWICE.md（`tdd` 的條件依賴）
  - `prototype/`：SKILL.md + LOGIC.md + UI.md（grill 階段 UI/邏輯設計討論用）
  - `setup-matt-pocock-skills/`：SKILL.md + 5 個 seed templates（per-repo tracker 設定）
- 新增 4 個 slash commands 至 `opencode/commands/`：
  - `to-spec.md`、`to-tickets.md`、`implement.md`：frontmatter 轉換為 opencode command 格式（`description` 沿用 upstream 原句），body 照搬 upstream SKILL.md
  - `setup-matt-pocock-skills.md`：薄 wrapper（load skill 並執行），因 skill 本體需要夾帶 seed templates 資料夾
- 修改 `skill-self-containment` spec：新增 vendor skill 豁免 —— upstream 內文提及 `AGENTS.md` / `CLAUDE.md` 屬「目標 repo 指示檔的文件類型語意」，非引用本 repo 全域指示檔
- 零 Makefile / opencode 設定變更（`make opencode` 為目錄級 symlink，新檔案自動部署）

## Capabilities

### New Capabilities

（無 —— 本變更全部歸入既有 capabilities）

### Modified Capabilities

- `mattpocock-skills`：擴充 vendor 範圍（+4 個 skill 資料夾、+4 個 commands），確立「新資料夾排除 `agents/openai.yaml`」政策（既有 4 個 vendor skills 依原 requirement 不動、續留 openai.yaml）
- `skill-self-containment`：新增 vendor skill 對指示檔「文件類型語意」引用的豁免條款與對應 grep 驗證例外

## Impact

- `opencode/skills/`：+4 目錄、15 檔案（6 + 3 + 3 + 3）
- `opencode/commands/`：+4 檔案
- 既有 skills 與 commands（含 4 個已 vendor 的 mattpocock skills、grill 系列 commands）完全不動
- `openspec/specs/mattpocock-skills/spec.md` 與 `openspec/specs/skill-self-containment/spec.md` 於 archive 時套用各自 delta
- `README.md` 專案結構描述中 `opencode/` 的列舉（commands/skills 系列）小幅更新
- Upstream 來源：`https://github.com/mattpocock/skills` @ `c55ee46073ed923f86ce59a5eb3b6d895095d1b7`（記錄於 design.md，供日後同步比對）
