# Proposal: add-artifact-review-gate

## Why

`openspec-propose` step 8 的 momus gate 與 OmO Momus agent 的內建契約錯位：Momus（非 GPT model 用的 `MOMUS_DEFAULT_PROMPT`）規定只接受恰好一個 `.omo/plans/*.md` 檔案路徑，收到 `openspec/changes/<name>/` 目錄會直接判 invalid；實際運作仰賴主 AI 即興轉檔成 OmO 格式再送審（每次 propose 都付出隱藏轉檔成本，且 Momus 因此看不到 delta specs 與 T\* 完整契約）。verdict 詞彙也錯位：skill 寫「loop until APPROVED」，但 Momus 只會輸出 `[OKAY]` / `[ITERATE]` / `[REJECT]`，通過條件永不成立。此 gate 需要一個契約對齊的替代者。

## What Changes

- 新增 `claude/skills/openspec-artifact-review/SKILL.md`：propose 階段的 artifact 審查 skill，移植 Momus 審查準則（blocker-only、approval bias、max 3 issues）並擴充 OpenSpec 專屬檢查（delta spec 格式、T\* Command/Expected 契約、artifacts 內部矛盾、以 codebase 驗證 reference）。審查者 read-only 只報告，修改由主 AI 執行；verdict 使用 `[OKAY]` / `[ITERATE]` / `[REJECT]`；ITERATE 自動修復最多 2 輪後升級詢問使用者
- 修改 `claude/skills/openspec-propose/SKILL.md` step 8：以 `openspec-artifact-review` skill 取代 `task(subagent_type="momus", ...)` 呼叫，verdict 詞彙同步對齊
- 不引入外部驗證（websearch / MCP 查證不在此 gate 範圍），審查僅依賴本地 codebase 與 artifacts 內容

## Capabilities

### New Capabilities

- `artifact-review-gate`: propose 階段 artifact 審查門檻 — 審查準則（reference 驗證、可執行性、blocker、T\* 契約、OpenSpec 格式）、verdict 契約、修復循環上限與 read-only 紀律

### Modified Capabilities

- `spec-test-contract`: 「T\* 隨 artifacts 通過 momus gate 與人工 review」的 requirement 敘述改為通過 artifact review gate（`openspec-artifact-review` skill），momus 字樣移除
- `openspec-skill-command-parity`: 保留 skills 清單由 7 個擴為 8 個（加入 `openspec-artifact-review`）；新 skill 為 propose 內部步驟，不新增對應 opsx command wrapper

## Impact

- 檔案：新增 `claude/skills/openspec-artifact-review/SKILL.md`；修改 `claude/skills/openspec-propose/SKILL.md`；delta specs sync 後更新 `openspec/specs/spec-test-contract/spec.md` 與 `openspec/specs/openspec-skill-command-parity/spec.md`
- 全為 markdown/docs 變更，無程式碼、無依賴、無 breaking change
- 解除此 gate 對 OmO `momus` agent 的依賴 — 移除 oh-my-openagent plugin 後 gate 仍可運作
