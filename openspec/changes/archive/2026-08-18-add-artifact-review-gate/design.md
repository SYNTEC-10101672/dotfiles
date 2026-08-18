# Design: add-artifact-review-gate

## Context

- 現況：`claude/skills/openspec-propose/SKILL.md` step 8 以 `task(subagent_type="momus", prompt="openspec/changes/<name>/")` 呼叫 OmO 的 Momus agent
- Momus 內建契約（非 GPT model 走 `MOMUS_DEFAULT_PROMPT`）規定輸入 MUST 為恰好一個 `.omo/plans/*.md` 路徑，其他輸入 invalid；實測行為：Momus 喊 invalid，主 AI 即興轉一版 OmO 格式再送審
- Momus 只檢查 tasks 與 QA scenario，看不到 delta specs；verdict 詞彙 `[OKAY]` / `[ITERATE]` / `[REJECT]` 與 skill 期待的 `APPROVED` / `NEEDS-REVISION` 錯位，「loop until APPROVED」條件永不成立
- 使用者長期考慮移除 oh-my-openagent plugin，新機制不得依賴 OmO 專屬的 agent 調度（`subagent_type` / `task(category=...)`）
- 既有先例：`claude/skills/openspec-code-review/SKILL.md` 將審查準則寫進 skill 當 brief、spawn 一般 agent 執行，不需要額外 agent 設定檔

## Goals / Non-Goals

**Goals:**

- propose 階段的 artifact 審查 gate 與被審對象（OpenSpec change artifacts）契約對齊
- 審查準則繼承 Momus 已打磨的紀律（blocker-only、approval bias、max 3 issues）並擴充 OpenSpec 格式與 T\* 契約檢查
- 移除對 OmO `momus` agent 的依賴

**Non-Goals:**

- 外部驗證（websearch / MCP 查證套件版本、API 行為）— 明確排除
- 審查者修改 artifacts — 修訂一律由主 AI 執行
- apply 階段的 code review（`openspec-code-review` skill 職責，不動）
- 變更 OmO plugin 本身或 `oh-my-openagent.json`

## Decisions

### D1: 以 skill 形式實作，比照 openspec-code-review 模式

新 `claude/skills/openspec-artifact-review/SKILL.md` 把審查準則完整寫在 skill body 當 brief，spawn 一般 agent（不指定 OmO 專屬 `subagent_type`）。

- 選此原因：審查準則是「知識」不是「身分」，不需要固定 agent 定義 / 綁 model / 工具白名單；且拔除 OmO 後仍可運作
- Alternatives:
  - custom agent 定義於 `opencode.json` — 多一份設定要維護，且綁 opencode 生態
  - adapter 轉檔產出 `.omo/plans/*.md` 餵 Momus — 保留即興轉檔的成本，且 Momus 永遠看不到 delta specs，只解決輸入格式不解決檢查內容

### D2: 審查準則 = Momus 移植 + OpenSpec 擴充

移植：blocker-only、approval bias（有疑慮時通過）、max 3 issues、reference 驗證（本地讀檔確認存在與內容相符）、可執行性（任務有起點）。擴充：delta spec 格式（section header、`#### Scenario:` WHEN/THEN）、T\* Command/Expected 契約（沿用 `spec-test-contract` capability 的定義）、artifacts 內部矛盾（proposal/design/specs/tasks 相互牴觸）。

- 選此原因：Momus 準則經上游打磨（anti-perfectionism 條款、具體 anti-pattern 範例），直接繼承降低自訂 prompt 的試錯成本

### D3: verdict 詞彙沿用 `[OKAY]` / `[ITERATE]` / `[REJECT]`

- 選此原因：三值語意完整（通過 / 可修 / 需使用者決策），`openspec-propose` step 8 的通過條件與處理邏輯直接對應 `[OKAY]` / `[ITERATE]`；不另造新詞避免第三份詞彙
- 同步修改：`openspec-propose/SKILL.md` step 8 的 `APPROVED` / `NEEDS-REVISION` 字樣改為對應 verdict

### D4: ITERATE 自動修復上限 2 輪

主 AI 收到 `[ITERATE]` 後修訂 artifacts 並重新送審；同一 change 最多 2 輪自動修復，第 3 次未通過即停止並向使用者呈現問題。

- 選此原因：沿用 Momus 上游設定（max 2 auto-fix rounds before escalating），防止審查者與主 AI 無限乒乓燒 token

### D5: 不新增 opsx command wrapper

`openspec-artifact-review` 是 `openspec-propose` 的內部步驟，不是使用者直接進入的 workflow 入口，依 `openspec-skill-command-parity` 的 4 核心 commands 原則不新增 wrapper。

### D6: re-invoke 必須從 disk 重讀

等價於 Momus 的 PLAN RE-READ RULE：每次 invoke（含 re-invoke）從 disk 讀取 artifacts 當前內容，防止審查者採信前次對話的舊版。

## Risks / Trade-offs

- [自訂審查 prompt 品質不若上游 Momus 持續打磨] → 準則主體直接移植 Momus 條文（含 anti-patterns），並以本 change 的 T\* 驗證流程可跑通；日後上游 Momus 改進可手動同步
- [spawn 一般 agent 無 read-only 工具強制隔離] → skill 明文禁止寫入，並以 T\*（審查後 artifacts 未變更）驗證；在 OmO 仍在時可用 read-only 類 agent 加強，但契約上不依賴
- [審查範圍含 delta spec 格式，比 Momus 原版更嚴] → 維持 blocker-only 紀律：格式檢查只認會讓 openspec CLI archive 失效的結構錯誤（如 `####` 層級錯誤），措辭風格不審
