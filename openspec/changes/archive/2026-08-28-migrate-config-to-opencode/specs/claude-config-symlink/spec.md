# Delta Spec: claude-config-symlink

## REMOVED Requirements

### Requirement: 混合 symlink 部署 ~/.claude

**Reason**: claude CLI 退役，`make claude` target 與 `~/.claude/` config symlinks 不再部署；`~/.claude/` 僅保留 runtime（credentials/history/transcripts），不屬於 dotfiles 部署範圍。

**Migration**: AI 工具設定的 symlink 部署職責由 `opencode` target 擴充承接（見 `opencode-config-files` delta：新增 `commands`、`skills` 目錄 symlink 與 `AGENTS.md` 單檔 symlink）。

### Requirement: Makefile claude target 使用混合 symlink

**Reason**: `claude` target 隨 claude CLI 退役刪除。

**Migration**: 無承接（target 本身刪除）；`make opencode` 成為 AI 工具設定的唯一部署 target。

### Requirement: 移除 backup/restore/clean 功能

**Reason**: 此 requirement 的原始訴求（Makefile 不提供 backup/restore/clean target）仍然成立，但其宿主 capability（claude 設定 symlink）消失。

**Migration**: 遷往 `dotfiles-install` capability（該 spec 管 Makefile install/uninstall/check 行為），內容不變。

### Requirement: 全域 CLAUDE.md 包含 OpenSpec TDD 規範

**Reason**: 宿主 capability 消失；指示檔本身改名搬遷（`claude/CLAUDE.md` → `opencode/AGENTS.md`）。

**Migration**: 遷往 `self-contained-tasks` capability（該 spec 已有同型「全域指示檔 MUST 記錄 OpenSpec 規範」requirement），路徑改為 `opencode/AGENTS.md`，規範內容不變。

### Requirement: 簡化 .gitignore

**Reason**: 純歷史遺跡 — requirement 描述的 `claude/commands/opsx/`、`claude/skills/openspec-*/` 排除規則已不存在於 `.gitignore`；`.claude/*` allowlist 模式隨 `.claude/` 目錄消失一併移除。

**Migration**: 無承接（`.gitignore` 的 `# Claude Code` 區塊直接刪除）。

### Requirement: explore mode 寫檔白名單

**Reason**: 宿主 capability 消失；規範對象（`openspec-explore/SKILL.md`）隨 `claude/skills/` 搬遷至 `opencode/skills/`。

**Migration**: 遷往 `skill-authoring-governance` capability（skill 檔內容治理主題），路徑改為 `opencode/skills/openspec-explore/SKILL.md`，白名單內容不變。

### Requirement: CONTEXT.md 寫入須走 domain-modeling 程序

**Reason**: 宿主 capability 消失；規範對象（explore/propose skills）搬遷至 `opencode/skills/`。

**Migration**: 遷往 `skill-authoring-governance` capability，路徑改為 `opencode/skills/openspec-explore/SKILL.md` 與 `opencode/skills/openspec-propose/SKILL.md`，程序要求不變。
