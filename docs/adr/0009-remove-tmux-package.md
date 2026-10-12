---
status: accepted
---

# tmux 系統套件移除，SSH 應急 fallback 退役（supersede ADR-0006 條款）

ADR-0006 退役 tmux 模組時保留系統套件作為 SSH 應急的 bare tmux（預設設定、零 repo 組態）。此後應急情境從未發生：herdr 上線後 bare tmux 一次都沒開過，`/usr/bin/tmux` 只剩「本機還有 tmux」的認知殘留。決定：`sudo apt purge tmux`，本機完全沒有 tmux——herdr 是唯一終端；遠端 SSH 情境用遠端機器自己的工具，真的需要本機 tmux 時 `apt install` 即回（bare、無 repo 設定）。本 ADR 僅 supersede ADR-0006 的「SSH 應急情境只剩 bare tmux」條款；模組退役與 git history 回退路徑的決策不變。

## Considered Options

- 維持 ADR-0006 現狀（bare tmux 留作應急）：拒絕——應急從未發生，套件存在讓「tmux 還在」的印象延續，與模組退役的認知清理不一致。
- 連 nvim clipboard 的 `$TMUX` 偵測一併移除：拒絕——那是 runtime 偵測（在遠端機器的 tmux 內也生效），與本機套件無關，ADR-0006 的保留理由不變。

## Consequences

- 本機 `command -v tmux` 無輸出；無殘留設定檔或 socket。
- SSH 應急改用遠端機器自身的 terminal 工具；回頭路 = `sudo apt install tmux`（bare）。
- MISSION.md 與 GLOSSARY「主力終端」詞條同步更新；ADR-0006 標記 partial superseded。
