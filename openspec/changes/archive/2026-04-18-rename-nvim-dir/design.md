## Context

dotfiles repo 目前各模組目錄命名不一致：`claude/`、`scripts/` 使用無前綴名稱，但 neovim 設定放在 `.nvim/`（隱藏目錄）。此改動對齊 `claude/` 目錄先前已完成的同類重新命名（`.claude/` → `claude/`）。

## Goals / Non-Goals

**Goals:**
- 將 `dotfiles/.nvim/` 重新命名為 `dotfiles/nvim/`
- 更新 Makefile 所有引用 `.nvim` 的字串
- 確保 `~/.config/nvim` symlink 正確指向新路徑

**Non-Goals:**
- 不修改 neovim 設定內容
- 不變更 symlink 目標路徑（仍為 `~/.config/nvim`）

## Decisions

**直接 `mv` 而非 `cp` + `rm`**：只是重新命名，無需複製內容。git 會追蹤為 rename（若相似度 > 50% 會自動偵測）。

**Symlink 更新方式**：`make nvim` 使用 `ln -sf`，可直接覆蓋舊 symlink，不需手動刪除。

## Risks / Trade-offs

- **短暫 broken symlink**：`mv` 完成後、`make nvim` 執行前，`~/.config/nvim` 會指向不存在的路徑。由於兩步驟都是本地操作，影響時間極短。
- **git rename detection**：若 `.nvim/` 內容有大量變動同時進行，git 可能無法偵測為 rename，改以 delete + add 呈現。此次只做純 rename，不影響。
