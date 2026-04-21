## Why

`docs/ENV_SETUP.md` 和 `env.example` 中記載了多個已過時或不再使用的環境變數與設定流程，與實際的 `~/.env` 和 `.gitconfig` 內容脫節。這次變更將移除不再需要的文件、腳本與範本項目，讓專案內容反映目前的實際狀態。

## What Changes

- 刪除 `docs/ENV_SETUP.md`（整份過時）
- 刪除 `scripts/setup-git-credentials.sh`
- `env.example` 移除以下廢棄/過時變數：
  - `GITLAB_TOKEN`（GitLab 認證不在此專案管理範圍）
  - `NOTION_TOKEN`（已改用 Claude Code plugin OAuth）
  - `CONTEXT7_API_KEY`（已改用 Claude Code plugin）
  - `OCUSER_SOURCE_DIR`（已廢棄）
  - `CNC_NATIVE_LIB_PATH`（已廢棄）
  - `WINDOWS_HOST` / `WINDOWS_PASSWORD`（命名已過時）
  - `APPKERNEL_WINDOWS_HOST` / `APPKERNEL_WINDOWS_PASSWORD` / `APPKERNEL_SAMBA_USER` / `APPKERNEL_SAMBA_PASSWORD`（命名已過時）
- `env.example` 新增實際使用的變數（對齊 `~/.env` 命名）：
  - `WINDOWS_SSH_HOST` / `WINDOWS_SSH_PASSWORD`
  - `SAMBA_SERVER` / `SAMBA_USER` / `SAMBA_PASSWORD` / `SAMBA_SHARE_ROOT`
- `Makefile` 移除 `setup-git-credentials` 相關的三處引用

## Capabilities

### New Capabilities

（無新 capability）

### Modified Capabilities

- `setup-guide`: 移除 `docs/ENV_SETUP.md` 及 `setup-git-credentials.sh` 的引用

## Impact

- `docs/ENV_SETUP.md` — 刪除
- `scripts/setup-git-credentials.sh` — 刪除
- `env.example` — 移除 9 個過時項目，新增 6 個實際使用的項目
- `Makefile` — 移除 3 處 `setup-git-credentials` 引用
- `docs/SETUP.md` — 可能需移除對 ENV_SETUP.md 的引用（實作時確認）
