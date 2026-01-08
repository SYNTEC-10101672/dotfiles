# CLIProxyAPI + Antigravity 設定指南

## 概述

**CLIProxyAPI** 是一個統一的 AI API 代理服務，透過 Docker 部署，支援多個 AI provider：
- Antigravity (Google OAuth，免費使用 Claude 和 Gemini)
- Gemini CLI
- OpenAI Codex
- Qwen Code

本指南說明如何部署 CLIProxyAPI 並透過 `claude-cliproxy` 腳本使用。

## 快速開始

### 1. 建立配置文件

```bash
# 建立工作目錄
mkdir -p ~/cliproxyapi/{auth,logs}
cd ~/cliproxyapi
```

創建 `~/cliproxyapi/config.yaml`：

```yaml
# Server configuration
host: ""
port: 8317

# Authentication directory
auth-dir: "~/.cli-proxy-api"

# Enable debug logging
debug: true

# Routing strategy
routing:
  strategy: "round-robin"

# Model mappings - 只使用 Sonnet 4 模型
ampcode:
  model-mappings:
    - from: "claude-sonnet-4-5-20250929"
      to: "gemini-claude-sonnet-4-5"
    - from: "claude-opus-4-5-20251101"
      to: "gemini-claude-sonnet-4-5"  # 強制使用 Sonnet 而非 Opus
    - from: "claude-haiku-4-5-20251001"
      to: "gemini-2.5-flash"

# WebUI 管理介面
remote-management:
  allow-remote: true
  secret-key: "MGT-123456"  # 請修改為強密碼
  disable-control-panel: false
```

**配置說明**：
- `routing.strategy`: `round-robin` 輪流使用帳號，`fill-first` 優先用完第一個帳號
- `ampcode.model-mappings`: Opus 映射到 Sonnet，避免使用高配額模型
- `remote-management`: 啟用 WebUI 管理介面

### 2. 下載並啟動 Docker

```bash
# 下載最新的 CLIProxyAPI image
docker pull eceasy/cli-proxy-api:latest

# 啟動容器
docker run -d \
  --name cliproxyapi \
  --restart unless-stopped \
  -p 8080:8317 \
  -p 51121:51121 \
  -v ~/cliproxyapi/config.yaml:/CLIProxyAPI/config.yaml \
  -v ~/cliproxyapi/auth:/root/.cli-proxy-api \
  -v ~/cliproxyapi/logs:/CLIProxyAPI/logs \
  eceasy/cli-proxy-api:latest

# 驗證啟動
docker ps | grep cliproxyapi
docker logs cliproxyapi --tail 20
```

**Port 說明**：
- `8080`: API endpoint 和 WebUI
- `51121`: OAuth callback (登入 Antigravity 時需要)

### 3. 登入 Antigravity 帳號

#### 方式 1: 本地操作（有圖形介面）

```bash
docker exec cliproxyapi ./CLIProxyAPI --antigravity-login
# 瀏覽器會自動開啟，完成 Google OAuth 授權
```

#### 方式 2: 遠端 SSH 連線（推薦）

**步驟 1**: 在伺服器執行登入命令

```bash
docker exec cliproxyapi ./CLIProxyAPI --antigravity-login --no-browser
```

會顯示 OAuth URL 和 SSH tunnel 指令。

**步驟 2**: 在本地電腦開新終端建立 SSH Tunnel

```bash
ssh -L 51121:127.0.0.1:51121 root@YOUR_SERVER_IP -p SSH_PORT
# 保持這個連線不要關閉
```

**步驟 3**: 在本地瀏覽器打開步驟 1 顯示的 OAuth URL，完成授權

**步驟 4**: 回到伺服器確認登入成功

```bash
# 重啟容器載入新帳號
docker restart cliproxyapi && sleep 3

# 驗證帳號已載入
docker logs cliproxyapi --tail 30 | grep antigravity
```

**新增多個帳號**：重複上述流程，最多支援 10 個帳號，會自動輪換使用。

### 4. 開啟 WebUI

根據環境選擇訪問方式：

- **本地訪問**: `http://127.0.0.1:8080/management.html`
- **遠端訪問**: `http://YOUR_SERVER_IP:8080/management.html`

登入時輸入 `config.yaml` 中設定的 `secret-key`（例如：`MGT-123456`）。

**WebUI 功能**：
- 查看已認證的 Antigravity 帳號狀態
- 檢視可用的 AI 模型清單
- 監控帳號輪換狀態和 API 使用情況
- 查看即時日誌

**重要**: WebUI 無法進行 OAuth 登入，新增帳號請使用步驟 3 的 CLI 方式。

### 5. 使用 claude-cliproxy

#### 安裝腳本

```bash
# 使用 dotfiles Makefile 安裝
cd ~/Projects/dotfiles
make scripts

# 或手動安裝
ln -sf ~/Projects/dotfiles/scripts/claude-cliproxy ~/bin/claude-cliproxy
```

#### 基本使用

```bash
# 使用預設模型 (Claude Sonnet)
claude-cliproxy "hello"

# 互動模式
claude-cliproxy
```

#### 使用 --model 參數切換 AI Provider

```bash
# 使用 Claude 模型 (預設)
claude-cliproxy --model claude "explain this code"

# 使用 Gemini 原生模型
claude-cliproxy --model gemini "explain this code"

# 使用 Gemini Flash (最快速度)
claude-cliproxy --model flash "explain this code"
```

**Provider 對照表**：

| Provider | Sonnet 模型 | Opus 模型 | Haiku 模型 | 說明 |
|---------|------------|----------|-----------|------|
| `claude` | gemini-claude-sonnet-4-5 | gemini-claude-sonnet-4-5 | gemini-2.5-flash | 透過 Antigravity 使用 Claude，品質最佳 |
| `gemini` | gemini-3-pro-preview | gemini-3-pro-preview | gemini-3-flash-preview | Gemini 原生模型 |
| `flash` | gemini-2.5-flash | gemini-2.5-flash | gemini-2.5-flash-lite | 速度最快 |

**使用建議**：
- 複雜任務：`--model claude`（品質最佳）
- 簡單任務：`--model flash`（速度最快）
- 測試 Gemini：`--model gemini`

### 6. 更新 CLIProxyAPI

```bash
# 停止並刪除舊容器
docker stop cliproxyapi
docker rm cliproxyapi

# 拉取最新 image
docker pull eceasy/cli-proxy-api:latest

# 使用步驟 2 的指令重新啟動容器
docker run -d \
  --name cliproxyapi \
  --restart unless-stopped \
  -p 8080:8317 \
  -p 51121:51121 \
  -v ~/cliproxyapi/config.yaml:/CLIProxyAPI/config.yaml \
  -v ~/cliproxyapi/auth:/root/.cli-proxy-api \
  -v ~/cliproxyapi/logs:/CLIProxyAPI/logs \
  eceasy/cli-proxy-api:latest

# 驗證更新成功
docker logs cliproxyapi --tail 20
```

**注意**: 更新後 `config.yaml` 和帳號認證資料都會保留。

## 常用操作

### 查看日誌

```bash
# 即時日誌
docker logs -f cliproxyapi

# 最近 50 行
docker logs cliproxyapi --tail 50
```

### 管理帳號

```bash
# 查看已認證帳號
ls -la ~/cliproxyapi/auth/

# 移除特定帳號
rm ~/cliproxyapi/auth/antigravity-YOUR_EMAIL.json
docker restart cliproxyapi
```

### 修改配置

```bash
# 編輯配置文件
vim ~/cliproxyapi/config.yaml

# 重啟容器使配置生效
docker restart cliproxyapi
```

### 查看可用模型

```bash
curl http://127.0.0.1:8080/v1/models
```

## 故障排除

### OAuth 登入超時

**症狀**: `authentication timed out`

**解決**: OAuth 流程有 5 分鐘時效，重新執行登入命令即可。

### OAuth state 不匹配

**症狀**: `invalid state`

**解決**: 確保使用最新產生的 OAuth URL，不要重複使用舊的 URL。

### SSH Tunnel 無法建立

**症狀**: OAuth 授權後沒有回應

**解決**:
- 確認 SSH tunnel 命令正確執行且保持連線
- 確認伺服器防火牆允許 port 51121
- 檢查 SSH 連線是否穩定

### 容器無法啟動

**症狀**: `docker ps` 沒有 cliproxyapi

**解決**:
```bash
# 查看詳細錯誤
docker logs cliproxyapi

# 檢查 port 是否被占用
sudo netstat -tlnp | grep 8080
```

## 進階配置

### 自訂模型映射

如果要使用 Opus 或其他映射組合，編輯 `config.yaml`：

```yaml
# 範例 1: 全部使用 Flash（最快速度）
ampcode:
  model-mappings:
    - from: "claude-sonnet-4-5-20250929"
      to: "gemini-2.5-flash"
    - from: "claude-opus-4-5-20251101"
      to: "gemini-2.5-flash"
    - from: "claude-haiku-4-5-20251001"
      to: "gemini-2.5-flash"

# 範例 2: 使用原本的 Opus
ampcode:
  model-mappings:
    - from: "claude-sonnet-4-5-20250929"
      to: "gemini-claude-sonnet-4-5"
    - from: "claude-opus-4-5-20251101"
      to: "gemini-claude-opus-4-5-thinking"
    - from: "claude-haiku-4-5-20251001"
      to: "gemini-2.5-flash"
```

修改後重啟容器：`docker restart cliproxyapi`

## 參考資源

- [CLIProxyAPI GitHub](https://github.com/router-for-me/CLIProxyAPI)
- [CLIProxyAPI 官方文檔](https://help.router-for.me/)
- [Claude Code 配置說明](https://help.router-for.me/cn/agent-client/claude-code)
- [Antigravity 配置說明](https://help.router-for.me/configuration/provider/antigravity)
