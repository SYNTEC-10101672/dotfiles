## Context

`claude/commands/syntec/review-doc.md` 是透過 `make claude` 部署至 `~/.claude/commands/syntec/review-doc.md` 的 symlink。該 command 同時作為 `/syntec:review-doc` slash command 與 `syntec:review-doc` skill 運作。功能本體已移至 `~/personal/projects_dotfiles/shared/commands/syntec/review-doc.md`，由該專案的 Makefile 負責部署。

## Goals / Non-Goals

**Goals:**
- 從 dotfiles repo 移除 review-doc command 的定義與相關 spec
- 確保 `~/.claude/commands/syntec/` 下的 symlink 不會留下懸空指標

**Non-Goals:**
- 修改 `~/personal/projects_dotfiles` 的內容（已完成）
- 調整 Makefile 的 `claude` target（`syntec/` 目錄整個消失，symlink 自然不會產生）

## Decisions

**直接刪除檔案與目錄，不做相容性保留**

`claude/commands/syntec/` 目錄移除後，`make claude` 不會再建立對應 symlink，行為乾淨。無需保留空目錄或佔位檔案。

## Risks / Trade-offs

- `~/.claude/commands/syntec/review-doc.md` 若為已存在的 symlink，指向的來源消失後會變成 dangling symlink → 執行 `make uninstall && make install` 或手動 `rm` 即可清除
