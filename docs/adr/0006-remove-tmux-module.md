---
status: partially superseded by 0009-remove-tmux-package.md (SSH bare tmux fallback clause)
---

# tmux 模組退役，回退路徑改為 git history（supersede ADR-0002）

ADR-0002 將 tmux 凍結為 fallback（壞了修、不演進，repo 內原樣保留）。herdr 上線後 fallback 從未被回用，凍結的實際成本是永久的：文件段落、Makefile 模組清單、讀者的認知負擔，以及 tmux 時代遺物的持續堆積——同批清理的 notify 管線（`opencode/plugins/notify.ts` 呼叫的 `@claude_state` + BEL scripts）正是凍結策略養出來的殘骸。決定：tmux 模組完整退役——`.tmux.conf`、`.aliases` 的 `tmux-attach`、Makefile target 與 install/uninstall/check 清單、README/SETUP.md 文件段落全數移除，herdr 成為唯一受組態的終端；回退路徑從「repo 內保留」改為 git history。本 ADR supersede ADR-0002 的凍結決策，並同時記載 notify 管線的移除（該管線先於本 ADR 落地）。

## Considered Options

- 維持 ADR-0002 的凍結 fallback：拒絕——fallback 從未被回用，凍結仍需在文件與 Makefile 永久佔位，且遺物（notify 管線）會以「fallback 還在」為由繼續留存。
- 保留 `.tmux.conf` 在 repo 但退出 deploy 清單：拒絕——無 deploy 鏈結的孤兒設定檔相對 git history 零額外價值，徒增 grep 噪音。

## Consequences

- `make install` / `make uninstall` / `make check` 與模組清單不再有 tmux；live 端 `~/.tmux.conf` symlink 移除。
- SSH 應急情境只剩 bare tmux（系統套件、預設設定）；需要 repo 設定時從 git history 找回。
- nvim clipboard 的 `$TMUX` 環境偵測保留：那是 runtime 偵測（bare tmux 內也生效），不屬於 tmux 模組。
- GLOSSARY「主力終端」詞條更新：fallback 描述移除；ADR-0002 標記 superseded。
