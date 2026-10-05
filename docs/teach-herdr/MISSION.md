# Mission: herdr 工作流全面遷移與 agent 協作

## Why
把日常終端工作流從 tmux 完全搬到 herdr（已完成基本遷移），下一步是善用其 agent-native 能力：讓多個 AI coding agents（opencode 為主）在 herdr 裡互相派工、等待、回報，並用 git worktree 平行開發。終點是「agents 在 herdr 裡自主協作，人看 sidebar 狀態做決策」。

## Success looks like
- 能用 `herdr agent prompt/wait/start/read` 完成一個 agent 指揮另一個 agent 的完整 loop（split → start → prompt --wait → read）
- 能解釋五個 agent 狀態（idle/working/blocked/done/unknown）與 `--wait` 的語意（blocked 拒收、5s stall gate）
- 能用 `herdr worktree create/open/remove` 為平行任務開獨立 worktree workspace
- 能說出 workspace / tab / pane / agent 四層結構與 socket API、`HERDR_*` 環境變數的關係
- 日常不再開 tmux（僅 fallback）

## Constraints
- 已熟悉 herdr 大部分快捷鍵；config.toml 已建制（`[[keys.command]]` shell 綁定、tab 自動命名 hooks）
- 本機 herdr 0.9.3（Linux）；docs 對齊此版本
- 教學文件維護在 dotfiles repo 的 `docs/teach-herdr/`
- 教學語言：繁體中文，技術術語保持英文

## Out of scope
- tmux 設定演進（已凍結為 fallback，見 ADR-0002）
- herdr plugin 開發（社群 plugins 生態先當使用者，不寫 plugin）
- remote machines / SSH forwarding / Herdr Cloud（未來可擴展）
