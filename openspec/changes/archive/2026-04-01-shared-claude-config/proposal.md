## Why

目前 dotfiles 的 `.claude/` 使用整個目錄 symlink 的部署方式（`~/.claude → ~/.dotfiles/.claude`），導致 Claude Code 的 runtime 產物（plugins, debug, sessions, projects 等，共約 140MB）直接寫入 dotfiles repo 中。未來多個 Docker container（不同 Yocto 專案的 build 環境）也需要共用 Claude 個人設定，如果沿用整個目錄 symlink/mount 的方式，多個 container 的 Claude Code 會寫入同一個 runtime 目錄造成衝突。需要將 config（唯讀共享）和 runtime（每個環境獨立）分離。

## What Changes

- **BREAKING** 將 `~/.claude` 從「整個目錄 symlink」改為「混合 symlink 策略」：單檔 config（settings.json, CLAUDE.md）用單檔 symlink，目錄型 config（commands/, skills/）用整個目錄 symlink，runtime 產物不 symlink 讓各環境獨立管理
- 簡化 `.gitignore`，移除不再需要的 runtime 產物排除規則（plugins/, debug/, sessions/, projects/ 等不再出現在 repo）
- 更新 Makefile 的 `claude` target 支援新的混合 symlink 部署方式
- 路徑不寫死，透過現有 `ROOT_DIR` 機制自動解析，本地和 container 環境都能用 `make install`

## Capabilities

### New Capabilities

- `claude-config-symlink`: 混合 symlink 部署策略，定義哪些檔案用單檔 symlink、哪些目錄用整個目錄 symlink、哪些 runtime 目錄不處理

### Modified Capabilities

(無，現有 spec 的 requirement 不變)

## Impact

- **Makefile**: `claude` target 重寫
- **.gitignore**: `.claude/` 相關的 runtime 排除規則大幅簡化
- **.claude/ 目錄結構**: repo 內只保留 config 檔和 config 目錄，runtime 產物不再出現
- **Container**: 透過 volume mount dotfiles repo 後直接 `make install` 即可，不需額外 script
