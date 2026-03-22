## REMOVED Requirements

### Requirement: 透過 .mcp.json 註冊 MCP server
**原因**：所有 MCP server（notion、context7、syntec-cf-server/atlassian）已改由 `settings.json` 中的 Claude Code plugin 負責註冊，`.mcp.json` 已成冗餘。
**遷移說明**：無需任何操作。`settings.json` 中的 plugin 會自動提供相同的 server。

#### Scenario: 刪除檔案後 MCP server 仍可正常使用
- **WHEN** 刪除 `.claude/.mcp.json`
- **THEN** notion、context7、atlassian MCP server 仍可透過 plugin 正常存取
