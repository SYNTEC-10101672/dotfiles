# 環境變數設定指南

## 概述

本專案使用 `~/.env` 檔案統一管理所有環境變數，包括：
- Git 使用者設定
- GitLab 認證 token
- MCP Server 認證資訊（SYNTEC Confluence/JIRA、Notion）

## 快速設定

### 1. 建立 ~/.env 檔案

```bash
# 複製範本檔案到 home 目錄
cp ~/dotfiles/env.example ~/.env

# 編輯並填入你的實際帳號資訊
nano ~/.env
```

### 2. 設定權限（重要！）

```bash
# 確保只有你能讀寫這個檔案
chmod 600 ~/.env
```

### 3. 重新載入 shell 環境

```bash
# 方法1：重新載入 bashrc
source ~/.bashrc

# 方法2：開啟新的終端視窗
```

### 4. 驗證設定

```bash
# 檢查環境變數是否正確載入
echo $GIT_USER_NAME
echo $GIT_USER_EMAIL
echo $GITLAB_TOKEN
echo $SYNTEC_EMAIL
echo $NOTION_TOKEN
```

## 環境變數詳細說明

### Git 設定

#### GIT_USER_NAME
- **用途**: Git commit 的使用者名稱
- **範例**: `10101672`
- **使用位置**: `.gitconfig` 的 `user.name`

#### GIT_USER_EMAIL
- **用途**: Git commit 的 email
- **範例**: `ken.chang@syntecclub.com.tw`
- **使用位置**: `.gitconfig` 的 `user.email`

#### GITLAB_TOKEN
- **用途**: GitLab HTTPS clone/push 認證
- **產生位置**: https://gitlab.syntecclub.com/-/profile/personal_access_tokens
- **權限需求**:
  - `read_repository` - 讀取專案
  - `write_repository` - 推送程式碼
- **格式**: `glpat-xxxxxxxxxxxxxxxxxxxx`

### MCP Server 設定

#### SYNTEC_EMAIL
- **用途**: SYNTEC Confluence/JIRA MCP 認證
- **範例**: `your.email@syntecclub.com.tw`
- **說明**: 你的 Atlassian 帳號 email

#### SYNTEC_API_TOKEN
- **用途**: SYNTEC Confluence/JIRA MCP API 認證
- **產生位置**: https://id.atlassian.com/manage-profile/security/api-tokens
- **格式**: 一串隨機字元

#### NOTION_TOKEN
- **用途**: Notion MCP Server 認證
- **產生位置**: https://www.notion.so/my-integrations
- **格式**: `ntn_xxxxxxxxxxxxxxxxxxxx`

### 硬體控制設定

#### TASMOTA_IP
- **用途**: Tasmota 智能插座 IP 位址（用於 CNC 控制器重置）
- **範例**: `10.10.90.50`
- **說明**: 控制 CNC 控制器電源的智能插座 IP

#### TASMOTA_PORT
- **用途**: Tasmota HTTP 服務 port
- **預設**: `8080`
- **說明**: Tasmota Web UI 和 API 的連接埠

## Git 設定詳細步驟

### 方法一：自動設定（推薦）

使用提供的自動化腳本：

```bash
# 執行 Git credentials 設定腳本
~/dotfiles/scripts/setup-git-credentials.sh
```

這個腳本會：
1. ✅ 從 `~/.env` 載入環境變數
2. ✅ 設定 Git 全域使用者名稱和 email
3. ✅ 自動設定 GitLab HTTPS 認證
4. ✅ 備份現有的 credentials（如果有）
5. ✅ 設定正確的檔案權限

### 方法二：手動設定

如果不想使用腳本，可以手動設定：

#### 1. 設定 Git 使用者資訊
```bash
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
```

#### 2. 設定 GitLab HTTPS 認證

**選項 A**: 使用 Git credential store（推薦）
```bash
# Git 會自動使用 credential.helper = store（已在 .gitconfig 設定）
# 第一次 clone 時會提示輸入：
# Username: oauth2
# Password: <你的 GITLAB_TOKEN>

git clone https://gitlab.syntecclub.com/your-group/your-repo.git
```

**選項 B**: 手動編輯 ~/.git-credentials
```bash
# 編輯 credentials 檔案
nano ~/.git-credentials

# 加入以下內容（替換 YOUR_TOKEN）
https://oauth2:YOUR_TOKEN@gitlab.syntecclub.com

# 設定權限
chmod 600 ~/.git-credentials
```

### GitLab Token 更新

當 GitLab token 過期時：

```bash
# 1. 到 GitLab 產生新的 Personal Access Token
# 2. 更新 ~/.env 中的 GITLAB_TOKEN
nano ~/.env

# 3. 重新執行設定腳本
~/dotfiles/scripts/setup-git-credentials.sh

# 4. 完成！
```

## MCP Server 設定

### SYNTEC Confluence/JIRA MCP

```bash
# 啟動 MCP Server
cd ~/dotfiles/.claude
./scripts/start-mcp-server.sh

# 檢查連線狀態
./scripts/check-mcp-connection.sh
```

### Notion MCP

Notion MCP 會在 Claude Code 啟動時自動透過 npx 執行，無需手動啟動。

## 硬體控制工具

### CNC 控制器重置

使用 `resetcnc` 腳本透過 Tasmota 智能插座重置 CNC 控制器：

```bash
# 執行 CNC 控制器重置
~/dotfiles/scripts/resetcnc
```

這個腳本會：
1. 讀取 `~/.env` 中的 `TASMOTA_IP` 和 `TASMOTA_PORT`
2. 向 Tasmota 智能插座發送關機指令
3. 等待 2 秒
4. 發送開機指令

**注意**：確保 Tasmota 智能插座已正確設定並連接到網路。

## 檔案說明

### ~/.env（不追蹤）
- **位置**: `~/.env`（home 目錄）
- **用途**: 存放敏感的環境變數
- **追蹤**: **不會**被 git 追蹤（因為在 repo 外）
- **載入**: 每次開啟 shell 時由 `.bashrc` 自動載入
- **權限**: `600`（只有自己能讀寫）

### env.example（追蹤）
- **位置**: `~/dotfiles/env.example`
- **用途**: 環境變數範本，供參考使用
- **追蹤**: **會**被 git 追蹤
- **注意**: 只包含範例，不含真實資料

### .gitconfig（追蹤）
- **位置**: `~/dotfiles/.gitconfig`
- **用途**: Git 全域設定
- **特點**: 使用環境變數 `$GIT_USER_NAME` 和 `$GIT_USER_EMAIL`
- **追蹤**: **會**被 git 追蹤

### ~/.git-credentials（不追蹤）
- **位置**: `~/.git-credentials`（home 目錄）
- **用途**: Git credential helper 存放認證資訊
- **追蹤**: **不會**被 git 追蹤（因為在 repo 外）
- **格式**: `https://oauth2:TOKEN@gitlab.syntecclub.com`
- **權限**: `600`（只有自己能讀寫）

## 安全最佳實務

✅ **應該做的事**
- 將真實的 credentials 存放在 `~/.env`
- 設定 `~/.env` 權限為 `600`
- 定期更新 `env.example` 範本（但不含真實資料）
- 在不同機器上分別設定 `~/.env`
- 定期更換 API tokens

❌ **不應該做的事**
- 將 `~/.env` 加入 git 追蹤
- 在 `env.example` 中放入真實的 token/密碼
- 分享你的 `~/.env` 檔案內容
- 將環境變數寫死在程式碼中
- 在公開場合展示包含 token 的畫面

## 故障排除

### 環境變數沒有載入

```bash
# 檢查檔案是否存在
ls -la ~/.env

# 檢查檔案內容（確認格式正確）
cat ~/.env

# 手動載入測試
source ~/.env
echo $GIT_USER_NAME
```

### Git 使用者設定沒有生效

```bash
# 檢查當前 Git 設定
git config --global user.name
git config --global user.email

# 如果顯示 $GIT_USER_NAME，表示環境變數未載入
# 請執行設定腳本
~/dotfiles/scripts/setup-git-credentials.sh
```

### GitLab 認證失敗

```bash
# 檢查 token 是否正確
echo $GITLAB_TOKEN

# 檢查 credentials 檔案
cat ~/.git-credentials

# 重新設定
~/dotfiles/scripts/setup-git-credentials.sh
```

### MCP Server 無法連接

```bash
# 檢查環境變數
echo $SYNTEC_EMAIL
echo $SYNTEC_API_TOKEN
echo $NOTION_TOKEN

# 重新載入環境變數
source ~/.env

# 重新啟動 MCP Server
cd ~/dotfiles/.claude
./scripts/start-mcp-server.sh
```

### 權限問題

```bash
# 重新設定正確的權限
chmod 600 ~/.env
chmod 600 ~/.git-credentials
```

## 多機器設定

在不同機器上使用相同的 dotfiles：

```bash
# 1. Clone dotfiles 專案
git clone <your-dotfiles-repo> ~/dotfiles

# 2. 建立本機環境變數檔案
cp ~/dotfiles/env.example ~/.env

# 3. 編輯填入該機器的設定
nano ~/.env

# 4. 執行 Git 設定腳本
~/dotfiles/scripts/setup-git-credentials.sh

# 5. 重新載入 shell
source ~/.bashrc
```

## 參考資料

- [dotfiles/.bashrc:19](/home/10101672/dotfiles/.bashrc:19) - 環境變數自動載入
- [dotfiles/env.example](/home/10101672/dotfiles/env.example) - 環境變數範本
- [dotfiles/.gitconfig:40-41](/home/10101672/dotfiles/.gitconfig:40) - Git 使用者設定
- [dotfiles/scripts/setup-git-credentials.sh](/home/10101672/dotfiles/scripts/setup-git-credentials.sh) - Git 認證設定腳本
- [dotfiles/scripts/resetcnc](/home/10101672/dotfiles/scripts/resetcnc) - CNC 控制器重置腳本
- [dotfiles/.claude/scripts/start-mcp-server.sh:12](/home/10101672/dotfiles/.claude/scripts/start-mcp-server.sh:12) - MCP Server 環境變數載入
