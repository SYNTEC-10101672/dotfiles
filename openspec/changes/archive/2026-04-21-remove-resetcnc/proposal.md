## Why

`scripts/resetcnc`（CNC 控制器重置腳本）已遷移至 `~/personal/projects_dotfiles/`（commit `246ee15`），dotfiles 中不再需要保留此腳本及其相關引用。

## What Changes

- 刪除 `scripts/resetcnc` 檔案
- 從 Makefile 的 `scripts`、`uninstall`、`check` 三個 target 中移除 `resetcnc` 引用
- 從 `docs/ENV_SETUP.md` 中移除 resetcnc 相關說明

## Capabilities

### New Capabilities

（無新增 capability）

### Modified Capabilities

- `setup-guide`: ENV_SETUP.md 中移除 resetcnc 相關文件說明

## Impact

- `scripts/resetcnc` — 刪除
- `Makefile` — 移除 3 處引用
- `docs/ENV_SETUP.md` — 移除 3 處說明
- `~/bin/resetcnc` symlink — 執行 `make uninstall && make install` 後自動清除
