---
status: accepted
---

# Domain document 命名跟隨 upstream 改為 GLOSSARY

mattpocock/skills v1.3.0 把 domain document 慣例從 `CONTEXT.md`/`CONTEXT-MAP.md` 全面改名為 `GLOSSARY.md`/`GLOSSARY-MAP.md`（所有讀寫它的 skills：`domain-modeling`、`tdd`、`diagnosing-bugs`、`improve-codebase-architecture`、`setup-matt-pocock-skills` 等，含 docs pages 與 upstream repo 自身的 root glossary），並明言 skills 後續只認新名、既有檔案以 `git mv` 遷移。檔案本質就是 glossary（`domain-modeling` 內文本來就定義「It is a glossary and nothing else」），upstream 以此正名。決定：跟隨 upstream——本 repo 與五個使用同批 skills 的工作 repo（appkernel、appkernel_V12、appkernel_GTK、CNCReboot、VibeWrite）同步改名，vendored 檔案內文隨 v1.3.1 sync 帶入新名。

## Considered Options

- 保留 `CONTEXT.md` 舊名、每次 upstream sync 把新名 patch 回舊名：拒絕——每次升級多一層永久的手工 diff patch 負擔，且 patch 遺漏的失敗模式是靜默的：skill 找不到檔案就直接跳過 domain vocabulary，不報錯，壞了不會被發現。
- 只改 vendored 檔案內文、各 repo 的 `CONTEXT.md` 檔案暫緩：拒絕——改名後的 skills 讀不到舊名檔案，同樣落入靜默跳過；rename 必須一次跨「vendored 內文 + 各 repo 檔案 + 消費端規則文件」同步完成才有意義。

## Consequences

- 六個 repo 各自把 `CONTEXT.md` 改名為 `GLOSSARY.md`，殘留的舊名引用（AGENTS.md、docs、`.install` manifest 等）一併修正。appkernel_V12 與 appkernel_GTK 是 appkernel 的 linked worktrees（`.git` file 形態，皆受 git 管轄、各有 index）；CNCReboot（空歷史 git repo）與 GTK branch 上的 glossary 檔原為 untracked，改名後維持 untracked、無 staged rename 可言。其餘 rename 均以 staged 變更呈現、不 commit。
- 全域 `opencode/AGENTS.md` 的領域知識規則與 `docs/agents/domain.md` 的 domain doc 佈局改用新名；語意不變（檔案不存在時靜默繼續）。
- `domain-modeling` 的參考檔 `CONTEXT-FORMAT.md` 隨 upstream 改名為 `GLOSSARY-FORMAT.md`；消費該檔的自製 commands（opsx 系列）引用同步更新。
- vendored 檔案與 upstream 的差異自此僅剩記錄於 `opencode/VENDORED.md` 的包裝客製，後續升級以 diff 對 upstream 進行。
