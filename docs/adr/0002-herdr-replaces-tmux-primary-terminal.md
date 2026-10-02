---
status: accepted
---

# herdr 取代 tmux 為主力終端，agent 通知管線不移轉

herdr 0.9.3 具備 tmux 級的 multiplexing（prefix mode、copy mode、split/pane 管理）加上 native agent observation——server log 已證實它偵測 `process=opencode` 並追蹤 working/idle/blocked 狀態，sidebar rollup、toast、sound 通知皆內建。決定：herdr 為主力終端；tmux 設定與 `@claude_state` 通知管線（`opencode/plugins/notify.ts` + `notify-stop.sh` / `notify-waiting.sh` + tmux status bar 整合）原樣保留為 fallback，不改寫成 herdr 版——herdr 原生觀測已覆蓋其功能，且 scripts 在非 tmux 環境本來就靜默 skip，零衝突。

## Considered Options

- 移植 notify scripts 到 herdr（`herdr pane send-keys` / socket API）：拒絕——重造 herdr 已內建的功能，且雙通知來源會重複打擾。
- tmux / herdr 並存為雙主力、設定同步維護：拒絕——維護負擔加倍，keybinding 衝突無解（hjkl 兩邊語意不同）。

## Consequences

- tmux 模組與其通知 scripts 凍結為 fallback：壞了修、不主動演進。
- agent 狀態顯示改依賴 herdr 的 detection manifests（含 remote manifest 自動更新）；opencode 偵測失效時的 fallback 行為是顯示為 plain terminal，不會誤報。
- keybinding 策略：採納 herdr 原生（hjkl = pane focus、n/p/1..9 = tab、w/g = workspace picker），不復刻 tmux 肌肉記憶；僅 `alt+j/k` 翻頁透過 `[[keys.command]]` + `herdr pane send-text` 送 escape sequence 自建（herdr 無原生 key-translation binding，且 `pane send-keys` 在 0.9.3 無 page key 名稱）。
- 若日後退回 tmux，通知管線仍在，可直接回退。
