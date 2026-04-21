## Context

`scripts/resetcnc` 是一個 CNC 控制器重置腳本，透過 SSH + Tasmota 智能插座控制電源。此腳本已遷移至 `~/personal/projects_dotfiles/`（commit `246ee15`），dotfiles 中不再需要。

目前 resetcnc 出現在 4 個位置：`scripts/resetcnc`（檔案本身）、Makefile（3 處引用）、`docs/ENV_SETUP.md`（3 處說明）。

## Goals / Non-Goals

**Goals:**
- 從 dotfiles 中完全移除 resetcnc 及其所有引用
- 保持 Makefile 的 `scripts`、`uninstall`、`check` target 正常運作

**Non-Goals:**
- 不修改 `~/personal/projects_dotfiles/` 中的 resetcnc 實作
- 不影響其他 scripts 的安裝/卸載流程

## Decisions

- **直接刪除檔案與引用**，不保留 empty state 或 placeholder。理由：這是純移除，沒有 migration 路徑需求，新位置已在 projects_dotfiles 運作。
- **不新增 Makefile target**。理由：resetcnc 從未擁有獨立 target，只是 scripts 迴圈中的一員。

## Risks / Trade-offs

- [執行中的 symlink] → 使用者已安裝的 `~/bin/resetcnc` symlink 會變為 dangling，需執行 `make uninstall && make install` 清除。這是預期行為。
