# herdr Resources

## Knowledge

### 本地權威（版本綁定 0.9.3，優先於網路文件）

- `herdr --skill` 的逐字輸出：[reference/herdr-skill-0.9.3.md](reference/herdr-skill-0.9.3.md)
  內建 agent skill file——TARGET 語法、五狀態語意、canonical 協作 pattern、安全規則。herdr 升級後重新產出。Use for: 任何 CLI 語法與行為疑問的第一手依據。
- `herdr <group>` 不帶 subcommand 直接跑（如 `herdr agent`、`herdr worktree`）會印出該 group 的完整命令清單。Use for: 快速查安裝版本的命令面。
- 本 repo：`herdr/config.toml`、`herdr/shell.zsh`、[ADR-0002](../../adr/0002-herdr-replaces-tmux-primary-terminal.md)（herdr 取代 tmux、native agent observation）、ADR-0003（tab 自動命名）
- 官方提供 [llms.txt](https://herdr.dev/llms.txt) 與 [llms-full.txt](https://herdr.dev/llms-full.txt)（給 agent 的全文件 dump）。Use for: 讓 agent 快速拿到全域文件。

### 官方文件（herdr.dev，docs 版本 = 0.9.3）

- [CLI reference](https://herdr.dev/docs/cli-reference/) — 全命令面（workspace/worktree/tab/pane/agent/server/session/machine）。Use for: 查任何指令語法（含 [#worktrees](https://herdr.dev/docs/cli-reference/#worktrees)）。
- [Agent automation](https://herdr.dev/docs/agent-automation/) — agents 用 CLI/socket API 互相驅動：split、start each other、prompt each other、wait for genuine blocked。Use for: agent 間溝通（mission 核心）。
- [Socket API](https://herdr.dev/docs/socket-api/) — newline-delimited JSON over Unix socket（`~/.config/herdr/herdr.sock`）、raw methods（`agent.*`、worktree methods）、server-owned wait。Use for: `agent.prompt` 帶 wait object 的 race-free 用法、自製 client。
- [Agents](https://herdr.dev/docs/agents/) — 偵測機制（foreground process + bottom buffer + detection manifest）、狀態 rollup、[blocked 嚴格判定](https://herdr.dev/docs/agents/#blocked-state)、[manifests 更新](https://herdr.dev/docs/agents/#detection-manifests)（local override：`~/.config/herdr/agent-detection/<agent>.toml`）。
- [Concepts](https://herdr.dev/docs/concepts/) — client/server 模型、workspace/tab/pane/agent 四層、狀態定義。Use for: 心智模型校準。
- [Configuration](https://herdr.dev/docs/configuration/) — `[worktrees] directory`、custom command 環境變數（`HERDR_ACTIVE_*`）、`[session] resume_agents_on_restore`。Use for: 設定層問題。
- [Session state](https://herdr.dev/docs/session-state/) — detach/restart/handoff 各自保留什麼、[native agent session restore](https://herdr.dev/docs/session-state/#native-agent-session-restore)（opencode：`opencode --session <id>`）。Use for: 永續 session 心智模型。
- [Add Herdr support to your agent](https://herdr.dev/docs/add-herdr-support/) — `pane report-agent` 自行回報狀態與 resume command。Use for: 讓自製工具被 herdr 觀測。
- [Integrations](https://herdr.dev/docs/integrations/) — 各 agent CLI 整合細節。

### 原始碼與更新

- [github.com/herdrdev/herdr](https://github.com/herdrdev/herdr) — Apache 2.0 原始碼（Rust），docs 在 repo 內（版本化路徑 `docs/versions/0.9.3/website/…`，每頁有 Edit link）。Use for: 讀原始實作、PR/issue。
- [CHANGELOG.md](https://github.com/herdrdev/herdr/blob/v0.9.3/CHANGELOG.md) · [Releases](https://github.com/herdrdev/herdr/releases)（0.9.3 = 2026-09-29 hotfix；feature notes 主要在 0.9.2）。Use for: 升級前看改動。
- Blog（與 mission 最相關）：[Connecting the machines](https://herdr.dev/blog/connecting-the-machines/)（remote machines）、[Coding agents are becoming runtimes](https://herdr.dev/blog/coding-agents-are-becoming-runtimes/)（設計哲學）、[Live updates without killing your terminal processes](https://herdr.dev/blog/live-updates-without-killing-your-terminal-processes/)（handoff）、[Ten agents, three clients, 95% less CPU](https://herdr.dev/blog/ten-agents-three-clients-95-percent-less-cpu/)（multi-agent 效能）。

## Wisdom (Communities)

- [Herdr Discord](https://discord.gg/PsgRfzmUDg) — 官方社群。Use for: worktree/workflow pattern 實戰討論、功能疑問。
- [X/Twitter @herdrdev](https://x.com/herdrdev) — 官方公告。Use for: 版本動態。
- [GitHub issues](https://github.com/herdrdev/herdr/issues) — Use for: bug 回報與 workaround 搜尋。

## Gaps

- （已解）worktree 文件：存在於 [CLI reference — Worktrees](https://herdr.dev/docs/cli-reference/#worktrees) 與 [Configuration — Worktrees](https://herdr.dev/docs/configuration/#worktrees)，非獨立頁。
- socket API 的 `agent.prompt` 完整 JSON payload 官方頁未附範例（method 名稱與 wait object 語意已確認）——需要時讀 repo 原始碼或問 Discord。
- 中文資源：幾乎不存在，以官方英文文件為準。
