# 先備知識：herdr keybinding 與基礎設定已熟

使用者自述已熟悉大部分 herdr 快捷鍵，且 config.toml 已建制完成（tab bar 底部化、`[[keys.command]]` type=shell 自訂綁定如 `alt+j/k` 翻頁經 `pane send-text` 送 escape sequence）。repo 中另有自製 tab 自動命名 shell integration（`herdr/shell.zsh`，ADR-0003），顯示對 `HERDR_TAB_ID` 環境變數與 `herdr tab` CLI 已有實務接觸。

**Evidence**: herdr/config.toml（`[[keys.command]]` shell commands、`ui.tab_bar_position`、theme gruvbox）、herdr/shell.zsh（preexec/precmd hooks + `herdr tab rename`）、使用者自述。

**Implications**: 跳過 keybinding 與基礎設定教學；ZPD 從 agent automation（`agent prompt/wait/start`）、worktree workspaces、socket API 開始。使用者已有「shell 指令驅動 herdr」的心智模型（send-text、tab rename），可直接推廣到 agent 層。
