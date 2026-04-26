## Context

目前 dotfiles 的 `claude/` 目錄管理 Claude Code 的設定（`settings.json`、`CLAUDE.md`、`commands/`、`skills/`、`scripts/`）。opencode 的 `commands/` 目錄已透過 Makefile 的 `opencode` target symlink 到 `dotfiles/claude/commands`（共用），但 `opencode.json` 和 `package.json` 是 `~/.config/opencode/` 下的普通檔案，未受版本控制。

## Goals / Non-Goals

**Goals:**
- `opencode.json` 和 `package.json` 納入 dotfiles 版本控制
- 新機器執行 `make opencode` 即可還原完整 opencode 設定
- SETUP.md 明確說明 plugin 的安裝行為

**Non-Goals:**
- 不管理 `~/.cache/opencode/`（plugin 下載 cache，由 opencode 自動管理）
- 不管理 `~/.config/opencode/node_modules/`（npm 依賴，由 npm install 管理）
- 不變更 `commands/` 的共用 symlink 機制

## Decisions

### 決策：新增獨立 `opencode/` 目錄，而非放入 `claude/`

**選擇**：在 dotfiles repo 新增 `opencode/` 頂層目錄，存放 `opencode.json` 和 `package.json`。

**理由**：opencode 有自己的 `package.json`（npm 依賴），與 Claude 設定性質不同，混入 `claude/` 會造成 `npm install` 路徑混亂。獨立目錄語意清晰，且與 `nvim/`、`claude/` 的模式一致。

**替代方案排除**：將 `opencode.json` 放入 `claude/` 然後調整 symlink target path——可行但 `package.json` 與 claude 毫無關聯，強行放入會造成混淆。

### 決策：Makefile `opencode` target 同時管理檔案與目錄 symlink

`opencode` target 新增對 `opencode.json` 和 `package.json` 的 symlink 邏輯，與既有的 `commands/` symlink 並列。沿用現有的 `ln -sf` 模式，與其他 target（`claude`、`git`）保持一致。

### 決策：plugin 安裝不納入 Makefile，僅在 SETUP.md 說明

opencode plugin 在首次啟動時由 opencode 自動從 npm 下載到 `~/.cache/opencode/`，不需要 `make opencode` 執行任何 npm 指令。SETUP.md 補充說明此行為即可。

## Risks / Trade-offs

- **`package.json` symlink 限制** → `npm install` 在 symlink 指向的目錄下執行時，`node_modules` 會安裝到 dotfiles repo 的 `opencode/` 目錄（而非 `~/.config/opencode/`）。但 `package.json` 的唯一依賴 `@opencode-ai/plugin` 是 plugin 開發用 SDK，一般使用不需要手動 `npm install`，故此風險接受。

## Migration Plan

1. 建立 `opencode/opencode.json`（從 `~/.config/opencode/opencode.json` 複製）
2. 建立 `opencode/package.json`（從 `~/.config/opencode/package.json` 複製）
3. 更新 Makefile `opencode`、`check`、`uninstall` target
4. 更新 `docs/SETUP.md`
5. 執行 `make opencode` 驗證 symlink 建立正確
6. 執行 `make check` 確認狀態顯示正確

現有 `~/.config/opencode/opencode.json` 和 `package.json` 在 `make opencode` 執行後會被 symlink 覆蓋（`ln -sf` 行為），原始檔案內容已保存於 dotfiles，無資料遺失風險。

## Open Questions

無。
