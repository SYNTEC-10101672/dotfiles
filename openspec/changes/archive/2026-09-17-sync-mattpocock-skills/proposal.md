# Proposal: sync-mattpocock-skills

## Why

`opencode/skills/` 內 3 個 mattpocock vendor skills（`grilling`、`writing-for-agents`、`domain-modeling`）落後 upstream 數個版本：`grilling` 還是「一次一題」的舊行為（upstream 已演化為 design tree / frontier / 一輪多題格式）、`domain-modeling` 在 commit `6526874` 被拔除 ADR 支援後與 upstream 分歧（使用者的 workflow 願景已轉向，ADR 要回來）。另外 `openspec-code-review` skill 是 Matt `code-review` 舊版的濃縮改編，缺少 upstream 最新版的完整 Fowler 12 smells 定義（what it is → how to fix）與 spec source 自動探測，且本地 patch 造成每次同步都要手動 merge。

同時存在兩個 pre-existing spec drift：`mattpocock-skills` spec 要求 `domain-modeling/ADR-FORMAT.md` 必須存在（現實已被刪）；`openspec-code-review` spec 要求 `opencode/AGENTS.md` 必須記錄「apply 後必跑 code review」規範（現實從未寫入）。本變更一併修正。

## What Changes

- 覆蓋 `opencode/skills/grilling/` 為 upstream 最新版（行為升級：一次一題 → 一輪多題帶建議答案）
- 覆蓋 `opencode/skills/domain-modeling/` 為 upstream 最新版（ADR 支援回歸：`ADR-FORMAT.md` + "Offer ADRs sparingly" 段落，撤銷 `6526874` 的拔除決策）
- 覆蓋 `opencode/skills/writing-for-agents/` 為 upstream 最新版（僅標點風格差異，零行為風險）
- 新增 `opencode/skills/code-review/`：Matt 最新版 **byte-identical** 複製，不做任何本地修改
- 修改 `opencode/commands/opsx/apply.md` Step 7 的 invocation：改呼叫 `code-review` skill，並在呼叫處提供 OpenSpec 適配資訊（spec source = active change artifacts、fixed point = merge-base、無 issue tracker）
- 刪除 `opencode/skills/openspec-code-review/`（由 `code-review` 取代）
- `opencode/AGENTS.md` 補入「apply 後必跑 `code-review`」規範文字（修正 pre-existing drift）
- 上述 4 個 vendor skills 一律含 `agents/` 目錄原封複製（`mattpocock-skills` spec 明訂 `agents/openai.yaml` 必須存在；verbatim 原則：vendor 檔案零本地修改，同步 = 覆蓋）

## Capabilities

### New Capabilities
- `code-review`: 雙軸平行 sub-agents code review 能力，skill 本體為 `mattpocock/skills` upstream verbatim；OpenSpec 適配（spec source、fixed point、無 tracker）由 `opsx:apply` 呼叫處提供。承接原 `openspec-code-review` capability 的 apply 後觸發、Fix Loop、AGENTS.md 規範等 contract

### Modified Capabilities
- `openspec-code-review`: capability 移除——skill 更名為 `code-review` 併入新 capability，原 requirements（skill 檔案結構、舊版流程細節）由 `code-review` capability 取代；apply 後觸發與 Fix Loop contract 平移不變
- `openspec-skill-command-parity`: skills 目錄保留清單變更——`openspec-` 開頭目錄由 4 個減為 3 個（`openspec-code-review` 移除），非 `openspec-` 前綴新增 vendor skill `code-review`；apply command 引用改為 `code-review`
- `mattpocock-skills`: vendor skill 清單由 3 個擴為 4 個（加入 `code-review`，upstream 對應 `skills/engineering/code-review/`）；「不影響既有 skills」requirement 的清單同步更新（`openspec-code-review` 移出、`code-review` 移入）；確認 verbatim 同步原則（覆蓋更新屬 spec 授權的維護行為）

## Impact

- `opencode/skills/`：`grilling/`、`domain-modeling/`、`writing-for-agents/` 內容更新；新增 `code-review/`；刪除 `openspec-code-review/`
- `opencode/commands/opsx/apply.md`：Step 7 invocation 一處改寫
- `opencode/AGENTS.md`：新增一行 code review 規範
- 行為變更：`grilling` 互動節奏改變（一輪多題）；`domain-modeling` 恢復 ADR 提案（sparingly 三條件）；code review 的 spec 軸比對來源由「寫死 OpenSpec artifacts」改為「呼叫處注入」
- 不動：`tutoring`、`openspec-artifact-review`、`openspec-sync-specs`、`openspec-tdd-verify`、`opencode/commands/` 全部檔案（`opsx/apply.md` 除外）
