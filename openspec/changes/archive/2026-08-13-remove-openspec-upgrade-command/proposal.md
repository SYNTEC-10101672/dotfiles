## Why

OpenSpec 上游 skills/commands 近乎不再更新，`/opsx:upgrade` command 已無實際使用價值。command 定義檔 (`claude/commands/opsx/upgrade.md`) 已先行刪除，但對應的 capability spec `openspec-upgrade-command` 仍殘留，記錄一個已不存在的功能。需正式移除以保持 spec 與實作一致。

## What Changes

- **BREAKING**: 移除 `openspec-upgrade-command` capability 的全部 requirements（3 個 requirements、8 個 scenarios）
- 移除 `openspec/specs/openspec-upgrade-command/spec.md`（capability 目錄整支刪除）
- command 定義檔 `claude/commands/opsx/upgrade.md` 已於本 change 建立前手動刪除（deletion 存於當前 diff，與本 change 的 spec removal 一併提交）

## Capabilities

### New Capabilities

（無）

### Modified Capabilities

- `openspec-upgrade-command`: 移除全部 3 個 requirements — `/opsx:upgrade` command 升級流程、自有客製化檔案排除、diff 摘要顯示。移除後此 capability 將不再存在。

## Impact

- **Specs**: `openspec/specs/openspec-upgrade-command/spec.md` 整支刪除
- **Commands**: `claude/commands/opsx/upgrade.md` 已刪除（手動刪除，與本 change 一併提交）
- **相依性**: 無其他 spec 引用此 capability；`openspec/project.md` 無相關記載
