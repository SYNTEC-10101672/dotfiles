## MODIFIED Requirements

### Requirement: ENV_SETUP.md 移除棄用的 SYNTEC MCP 內容
`docs/ENV_SETUP.md` SHALL NOT 包含 SYNTEC Confluence/JIRA MCP 的設定說明、`start-mcp-server.sh`、`check-mcp-connection.sh` 的參考，以及 resetcnc 相關說明（已遷移至 `~/personal/projects_dotfiles/`）。

#### Scenario: 閱讀 ENV_SETUP.md
- **WHEN** AI 閱讀 `docs/ENV_SETUP.md`
- **THEN** SHALL 不看到任何 SYNTEC_EMAIL、SYNTEC_API_TOKEN 的說明，也不看到 resetcnc 相關內容或 `~/dotfiles/scripts/resetcnc` 的路徑引用
