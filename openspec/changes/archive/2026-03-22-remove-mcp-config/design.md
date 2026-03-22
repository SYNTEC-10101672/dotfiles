## 背景

Claude Code 支援兩種方式註冊 MCP server：(1) `.mcp.json` 設定檔，(2) 透過 `settings.json` 安裝的 plugin。目前 dotfiles 兩種方式並存。在啟用 atlassian、Notion、context7 plugin 後，`.mcp.json` 中的項目已成為冗餘。

## 目標 / 非目標

**目標：**
- 移除 `.claude/.mcp.json`，消除重複的 MCP server 註冊

**非目標：**
- 變更可用的 MCP server
- 修改任何 plugin 設定
- 其他 dotfiles 清理

## 設計決策

**直接刪除檔案，而非清空內容**
- 空的 `{"mcpServers": {}}` 沒有任何意義
- 檔案不存在是最清楚的語意——MCP server 由 plugin 管理
- Claude Code 在 `.mcp.json` 不存在時能正常運作

## 風險 / 取捨

- [風險] Plugin 提供的 MCP 功能可能與原本的自訂 server 有落差 → 緩解：在 explore 階段已確認三個 server 均有對應 plugin 覆蓋。若發現缺口，可將特定項目重新加回 `.mcp.json`
- [風險] 其他使用此 dotfiles 的機器可能仍依賴 `.mcp.json` → 緩解：Plugin 設定位於 `settings.json`，同樣由 dotfiles 管理，所有機器應啟用相同的 plugin
