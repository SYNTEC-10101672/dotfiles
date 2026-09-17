# Proposal: add-commit-gate-plugin

## Why

ultrawork 模式（`/opsx:apply ulw`）的 COMMIT DISCIPLINE 指示模型「每個 verified increment 就 commit」，導致任務結束時 AI 已自發 commit — 但使用者的流程是人工一一確認後才經由 `/commit` 下 commit。permission config 的 `deny` 無法為 `/commit` 開例外，`ask` 會在 unattended 執行時卡住整個任務，因此需要一個有授權通道的 plugin 層擋截。

## What Changes

- 新增 plugin `opencode/plugins/commit-gate.ts`（Commit Gate）：
  - 以 `tool.execute.before` 攔截 bash tool，regex 偵測 `git commit` subcommand（涵蓋 `git -C <path> commit`、`&&`/`;` chain、env prefix 形狀）
  - 未授權 session 一律 `throw` 阻擋；錯誤訊息以英文明示「user forbade commits this session」，命中 ulw COMMIT DISCIPLINE 的 skip 條件，模型不重試、任務繼續
  - 不阻擋：git plumbing（`commit-tree`、`update-ref`）、`--continue` 家族（`merge`/`rebase`/`cherry-pick`）、script 內藏 commit（殘留風險，靠錯誤訊息聲明禁止繞路）
- 授權機制（authorized session）：
  - `command.execute.before` 偵測 `/commit` 執行 → 授權該 `sessionID`
  - 任何非 `/commit` 的 slash command 執行 → 清除該 session 授權
  - 無 TTL；`session.deleted` event 清理 state
  - subagent（獨立 `sessionID`）永不繼承授權，一律擋
- 新增測試 `opencode/test/commit-gate.test.ts`（bun test，repo-local、不部署）
- 更新 `README.md` 專案結構中 `plugins/` 的描述（加 commit-gate.ts）

## Capabilities

### New Capabilities

- `opencode-commit-gate`: AI `git commit` 的授權與阻擋 — 偵測範圍、authorized session 生命週期、subagent 不繼承、與 Secret Guard 的分層（授權後的 commit 仍過 gitleaks 掃描）

### Modified Capabilities

（無 — `opencode-secret-guard` 的 requirements 不變：Commit Gate 只決定「能不能執行」，Secret Guard 仍掃描所有實際執行的 commit）

## Impact

- 新檔：`opencode/plugins/commit-gate.ts`、`opencode/test/commit-gate.test.ts`
- 修改：`README.md`（plugins/ 描述一行）
- 部署後全域生效（`opencode/plugins/` 整目錄 symlink 至 `~/.config/opencode/plugins`，auto-discovery 載入）
- 不動：`opencode/opencode.json`（local plugins 不需註冊）、`opencode/plugins/guard.ts`、`opencode/commands/commit.md`、`git push` 行為（維持 `"ask"`）
