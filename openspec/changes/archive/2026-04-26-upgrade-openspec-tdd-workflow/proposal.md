## Why

目前 OpenSpec TDD 流程將 `> 驗證：` 區塊內嵌於每個實作 task，缺乏「先思考測試再實作」的結構，驗收條件分散且無獨立追蹤機制。同時 openspec skills 停留在 1.3.0，上游已釋出 1.3.1。

## What Changes

- **tasks.md 格式重構**：拆分為 `## 測試` 區塊（T* 項目，含 `> 指令：` 與 `> 預期：`）和 `## 實作` 區塊，實作項目標注對應的 T* 編號
- **opsx:apply TDD 流程**：新增 Red→Green→Final 三階段；apply 開始時評估是否需補充單元測試（掃描 codebase 後決定）
- **openspec-tdd-verify 升級**：改為讀取 T* 項目格式；AI 先自評能否驗證，無法立即確定時與使用者討論，而非直接標注「無法自動驗證」
- **上游 skills 升級**：將 11 個上游 skills 從 1.3.0 升至 1.3.1（diff 確認為版本號與 contextFiles 描述細節調整）
- **新增 `/opsx:upgrade` command**：自動化上游 skills 升級流程，比對版本後複製新檔，跳過自有客製化檔案

## Capabilities

### New Capabilities

- `openspec-tdd-task-format`：tasks.md 新格式規範——測試與實作分離，T* 項目含結構化的指令與預期輸出欄位，實作項目標注對應測試
- `openspec-upgrade-command`：`/opsx:upgrade` slash command，自動升級上游 skills/commands 至最新版，保留自有客製化檔案

### Modified Capabilities

- `openspec-tdd-verify`：增強驗證邏輯，改為讀取 T* 項目而非 `> 驗證：` blockquote；新增 AI 自評驗證可行性的流程，必要時與使用者討論驗證方式

## Impact

- `claude/CLAUDE.md`：OpenSpec 規範段落改為新格式說明
- `claude/skills/openspec-apply-change/SKILL.md`：加入 TDD 三階段流程與單元測試評估步驟
- `claude/commands/opsx/apply.md`：同上
- `claude/skills/openspec-tdd-verify/SKILL.md`：完整改寫驗證邏輯
- `claude/commands/opsx/tdd-verify.md`：description 同步更新
- `claude/skills/openspec-continue-change/SKILL.md`：tasks.md 說明更新為新格式
- `claude/commands/opsx/upgrade.md`：新增 `/opsx:upgrade` command
- 上游 11 個 skills 及對應 commands：版本升至 1.3.1
