# CLIProxyAPI + Antigravity 設定指南

## 概述

**CLIProxyAPI** 是一個統一的 AI API 代理服務，支援多個 AI provider，包括：
- Antigravity (Google OAuth，免費使用 Claude 和 Gemini)
- Gemini CLI
- Claude Code
- OpenAI Codex
- Qwen Code

本指南說明如何在伺服器上部署 CLIProxyAPI，並透過 Antigravity OAuth 使用 Claude 模型。

## 架構說明

```
命令層:
┌──────────────────────┐
│  claude-cliproxy  │
│  (設定環境變數後)      │
│  呼叫 claude CLI      │
└──────────┬───────────┘
           │
           │ ANTHROPIC_BASE_URL=http://127.0.0.1:8080
           │ ANTHROPIC_DEFAULT_SONNET_MODEL=gemini-claude-sonnet-4-5
           │
           ▼
┌────────────────────────────────┐
│  CLIProxyAPI                   │
│  (127.0.0.1:8080)              │
│  Docker Container              │
│  - 多帳號輪換 (round-robin)     │
│  - OAuth 認證管理               │
│  - Model mapping               │
└──────────┬─────────────────────┘
           │
   ┌───────┼───────┐
   ▼       ▼       ▼
┌────┐ ┌────┐ ┌────┐
│帳號1│ │帳號2│ │帳號3│
│(AG) │ │(AG) │ │(AG) │
└────┘ └────┘ └────┘
   │       │       │
   └───────┼───────┘
           ▼
    Google Antigravity
    (Claude/Gemini API)
```

## Server 端部署

### 1. 準備工作目錄

```bash
# 建立 CLIProxyAPI 工作目錄
mkdir -p ~/cliproxyapi/{auth,logs}
cd ~/cliproxyapi
```

### 2. 創建配置文件

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

# Amp Integration - Model mappings for Claude Code
ampcode:
  model-mappings:
    - from: "claude-sonnet-4-5-20250929"
      to: "gemini-claude-sonnet-4-5"
    - from: "claude-opus-4-5-20251101"
      to: "gemini-claude-opus-4-5-thinking"
    - from: "claude-haiku-4-5-20251001"
      to: "gemini-2.5-flash"
```

### 3. 下載並啟動 Docker 容器

```bash
# 下載最新的 CLIProxyAPI image
docker pull eceasy/cli-proxy-api:latest

# 啟動容器
docker run -d \
  --name cliproxyapi \
  --restart unless-stopped \
  -p 8080:8317 \
  -p 8085:8085 \
  -p 1455:1455 \
  -p 54545:54545 \
  -p 51121:51121 \
  -p 11451:11451 \
  -v ~/cliproxyapi/config.yaml:/CLIProxyAPI/config.yaml \
  -v ~/cliproxyapi/auth:/root/.cli-proxy-api \
  -v ~/cliproxyapi/logs:/CLIProxyAPI/logs \
  eceasy/cli-proxy-api:latest
```

**Port 對應說明**：
- `8080` (host) → `8317` (container): 主 API endpoint
- `51121`: OAuth callback port（Antigravity 登入時需要）
- 其他 ports: 用於不同 provider 的 OAuth callbacks

### 4. 驗證容器啟動

```bash
# 檢查容器狀態
docker ps | grep cliproxyapi

# 查看日誌
docker logs cliproxyapi --tail 20

# 測試 API endpoint
curl http://127.0.0.1:8080/
```

應該看到：
```json
{
  "endpoints": [
    "POST /v1/chat/completions",
    "POST /v1/completions",
    "GET /v1/models"
  ],
  "message": "CLI Proxy API Server"
}
```

## Antigravity 帳號登入

### 方式 1: 本地操作（有圖形介面）

如果你在伺服器本機有瀏覽器：

```bash
# 執行登入命令
docker exec cliproxyapi ./CLIProxyAPI --antigravity-login

# 瀏覽器會自動開啟，完成 Google OAuth 授權即可
```

### 方式 2: 遠端 SSH 連線（推薦）

如果你是透過 SSH 連線到伺服器：

#### 步驟 1: 啟動登入流程

在**伺服器**上執行：

```bash
docker exec cliproxyapi ./CLIProxyAPI --antigravity-login --no-browser
```

系統會顯示類似：
```
Visit the following URL to continue authentication:
https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&client_id=...

To authenticate from a remote machine, an SSH tunnel may be required.
Run one of the following commands on your local machine:
  ssh -L 51121:127.0.0.1:51121 root@YOUR_SERVER_IP -p 22
```

#### 步驟 2: 建立 SSH Tunnel

在你的**本地電腦**（不是伺服器）開新終端，執行：

```bash
# 替換 YOUR_SERVER_IP 為你的伺服器 IP
# 替換 SSH_PORT 為你的 SSH port（預設 22）
ssh -L 51121:127.0.0.1:51121 root@YOUR_SERVER_IP -p SSH_PORT
```

**保持這個 SSH 連線不要關閉**

#### 步驟 3: 完成 OAuth 授權

在本地電腦的瀏覽器，打開步驟 1 顯示的 Google OAuth URL，完成授權。

#### 步驟 4: 確認登入成功

回到伺服器，應該會看到：
```
Antigravity authentication successful
Using GCP project: dauntless-song-xxxxx
Authentication saved to /root/.cli-proxy-api/antigravity-YOUR_EMAIL.json
Authenticated as your-email@gmail.com
```

### 新增多個帳號

CLIProxyAPI 支援最多 10 個 Antigravity 帳號，會自動輪換使用。

重複上述登入流程，每次用不同的 Google 帳號即可：

```bash
docker exec cliproxyapi ./CLIProxyAPI --antigravity-login --no-browser
```

### 驗證帳號已載入

重啟容器讓新帳號生效：

```bash
docker restart cliproxyapi

# 等待 3 秒
sleep 3

# 檢查日誌
docker logs cliproxyapi --tail 30 | grep antigravity
```

應該會看到：
```
[debug] Registered new model gemini-claude-sonnet-4-5 from provider antigravity
[debug] Registered new model gemini-claude-opus-4-5-thinking from provider antigravity
[debug] Registered client antigravity-YOUR_EMAIL.json from provider antigravity with 10 models
```

## Client 端設定

### 安裝 claude-cliproxy 腳本

本專案提供的 `claude-cliproxy` 腳本已經預先配置好所有必要的環境變數。

```bash
# 使用 dotfiles Makefile 安裝
cd ~/Projects/dotfiles
make scripts

# 或手動安裝
ln -sf ~/Projects/dotfiles/scripts/claude-cliproxy ~/bin/claude-cliproxy
```

### 腳本說明

`claude-cliproxy` 會自動設定：
- `ANTHROPIC_BASE_URL`: 指向 CLIProxyAPI (http://127.0.0.1:8080)
- `ANTHROPIC_AUTH_TOKEN`: 使用 dummy token (sk-dummy)
- `ANTHROPIC_DEFAULT_SONNET_MODEL`: 使用 Antigravity 的 Sonnet 模型
- `ANTHROPIC_DEFAULT_OPUS_MODEL`: 使用 Antigravity 的 Opus 模型  
- `ANTHROPIC_DEFAULT_HAIKU_MODEL`: 使用 Antigravity 的 Haiku 模型

### 使用方式

```bash
# 直接使用
claude-cliproxy "hello"

# 互動模式
claude-cliproxy
```

## 可用模型

透過 Antigravity 可使用以下模型：

| Anthropic 模型 | Antigravity 對應模型 |
|---------------|---------------------|
| claude-sonnet-4-5-20250929 | gemini-claude-sonnet-4-5 |
| claude-opus-4-5-20251101 | gemini-claude-opus-4-5-thinking |
| claude-haiku-4-5-20251001 | gemini-2.5-flash |

另外還有：
- `gemini-3-pro-preview`
- `gemini-3-flash-preview`
- `gemini-2.5-flash-lite`
- `gemini-2.5-computer-use-preview-10-2025`
- `gpt-oss-120b-medium`

查看所有可用模型：
```bash
curl http://127.0.0.1:8080/v1/models
```

## 管理與監控

### 查看日誌

```bash
# 即時日誌
docker logs -f cliproxyapi

# 最近 50 行
docker logs cliproxyapi --tail 50
```

### 重啟服務

```bash
# 修改 config.yaml 後需要重啟
docker restart cliproxyapi
```

### 查看已認證帳號

```bash
ls -la ~/cliproxyapi/auth/
```

### 移除帳號

```bash
# 刪除特定帳號的認證檔案
rm ~/cliproxyapi/auth/antigravity-YOUR_EMAIL.json

# 重啟容器
docker restart cliproxyapi
```

### 停止服務

```bash
docker stop cliproxyapi
```

### 完全移除

```bash
docker stop cliproxyapi
docker rm cliproxyapi
rm -rf ~/cliproxyapi
```

## 故障排除

### 問題 1: OAuth 登入超時

**症狀**：
```
[error] Antigravity authentication failed: antigravity: authentication timed out
```

**解決方式**：
- OAuth 流程有 5 分鐘時效，需要在時限內完成授權
- 重新執行登入命令即可

### 問題 2: OAuth state 不匹配

**症狀**：
```
[error] Antigravity authentication failed: antigravity: invalid state
```

**解決方式**：
- 確保使用最新產生的 OAuth URL
- 不要重複使用舊的 URL
- 重新執行登入命令

### 問題 3: Claude Code 顯示 unknown provider

**症狀**：
```
API Error: 400 {"error":{"message":"unknown provider for model claude-sonnet-4-5-20250929"}}
```

**解決方式**：
- 確認 `config.yaml` 中的 `ampcode.model-mappings` 設定正確
- 確認使用 `claude-cliproxy` 腳本（會自動設定 model 環境變數）
- 重啟 CLIProxyAPI: `docker restart cliproxyapi`

### 問題 4: 容器無法啟動

**症狀**：
```
docker ps | grep cliproxyapi
# 沒有輸出
```

**解決方式**：
```bash
# 查看詳細錯誤
docker logs cliproxyapi

# 常見原因：port 已被占用
# 檢查 port 8080 是否被占用
sudo netstat -tlnp | grep 8080

# 或修改 docker run 命令的 port mapping
```

### 問題 5: SSH Tunnel 無法建立

**症狀**：
OAuth 授權後沒有回應

**解決方式**：
- 確認 SSH tunnel 命令正確執行且保持連線
- 確認伺服器防火牆允許 port 51121
- 檢查 SSH 連線是否穩定

## 進階設定

### 自訂 Routing 策略

編輯 `~/cliproxyapi/config.yaml`：

```yaml
routing:
  strategy: "fill-first"  # 或 "round-robin"
```

- `round-robin`: 輪流使用各帳號（預設）
- `fill-first`: 優先用完第一個帳號才換下一個

### 啟用 Management UI

編輯 `~/cliproxyapi/config.yaml`：

```yaml
remote-management:
  allow-remote: false
  secret-key: "your-secret-key-here"
```

重啟後訪問：`http://127.0.0.1:8080/management.html`

### 日誌持久化

預設日誌已掛載到 `~/cliproxyapi/logs/`，會自動保存。

## 參考資源

- [CLIProxyAPI GitHub](https://github.com/router-for-me/CLIProxyAPI)
- [CLIProxyAPI 官方文檔](https://help.router-for.me/)
- [Claude Code 配置說明](https://help.router-for.me/cn/agent-client/claude-code)
- [Antigravity 配置說明](https://help.router-for.me/configuration/provider/antigravity)

## 更新日誌

- 2026-01-08: 初始版本，替換原 Antigravity-manager
