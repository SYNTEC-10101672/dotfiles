## Why

目前 `openspec-propose` 產出的 tasks.md 經常殘留代名詞（「測試控制器」「那個服務」「現有設定」），而 `openspec-apply` 預設會交給 fresh AI session 執行（無 session context）。代名詞導致 fresh AI 必須回頭澄清或自行查 codebase，破壞「規劃/實作分離」的 workflow。同時 `openspec-apply` 完成實作後只跑 T* 驗證，缺少 Standards（程式碼風格 + Fowler smells）與 Spec（是否符合 OpenSpec artifacts）雙軸的 code review，refactor 後也沒有重新跑測試確認沒退化。

根本原因之一是 `openspec-propose/SKILL.md:108` 明確寫著「prefer making reasonable decisions to keep momentum」，直接告訴 AI「自己腦補別打擾」，是代名詞滿天飛的元兇。借鏡 Matt Pocock `grilling` skill 的「fact vs decision」規則（能在環境查到的事實必查、需要人決定的才問），可以把這個反規則替換成正向紀律。

## What Changes

- **刪除反規則**: 移除 `openspec-propose/SKILL.md:108` 的「prefer making reasonable decisions to keep momentum」
- **新增 fact-vs-decision 紀律**: 在 propose 的 Guardrails 加入「fact 必查、decision 才問」的規則（借鏡 Matt grilling）
- **新增 Step 5 Fact Lookup**: 對寫完的 artifact（特別是 tasks.md）逐條掃描代名詞，查 codebase 取具體值 inline 替換
- **新增 Step 6 Self-Containment Gate**: 模擬 fresh AI 視角對每個 task 檢查「檔案可定位 / 變更具體 / 完成條件可檢查」
- **新增 skill `openspec-code-review`**: 雙軸平行 sub-agents（Standards: CLAUDE.md 程式碼規範 + Fowler 12 smells baseline / Spec: vs OpenSpec change artifacts），借鏡 Matt `code-review`
- **修改 `openspec-apply-change/SKILL.md`**: 在 Step 6（TDD 三階段）之後新增 Step 7（Code Review + Fix Loop），完成後重跑 Final phase tests 確認沒退化
- **更新 `~/.claude/CLAUDE.md` 的 OpenSpec 規範段**: 加 3 條規範（禁代名詞、design.md Context 段、apply 完必跑 code-review）

## Capabilities

### New Capabilities

- `self-contained-tasks`: 規範 propose 階段產出的 tasks.md 必須 self-contained（無代名詞、含具體檔案路徑與 API），讓 fresh AI session 可獨立執行。涵蓋 fact-vs-decision 紀律、Fact Lookup 階段、Self-Containment Gate。
- `openspec-code-review`: 雙軸平行 sub-agents 的 code review 能力。Standards 軸檢查 repo 程式碼規範 + Fowler smells baseline；Spec 軸檢查是否符合 originating OpenSpec change artifacts。被 `openspec-apply` 完成實作後自動觸發。

### Modified Capabilities

（無。本次改造均為新增能力，不改變既有 spec 行為。`openspec-tdd-task-format` 的 T* 雙欄位格式維持不變。）

## Impact

**修改檔案**:
- `~/.claude/skills/openspec-propose/SKILL.md`（刪 1 條 guardrail / 改 Step 4c / 新增 Step 5 + Step 6，原 Step 5 改編號為 Step 7）
- `~/.claude/skills/openspec-apply-change/SKILL.md`（新增 Step 7，原 Step 7 改編號為 Step 8）
- `~/.claude/CLAUDE.md`（在「OpenSpec 規範」段加 3 條規範）

**新增檔案**:
- `~/.claude/skills/openspec-code-review/SKILL.md`（全新 skill）

**受影響 workflow**:
- `opsx:propose` 變慢約 30-50%（多了 Fact Lookup + Gate 步驟），但產出 tasks.md 自足性大幅提升
- `opsx:apply` 完成後多一次 code review sub-agent 平行呼叫（token 微增），但能抓出 Standards / Spec 問題
- fresh AI session 在 apply 時卡住率預期從「高」降到「接近 0」

**相依技能**:
- `openspec-tdd-verify` 不動（Final phase 重跑會用到它，但介面不變）
- `openspec-verify-change` 不動（仍是手動 review 整個 change 一致性的入口，與新 code-review skill 職責不同：verify-change 是「一致性」，新 code-review 是「Standards + Spec 雙軸」）
