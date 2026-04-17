## Context

dotfiles 專案使用 Makefile + symlink 將各種設定檔部署到 home directory。Claude Code 相關設定目前存放在 `dotfiles/.claude/`（hidden 目錄），包含全域 CLAUDE.md、settings.json、commands、skills、scripts。部署時由 `make claude` 將這些項目個別 symlink 到 `~/.claude/`（Claude Code runtime 目錄）。

Claude Code 使用 `.claude/CLAUDE.md` 作為 project-level 指令。但目前 `.claude/` 已被 user settings 佔用，無法在同一 repo 建立 project-level CLAUDE.md。

## Goals / Non-Goals

**Goals:**
- 分離 Claude Code user settings（`claude/`）與 project-level 設定（`.claude/CLAUDE.md`）
- 簡化 Makefile，移除不使用的 backup/restore/clean 功能
- 確保已部署環境可安全遷移

**Non-Goals:**
- 不改變 Claude Code runtime 目錄（`~/.claude/`）的結構
- 不改變 scripts、commands、skills 的內容
- 不改變其他 dotfiles 模組（bash、nvim、git 等）

## Decisions

### D1: 目錄命名 — `.claude/` → `claude/`

**選擇**：將 user settings 目錄 rename 為 visible 的 `claude/`。

**理由**：這些檔案是專案的一部分，不該隱藏。與 README 和 Makefile 中 `make claude` 的語意一致。

**替代方案**：保留 `.claude/` 並將 project-level CLAUDE.md 放在 repo root（但 Claude Code 只認 `.claude/CLAUDE.md`）。

### D2: .gitignore 使用 allowlist 模式

**選擇**：
```gitignore
.claude/*
!.claude/CLAUDE.md
```

**理由**：Claude Code 可能未來在 `.claude/` 下產生其他檔案（如 `settings.local.json`），兜底規則防止意外 commit。

### D3: 移除 backup/restore/clean

**選擇**：完整移除這三個 target。

**理由**：dotfiles 由 git 管理，恢復只需 `git checkout`。`make restore` 的 `cp -r` 有覆蓋 Claude Code runtime data 的風險。使用者確認幾乎不使用。

**替代方案**：僅移除 `install` 前的自動 backup，保留手動 `make backup`。但維護成本不值得。

### D4: 遷移策略 — 手動兩步驟

**選擇**：不寫自動 migration script，改為文件指引。

**理由**：只有一台機器需要遷移，步驟只有 rm + make claude，不值得抽象化。

## Risks / Trade-offs

- **[Dangling symlinks]** → 遷移後若忘記 `make claude`，舊 symlinks 會失效。Mitigation：`make check` 可偵測。
- **[命名不一致]** → `claude/` 是 visible 目錄，與其他 dotfiles（`.nvim/`、`.tigrc`）風格不同。Acceptable：這些是 Claude Code 特有的設定，語意上不同。
- **[CLAUDE.md 衝突]** → `.claude/CLAUDE.md`（project-level）和 `claude/CLAUDE.md`（global）載入順序由 Claude Code 決定。專案級覆蓋全域級是預期行為。
