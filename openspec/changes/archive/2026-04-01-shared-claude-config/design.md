## Context

目前 `~/.claude` 是一個指向 `~/.dotfiles/.claude` 的整個目錄 symlink。Claude Code 會在 `~/.claude/` 下寫入大量 runtime 產物（plugins, debug, sessions, projects 等），這些產物透過 symlink 實際存在於 dotfiles repo 中。

未來架構需要多個 Docker container（不同 Yocto 專案的 build 環境）共用 Claude 個人設定。每個 container 的 `~/.claude/` 在 container 重建時會被清除，所以 runtime 產物不需要持久化，但 config 需要一致。

### 目前的 symlink 佈局

```
~/.claude  →  ~/.dotfiles/.claude/   (整個目錄 symlink)
```

### .claude/ 內容分類

| 類型 | 項目 | 處理方式 |
|------|------|---------|
| 單檔 config | settings.json, CLAUDE.md | 單檔 symlink |
| 目錄型 config | commands/, skills/ | 整個目錄 symlink |
| Runtime | plugins/, debug/, sessions/, projects/, session-env/, telemetry/, cache/, paste-cache/, backups/, logs/, shell-snapshots, todos/, tasks/, plans/, file-history/, ide/ | 不 symlink |

## Goals / Non-Goals

**Goals:**
- Runtime 產物不再出現在 dotfiles repo 中
- 多個 container 可透過 volume mount dotfiles repo + `make install` 共用同一份 Claude config
- 單一 environment 的 runtime 產物完全隔離
- 遷移過程不遺失現有設定
- 路徑不寫死，透過 `ROOT_DIR` 自動解析

**Non-Goals:**
- 不處理 `.nvim/`（neovim config 目前沒有 runtime 產物問題）
- 不處理 Claude Code binary 的安裝
- 不處理 container 內 Claude Code 的認證流程
- 不新增獨立的 container entrypoint script（直接用 `make install`）

## Decisions

### 1. 混合 symlink 策略

**決定**：將 `.claude/` 按內容類型分為三種處理方式。

```
~/.claude/
├── settings.json     → $(ROOT_DIR)/.claude/settings.json     (單檔 symlink)
├── CLAUDE.md         → $(ROOT_DIR)/.claude/CLAUDE.md         (單檔 symlink)
├── .gitignore        → $(ROOT_DIR)/.claude/.gitignore        (單檔 symlink)
├── commands/         → $(ROOT_DIR)/.claude/commands/         (目錄 symlink)
├── skills/           → $(ROOT_DIR)/.claude/skills/           (目錄 symlink)
├── scripts/          → $(ROOT_DIR)/.claude/scripts/          (目錄 symlink)
└── (其他目錄)        ← Claude Code 自行建立，各環境獨立
```

**理由**：commands/ 和 skills/ 是目錄結構，內容會被外部 plugin（openspec, superpowers）動態新增，用整個目錄 symlink 才能讓新安裝的 commands/skills 自動出現在 repo 中。scripts/ 裡的 shell scripts 同理。

**排除的方案**：
- 全部用單檔 symlink → 每次 openspec 安裝新 command 都要更新 Makefile，維護成本高
- 用 GNU stow 管理 → 引入額外 dependency，且 stow 的 symlink 行為在 container 內不直覺

### 2. Symlink 方向

**決定**：symlink 從 `~/.claude/` 指向 `$(ROOT_DIR)/.claude/`（從使用端指向 repo）。

**理由**：與現有 Makefile 的 symlink 方向一致。

### 3. 不新增獨立 script，統一用 Makefile

**決定**：移除 `claude-container-entrypoint` capability。本地和 container 環境都透過 `make install`（或 `make claude`）部署。現有的 `ROOT_DIR` 變數已經透過 `$(realpath $(firstword $(MAKEFILE_LIST)))` 自動解析 repo 路徑，不需要寫死。

```
Local:       cd ~/.dotfiles && make install         → ROOT_DIR=/home/10101672/.dotfiles
Container:   cd ~/shared_zone/dotfiles && make install → ROOT_DIR=/root/shared_zone/dotfiles
```

**理由**：
- 避免兩份實作維護同一套 symlink 邏輯
- `ROOT_DIR` 機制已經解決路徑問題
- Container 只要 volume mount dotfiles repo 就能用

### 4. Makefile 結構

**決定**：
- `claude` target 改為混合 symlink 部署

### 5. .gitignore 簡化

**決定**：移除所有 `.claude/<runtime-dir>/` 規則，因為 runtime 產物不再會出現在 repo 中。保留 `.claude/skills/openspec-*/` 和 `.claude/commands/opsx/` 的排除（這些目錄是 symlink 進來的，openspec/superpowers 可能往裡面寫東西）。

## Risks / Trade-offs

- **[新增 config 檔要手動加 symlink]** → 如果 Claude Code 未來新增 config 檔案，需要手動更新 Makefile。可透過在 Makefile 中使用變數列表集中管理減少遺忘風險。
- **[目錄 symlink 內的 runtime 檔案]** → openspec 和 superpowers 可能往 commands/ 和 skills/ 寫入檔案，這些會出現在 repo 中。透過 .gitignore 排除特定 pattern 緩解。
- **[遷移期間的 session 中斷]** → 移除 `~/.claude` symlink 會中斷正在執行的 Claude Code session。需要在 session 結束後執行遷移。

## Migration Plan

現有環境的遷移手動執行即可（**必須在 Claude Code session 結束後執行**）：

1. 結束所有 Claude Code session
2. 移除舊的整個目錄 symlink：`rm ~/.claude`
3. 建立真實目錄：`mkdir ~/.claude`
4. 搬移需要保留的 runtime 產物：
   ```bash
   mv ~/.dotfiles/.claude/plugins ~/.claude/   # 已安裝的插件
   mv ~/.dotfiles/.claude/projects ~/.claude/  # 專案記錄
   ```
5. 執行 `make claude` 建立混合 symlink
6. 清理 repo 內的 runtime 產物：
   ```bash
   cd ~/.dotfiles
   rm -rf .claude/debug .claude/sessions .claude/session-env \
          .claude/telemetry .claude/cache .claude/paste-cache \
          .claude/backups .claude/logs .claude/shell-snapshots \
          .claude/todos .claude/tasks .claude/plans \
          .claude/file-history .claude/ide
   ```
7. 驗證 symlink 正確：`make check`
8. Commit 更改
