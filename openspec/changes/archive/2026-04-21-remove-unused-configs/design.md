## Context

dotfiles 專案管理個人開發環境設定，透過 Makefile 建立 symlink 部署。`~/.env` 載入機制（由 `.bashrc` 的 `[ -f ~/.env ] && . ~/.env` 處理）仍保留，但 `env.example` 和 `docs/ENV_SETUP.md` 的內容與實際 `~/.env` 有顯著落差。

目前狀態：
- `.gitconfig` 已寫死 `user.name` / `user.email`，不再使用環境變數
- Notion / Context7 認證已改用 Claude Code plugin OAuth
- Windows 連線和 Samba 相關變數命名已更改但 env.example 未同步
- `setup-git-credentials.sh` 管理 GitLab HTTPS 認證，但不屬於 dotfiles 管理範圍

## Goals / Non-Goals

**Goals:**
- 移除所有過時的文件、腳本與 env.example 項目
- env.example 反映目前 ~/.env 的實際變數命名
- Makefile 移除已刪除腳本的引用
- SETUP.md 移除對已刪除文件的引用

**Non-Goals:**
- 不修改 `~/.env` 的實際內容（使用者自行管理）
- 不修改 `.bashrc` 的載入機制
- 不新增環境變數管理工具或驗證機制
- 不重寫 SETUP.md（只移除對 ENV_SETUP.md 的引用）

## Decisions

### 1. 刪除 `docs/ENV_SETUP.md` 而非重寫

**選擇**: 刪除整份文件
**原因**: 文件內容大多已過時，且 env.example 本身的註解已提供足夠說明。大幅改寫的成本高於刪除後將必要資訊併入 env.example 註解。
**替代方案**: 重寫為精簡版 — 但文件獨立維護容易再次脫節，不如讓 env.example 自描述。

### 2. 刪除 `scripts/setup-git-credentials.sh`

**選擇**: 刪除腳本及 Makefile 中所有引用
**原因**: GitLab 認證管理不屬於 dotfiles 專案範圍。git 的 `credential.helper = store` 機制本身已足夠。
**替代方案**: 保留腳本但更新文件 — 但使用者確認不需要。

### 3. SETUP.md 處理方式

**選擇**: 移除對 ENV_SETUP.md 的引用，env.example 的內容自描述
**原因**: ENV_SETUP.md 刪除後引用會失效。env.example 的行內註解已足夠說明每個變數。

## Risks / Trade-offs

- [風險] 移除 ENV_SETUP.md 後新手可能缺少環境變數的背景說明 → env.example 的行內註解涵蓋基本需求，且 `~/.env` 由使用者自行管理不需外部文件指導
- [風險] SETUP.md 的 setup-guide spec 引用了 ENV_SETUP.md → 需同步更新 spec
