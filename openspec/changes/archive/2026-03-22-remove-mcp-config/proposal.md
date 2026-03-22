## 為什麼

`.claude/.mcp.json` 手動註冊了三個 MCP server（notion、context7、syntec-cf-server），這些 server 已全數被 `settings.json` 中啟用的 Claude Code plugin 所涵蓋。維護一個獨立的 MCP 設定檔造成重複註冊，增加不必要的維護負擔。

## 變更內容

- 從 dotfiles 中刪除 `.claude/.mcp.json`

## Capabilities

### 新增 Capabilities

（無）

### 修改 Capabilities

（無——此為純粹清理，不改變任何功能；plugin 提供相同的 MCP server）

## 影響範圍

- `.claude/.mcp.json` 被移除
- 原本透過此檔案註冊的 MCP server，改由 Claude Code plugin 統一管理：
  - `notion` → `Notion@claude-plugins-official`
  - `context7` → `context7@claude-plugins-official`
  - `syntec-cf-server` → `atlassian@claude-plugins-official`
- Claude Code 的功能行為不受影響
