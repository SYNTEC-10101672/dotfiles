## MODIFIED Requirements

### Requirement: 混合 symlink 部署 ~/.claude
系統 SHALL 使用混合 symlink 策略部署 `~/.claude/`：單檔 config 用單檔 symlink，目錄型 config 用目錄 symlink，runtime 目錄不 symlink（由 Claude Code 在本機建立）。

以下項目 SHALL 被 symlink：
- **單檔**：`settings.json`、`CLAUDE.md`
- **目錄**：`commands/`、`skills/`、`scripts/`

其他所有目錄（plugins, debug, sessions, projects, session-env, telemetry, cache, paste-cache, backups, logs, shell-snapshots, todos, tasks, plans, file-history, ide）SHALL NOT 被 symlink。

所有 symlink SHALL 使用 `$(ROOT_DIR)/claude/` 作為來源路徑（而非 `$(ROOT_DIR)/.claude/`），不寫死路徑。

#### Scenario: 全新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 不存在
- **THEN** 系統建立 `~/.claude/` 目錄，並建立 config 檔案和目錄的 symlink，來源指向 `$(ROOT_DIR)/claude/`

#### Scenario: 在已有環境上重新安裝
- **WHEN** 執行 `make claude` 且 `~/.claude` 已存在且含 symlink
- **THEN** 系統更新 symlink，不移除已有的 runtime 目錄

#### Scenario: 在 container 中部署
- **WHEN** dotfiles repo 被 volume mount 到 container 內任意路徑（例如 `~/shared_zone/dotfiles/`），並從該路徑執行 `make install`
- **THEN** 系統透過 `ROOT_DIR` 自動解析正確的 repo 路徑，建立正確的 symlink

### Requirement: Makefile claude target 使用混合 symlink
Makefile 的 `claude` target SHALL 建立 `~/.claude/` 為真實目錄，然後為 config 檔案建立單檔 symlink，為 config 目錄建立目錄 symlink。symlink 來源 SHALL 使用 `$(ROOT_DIR)/claude/` 而非寫死路徑。

#### Scenario: make claude 冪等性
- **WHEN** `make claude` 被執行多次
- **THEN** symlink 被正確建立或更新，不產生錯誤

### Requirement: 移除 backup/restore/clean 功能
Makefile SHALL 移除 `backup`、`restore`、`clean` 三個 target。`install` target SHALL 直接執行各模組安裝，不再依賴 backup。`uninstall` target SHALL 移除 backup 相關的提示文字。

#### Scenario: make install 不再自動備份
- **WHEN** 執行 `make install`
- **THEN** 系統直接安裝各模組，不建立備份目錄

#### Scenario: make help 不再顯示 backup 相關指令
- **WHEN** 執行 `make help`
- **THEN** 輸出中不包含 backup、restore、clean 指令

### Requirement: 全域 CLAUDE.md 包含 OpenSpec TDD 規範
全域 `claude/CLAUDE.md` SHALL 包含 OpenSpec 規範段落，規定：
1. tasks.md 每個 task 必須有 `> 驗證：` 區塊
2. 實作完每個 task 後，必須使用 `openspec-tdd-verify` skill 執行驗證，通過才 mark `[x]`

#### Scenario: Claude 產生 tasks.md
- **WHEN** Claude 為 OpenSpec change 產生 tasks.md
- **THEN** 每個 task 包含 `> 驗證：` 區塊

#### Scenario: Claude 完成 task 實作
- **WHEN** Claude 透過 opsx:apply 完成一個 task 的實作
- **THEN** Claude 呼叫 `openspec-tdd-verify` skill 執行驗證，通過後才 mark `[x]`

### Requirement: 簡化 .gitignore
根目錄的 `.gitignore` SHALL 將 `claude/commands/opsx/` 和 `claude/skills/openspec-*/` 排除規則的來源路徑從 `.claude/` 更新為 `claude/`。SHALL 新增 `.claude/*` 排除規則和 `!.claude/CLAUDE.md` allowlist 規則。

#### Scenario: 迁移後 repo 內不含 runtime 目錄
- **WHEN** Claude Code 相關設定以混合 symlink 方式從 `claude/` 部署
- **THEN** `claude/` 路徑下的 runtime 排除規則對應到正確的來源目錄

### Requirement: explore mode 寫檔白名單

`claude/skills/openspec-explore/SKILL.md` SHALL 以白名單制規範 explore mode 的檔案寫入：僅允許寫入 OpenSpec artifacts（`openspec/changes/**`）與經 domain-modeling 程序 resolved 的 `CONTEXT.md`。Skill 檔案 SHALL NOT 含有「"capturing thinking" 類比的模糊例外」或「未經程序即寫入 `CONTEXT.md`（如 right away）」的指示；此類指示與 "Don't auto-capture" guardrail 的矛盾 SHALL 被消除。

#### Scenario: 白名單文字存在

- **WHEN** 檢視 `claude/skills/openspec-explore/SKILL.md` 的寫檔規範段落（開頭 IMPORTANT 段與 Guardrails 段）
- **THEN** 該段落明列允許寫入的路徑（`openspec/changes/**` 與 `CONTEXT.md`），且不含 "that's capturing thinking, not implementing" 類比句與 "right away" 寫入指示

#### Scenario: 引導實作請求至 propose

- **WHEN** explore mode 中使用者要求直接修改 code（如「那你直接改一改」）
- **THEN** skill 指示 AI 拒絕寫入並引導使用者執行 `/opsx:propose`，且此行為以對話範例（few-shot）形式呈現於 skill 的 entry-point 範例區

### Requirement: CONTEXT.md 寫入須走 domain-modeling 程序

`claude/skills/openspec-explore/SKILL.md` 與 `claude/skills/openspec-propose/SKILL.md` 中所有涉及 `CONTEXT.md` 寫入的指示 SHALL 遵循一致程序：詞彙 crystallize 時 invoke `domain-modeling` skill（或至少先讀同 skills 目錄下 `domain-modeling` 的 `SKILL.md` 與 `CONTEXT-FORMAT.md`），經挑戰程序 resolved 後才寫入。兩個 skill SHALL NOT 含有 "right away"、"immediately"、"Do not batch" 等繞過程序的寫入指示。

#### Scenario: explore skill 程序指示

- **WHEN** 檢視 `claude/skills/openspec-explore/SKILL.md` 的 domain vocabulary 條目
- **THEN** 指示要求 invoke `domain-modeling` skill 走挑戰程序（challenge → resolve → write），而非直接寫入

#### Scenario: propose skill 程序指示

- **WHEN** 檢視 `claude/skills/openspec-propose/SKILL.md` 的 domain vocabulary 條目（原 L120-121）
- **THEN** "immediately / right away / Do not batch" 字眼已移除，指示與 explore skill 的程序一致

#### Scenario: grep 驗證舊字眼消除

- **WHEN** 在 `claude/skills/openspec-explore/SKILL.md` 與 `claude/skills/openspec-propose/SKILL.md` 內 grep `right away`、`immediately`、`Do not batch`
- **THEN** 兩檔案的 `CONTEXT.md` 寫入指示段落無這些字眼（非 CONTEXT.md 語境的其他用法不在此限）
