## 1. 刪除過時檔案

- [x] 1.1 刪除 `docs/ENV_SETUP.md`
- [x] 1.2 刪除 `scripts/setup-git-credentials.sh`

## 2. 更新 env.example

- [x] 2.1 移除廢棄/過時變數：GITLAB_TOKEN、NOTION_TOKEN、CONTEXT7_API_KEY、OCUSER_SOURCE_DIR、CNC_NATIVE_LIB_PATH、WINDOWS_HOST、WINDOWS_PASSWORD、APPKERNEL_WINDOWS_HOST、APPKERNEL_WINDOWS_PASSWORD、APPKERNEL_SAMBA_USER、APPKERNEL_SAMBA_PASSWORD
- [x] 2.2 新增實際使用的變數（對齊 ~/.env 命名）：WINDOWS_SSH_HOST、WINDOWS_SSH_PASSWORD、SAMBA_SERVER、SAMBA_USER、SAMBA_PASSWORD、SAMBA_SHARE_ROOT

## 3. 更新 Makefile

- [x] 3.1 移除 `scripts` target 中 setup-git-credentials 的 symlink 建立（L86）
- [x] 3.2 移除 `uninstall` target 中 setup-git-credentials 的移除（L120）
- [x] 3.3 移除 `check` target 中 setup-git-credentials 的檢查（L198）

## 4. 更新 SETUP.md

- [x] 4.1 移除步驟 9 中對 `docs/ENV_SETUP.md` 的引用

## 5. 更新 openspec/specs

- [x] 5.1 更新 `openspec/specs/setup-guide/spec.md`，移除對 ENV_SETUP.md 的引用（REMVOED requirement 已在 change spec 中定義，archive 時會自動合併）
