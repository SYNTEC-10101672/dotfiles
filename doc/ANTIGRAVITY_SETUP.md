# Antigravity 使用說明

## 概述

**Antigravity** 是 Google 提供的 AI agent IDE 軟體，讓使用者透過 Google 帳號使用 Claude 和 Gemini 等 AI 模型。

**Antigravity-manager** 是一個帳號管理工具，可以管理多個 Antigravity 帳號，並提供統一的 API proxy 服務，實現帳號輪換和 quota 管理。

本專案提供了兩個 CLI wrapper 工具來使用 Antigravity-manager：

- **`claude-antigravity`** - 透過 Antigravity-manager 使用 Claude Code
- **`gemini-antigravity`** - 透過 Antigravity-manager 使用 Gemini 模型

## 架構說明

```
命令層:
┌──────────────────────┐    ┌──────────────────────┐
│  claude-antigravity  │    │  gemini-antigravity  │
└──────────┬───────────┘    └──────────┬───────────┘
           │                           │
           │ Claude API format         │ Gemini models
           │                           │
           └──────────┬────────────────┘
                      │
                      ▼
           ┌────────────────────────────┐
           │  Antigravity-manager       │
           │  (127.0.0.1:8045)          │
           │  - 帳號輪換                 │
           │  - Quota 管理               │
           │  - 智能路由                 │
           └──────────┬─────────────────┘
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ Google  │ │ Google  │ │ Google  │
    │ 帳號 1  │ │ 帳號 2  │ │ 帳號 3  │
    │(Antigr.)│ │(Antigr.)│ │(Antigr.)│
    └─────────┘ └─────────┘ └─────────┘
          │           │           │
          └───────────┼───────────┘
                      ▼
           ┌──────────────────────┐
           │  Claude/Gemini API   │
           │  (透過 Antigravity)  │
           └──────────────────────┘
```

## 部署 Antigravity-manager

### 前提條件

在使用本文件中的工具之前，你需要先部署 Antigravity-manager。

### Server 端設置

#### 1. 下載 Docker Image

```bash
# 建立工作目錄
mkdir -p ~/antigravity-manager
cd ~/antigravity-manager

# 下載 Docker image（約 40MB）
wget https://github.com/jxpony/Antigravity-Manager-amd64-Docker/releases/download/v1/antigravity-manager.tar
```

#### 2. 載入 Docker Image

```bash
# 載入 image
docker load -i antigravity-manager.tar

# 驗證 image 已載入
docker images | grep antigravity
```

應該看到：
```
antigravity-manager   latest   ...
```

#### 3. 啟動容器

```bash
docker run -d \
  --name antigravity \
  -p 3000:3000 \
  -p 8045:8045 \
  -v $(pwd)/data:/app/data \
  -e PROXY_AUTO_START=true \
  -e ALLOW_LAN_ACCESS=true \
  antigravity-manager:latest
```

**參數說明**：
- `-p 3000:3000`：Web 管理界面端口
- `-p 8045:8045`：API Proxy 端口（給 Claude Code 使用）
- `-v $(pwd)/data:/app/data`：持久化授權資料
- `-e PROXY_AUTO_START=true`：自動啟動 proxy 服務
- `-e ALLOW_LAN_ACCESS=true`：允許局域網訪問

#### 4. 驗證運行狀態

```bash
# 檢查容器狀態
docker ps | grep antigravity

# 查看日誌
docker logs antigravity
```

應該看到：
```
INFO Server running on http://0.0.0.0:3000
```

### 本機端設置（OAuth 授權用）

#### 建立 SSH Port Forwarding

在**本機終端**執行：

```bash
ssh -L 3000:localhost:3000 -L 8045:localhost:8045 your-username@your-server-ip
```

**替換以下內容**：
- `your-username`：你的 server 使用者名稱
- `your-server-ip`：你的 server IP 位址或域名

**範例**：
```bash
ssh -L 3000:localhost:3000 -L 8045:localhost:8045 user@192.168.50.156
```

**重要提醒**：
- 保持這個終端視窗**不要關閉**
- SSH 連線成功後會進入 server shell，這是正常的

### Google OAuth 授權

#### 1. 開啟管理界面

在**本機瀏覽器**開啟：

```
http://localhost:3000
```

#### 2. 新增帳號

1. 點擊「添加帳號」或「Add Account」
2. 選擇 AI 提供商（Anthropic/Claude）
3. 點擊「OAuth 授權」按鈕

#### 3. 完成 Google 授權

1. 瀏覽器會跳轉到 Google OAuth 頁面
2. 選擇你的 Google 帳號
3. 點擊「登入」或「允許」
4. 授權完成後會自動重定向回 Antigravity 管理界面

**注意**：redirect URI 必須是 `http://127.0.0.1:3000/api/oauth/callback`

#### 4. 驗證授權成功

在管理界面中應該看到：
- 帳號狀態：已授權 / Authorized
- 可用額度資訊

### 容器管理指令

```bash
# 停止容器
docker stop antigravity

# 啟動容器
docker start antigravity

# 重啟容器
docker restart antigravity

# 查看日誌
docker logs antigravity -f

# 移除容器（會保留 data 目錄）
docker stop antigravity && docker rm antigravity
```

### 快速檢查

如果你已經部署了 Antigravity-manager，可以快速檢查：

```bash
# 檢查容器是否運行
docker ps | grep antigravity

# 應該看到：
# antigravity    Up X hours    0.0.0.0:8045->8045/tcp
```

如果容器正在運行，可以繼續閱讀下面的「統一設定步驟」。

## 統一設定步驟

### 1. 確認 Antigravity-manager 正在運行

```bash
# 檢查 Antigravity-manager 容器
docker ps | grep antigravity

# 應該看到類似輸出：
# antigravity    Up X hours    0.0.0.0:8045->8045/tcp
```

如果沒有運行，請參考 Antigravity-manager 部署文件啟動服務。

### 2. 配置環境變數（選填）

在 `~/.env` 中設定（如果使用非預設 port）：

```bash
# Antigravity-manager proxy URL（預設：http://127.0.0.1:8045）
export ANTIGRAVITY_BASE_URL="http://127.0.0.1:8045"

# Claude 官方 API key（選填，如果你不用原本的 claude 命令可以不填）
export ANTHROPIC_API_KEY="sk-ant-your_api_key_here"
```

如果使用預設 port 8045，可以省略 `ANTIGRAVITY_BASE_URL`。

### 3. 安裝工具

```bash
cd ~/Projects/dotfiles
make scripts
```

這會安裝以下工具到 `~/bin/`：
- `claude-antigravity`
- `gemini-antigravity`
- `antigravity-monitor`

### 4. 重新載入環境（如果有修改 ~/.env）

```bash
source ~/.bashrc
```

### 5. 驗證安裝

```bash
# 檢查工具是否存在
which claude-antigravity
which gemini-antigravity
which antigravity-monitor

# 查看說明
claude-antigravity --help
gemini-antigravity --help

# 測試連接
gemini-antigravity -m gemini-2.5-flash "hello"
```

## Claude Antigravity

### 概述

`claude-antigravity` 是 Claude Code 的 wrapper，讓你透過 Antigravity-manager 使用 Claude 模型，而不是直接使用官方 API key。

Antigravity-manager 會管理多個 Google 帳號的 Antigravity sessions，並自動進行帳號輪換和 quota 管理。

### 與原生 claude 的差異

| 特性 | `claude` | `claude-antigravity` |
|------|----------|---------------------|
| 後端 | Anthropic API（官方）| Antigravity-manager |
| 需要 API key | ✓ | ✗ |
| 流量來源 | 官方 API 額度 | Google 帳號的 Antigravity |
| 設定 | ANTHROPIC_API_KEY | ANTIGRAVITY_BASE_URL |
| 帳號管理 | 單一帳號 | 多帳號輪換 |

### 使用方式

```bash
# 基本使用（與 claude 命令相同）
claude-antigravity "explain this code"

# 互動模式
claude-antigravity

# 在專案中使用
cd ~/myproject
claude-antigravity "analyze this codebase"
```

### 使用場景

```bash
# 程式碼解釋
claude-antigravity "explain this function" < script.py

# 程式碼審查
claude-antigravity "review this code for security issues"

# 在專案目錄中使用
cd ~/Projects/myapp
claude-antigravity
```

## Gemini Antigravity

### 概述

`gemini-antigravity` 是 Gemini CLI wrapper，透過 Antigravity-manager 使用多種 Gemini 模型。

Antigravity-manager 會自動管理多個 Google 帳號，並根據 quota 狀況進行智能路由。

### 基本語法

```bash
gemini-antigravity [OPTIONS] "PROMPT"
```

### 選項

- `-m, --model MODEL` - 指定 Gemini 模型（預設：gemini-2.5-pro）
- `-i, --interactive` - 啟動互動模式
- `-h, --help` - 顯示說明

### 可用模型

| 模型名稱 | 說明 | 建議使用場景 |
|---------|------|-------------|
| `gemini-2.5-pro` | 最強模型（預設）| 複雜任務，但注意 quota |
| `gemini-2.5-flash` | 快速高效 | 日常對話、快速查詢 ⭐ |
| `gemini-2.5-flash-thinking` | 帶思考鏈 | 需要推理過程的任務 |
| `gemini-2.5-flash-lite` | 輕量版 | 簡單任務、大量請求 |
| `gemini-3-flash` | 最快速 | 即時回應需求 ⭐ |
| `gemini-3-pro-high` | 高品質 | 重要任務、品質優先 |
| `gemini-3-pro-low` | 低配版 | 測試、實驗用途 |
| `gemini-3-pro-image` | 圖像處理 | 圖像分析任務 |

⭐ 推薦日常使用，速度快且 quota 充足

### 使用範例

#### 單次查詢

```bash
# 使用預設模型
gemini-antigravity "解釋什麼是量子計算"

# 指定模型（推薦使用 flash 系列）
gemini-antigravity -m gemini-2.5-flash "1+1等於多少？"

# 使用最快的模型
gemini-antigravity -m gemini-3-flash "Say hello in one word"
```

#### 互動模式

```bash
# 使用預設模型啟動
gemini-antigravity -i

# 使用指定模型啟動（推薦）
gemini-antigravity -m gemini-2.5-flash -i
```

互動模式操作：
- 直接輸入問題對話
- 輸入 `exit` 或 `quit` 離開
- 按 `Ctrl+C` 取消當前操作

#### 實用場景

```bash
# 程式碼解釋
gemini-antigravity -m gemini-3-pro-high "解釋這段 Python 程式碼：
def fib(n):
    if n <= 1: return n
    return fib(n-1) + fib(n-2)"

# 翻譯
gemini-antigravity -m gemini-2.5-flash "將以下英文翻譯成繁體中文：Hello, World!"

# 快速查詢
gemini-antigravity -m gemini-3-flash "React hooks 是什麼？"

# 文字摘要
gemini-antigravity -m gemini-2.5-flash "總結以下文章：..."
```

## 監控工具

### antigravity-monitor

監控 Antigravity-manager 的狀態、查看可用模型和帳號資訊。

#### 使用方式

```bash
# 查看可用模型和 quota
antigravity-monitor quota

# 查看即時日誌
antigravity-monitor logs

# 查看使用統計
antigravity-monitor stats

# 查看帳號資訊
antigravity-monitor accounts
```

#### 輸出範例

```bash
$ antigravity-monitor quota
=== Available Models ===

- gemini-3-pro-high
- gemini-3-pro-image
- gemini-3-flash
- gemini-2.5-pro
- gemini-2.5-flash
- claude-sonnet-4-5
- ...
```

## 故障排除

### 問題 1：command not found

**症狀**：執行 `claude-antigravity` 或 `gemini-antigravity` 時找不到命令

**解決方式**：

```bash
# 確認 ~/bin 在 PATH 中
echo $PATH | grep -q "$HOME/bin" && echo "✓ ~/bin in PATH" || echo "✗ ~/bin not in PATH"

# 如果不在，加入到 ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 重新安裝
cd ~/Projects/dotfiles
make scripts
```

### 問題 2：Connection refused

**症狀**：執行時出現連接錯誤

**檢查清單**：

1. Antigravity-manager 是否運行：
   ```bash
   docker ps | grep antigravity
   ```

2. Port 8045 是否監聽：
   ```bash
   ss -tlnp | grep 8045
   ```

3. 環境變數是否正確：
   ```bash
   echo $ANTIGRAVITY_BASE_URL
   ```

4. 測試 Antigravity-manager API：
   ```bash
   curl -s http://127.0.0.1:8045/health
   ```

5. 重啟 Antigravity-manager：
   ```bash
   docker restart antigravity
   ```

### 問題 3：Quota exhausted (gemini-antigravity)

**症狀**：回應錯誤 `HTTP 429 Too Many Requests`

**解決方式**：

1. 切換到其他模型：
   ```bash
   # gemini-2.5-pro quota 用完時，改用 flash
   gemini-antigravity -m gemini-2.5-flash "your prompt"
   ```

2. 檢查 quota 狀態：
   ```bash
   antigravity-monitor quota
   ```

3. 等待 quota 重置（通常幾小時後）

### 問題 4：環境變數未載入

**解決方式**：

```bash
# 確認 ~/.bashrc 有載入 ~/.env
grep -q '~/.env' ~/.bashrc

# 如果沒有，手動加入
echo 'if [ -f ~/.env ]; then source ~/.env; fi' >> ~/.bashrc
source ~/.bashrc
```

## 進階配置

### 使用自訂 Antigravity-manager URL

```bash
# 一次性使用
ANTIGRAVITY_BASE_URL="http://192.168.1.100:8045" claude-antigravity "hello"
ANTIGRAVITY_BASE_URL="http://192.168.1.100:8045" gemini-antigravity "hello"

# 永久設定（在 ~/.env）
export ANTIGRAVITY_BASE_URL="http://192.168.1.100:8045"
```

### 建立便捷別名

在 `~/.bashrc` 或 `~/.aliases` 中：

```bash
# Claude 別名
alias cag='claude-antigravity'

# Gemini 別名
alias gag='gemini-antigravity'
alias gagf='gemini-antigravity -m gemini-2.5-flash'
alias gagl='gemini-antigravity -m gemini-3-flash'  # lightning fast
alias gagi='gemini-antigravity -m gemini-2.5-flash -i'

# 監控別名
alias agm='antigravity-monitor'

# 使用範例
cag "explain this code"
gagf "快速查詢"
gagi  # 啟動 Gemini 互動模式
agm quota
```

### 整合到工作流程

```bash
# 建立函數：快速查詢 Gemini
ask() {
    gemini-antigravity -m gemini-2.5-flash "$*"
}

# 建立函數：深入分析
analyze() {
    gemini-antigravity -m gemini-3-pro-high "$*"
}

# 建立函數：程式碼審查
review() {
    claude-antigravity "請審查以下程式碼：$*"
}

# 使用
ask "React 的 useEffect 怎麼用？"
analyze "Explain quantum computing in detail"
review "檢查這段 SQL 的安全性"
```

### 檢查當前使用的 API

建立一個 helper function：

```bash
# 加到 ~/.bashrc
check-antigravity() {
    echo "=== Antigravity Configuration ==="
    echo "Proxy URL: ${ANTIGRAVITY_BASE_URL:-http://127.0.0.1:8045 (default)}"
    echo ""
    echo "=== Antigravity Status ==="
    docker ps | grep antigravity || echo "⚠ Antigravity not running"
    echo ""
    echo "=== Available Commands ==="
    echo "  claude-antigravity  - Claude Code via Antigravity"
    echo "  gemini-antigravity  - Gemini models via Antigravity"
    echo "  antigravity-monitor - Monitor Antigravity status"
}
```

使用：
```bash
check-antigravity
```

## 工具比較與使用建議

### Claude vs Gemini

| 用途 | 推薦工具 | 理由 |
|------|---------|------|
| 程式開發、程式碼輔助 | `claude-antigravity` | Claude 對程式碼理解更好 |
| 快速查詢、通用對話 | `gemini-antigravity -m gemini-2.5-flash` | Gemini flash 速度快 |
| 程式碼審查 | `claude-antigravity` | Claude 審查更仔細 |
| 翻譯、文字處理 | `gemini-antigravity -m gemini-2.5-flash` | Gemini 速度快且準確 |
| 複雜推理任務 | `gemini-antigravity -m gemini-3-pro-high` | 高品質模型 |
| 架構設計 | `claude-antigravity` | Claude 系統思考能力強 |

### 模型選擇建議（Gemini）

**日常使用**：
- `gemini-2.5-flash` - 平衡速度與品質 ⭐
- `gemini-3-flash` - 追求極致速度 ⭐

**重要任務**：
- `gemini-3-pro-high` - 品質優先
- `gemini-2.5-pro` - 最強模型（注意 quota）

**實驗測試**：
- `gemini-3-pro-low` - 測試用途
- `gemini-2.5-flash-lite` - 輕量測試

## 最佳實踐

### 1. 根據任務選擇工具

- **寫程式、改 bug** → `claude-antigravity`
- **快速查詢** → `gemini-antigravity -m gemini-3-flash`
- **學習探索** → `gemini-antigravity -i`（互動模式）
- **程式碼審查** → `claude-antigravity`

### 2. 監控 Quota 使用

```bash
# 定期檢查可用模型
antigravity-monitor quota

# 查看最近的請求
antigravity-monitor stats

# 查看即時日誌
antigravity-monitor logs
```

### 3. 使用別名提高效率

建立簡短的別名，減少輸入時間（見「進階配置」章節）。

### 4. Gemini 互動模式用於連續對話

避免重複啟動命令，提高對話效率：

```bash
gemini-antigravity -m gemini-2.5-flash -i
```

### 5. Claude 用於程式開發主力

在開發環境中，使用 `claude-antigravity` 作為主要的程式碼助手：

```bash
cd ~/Projects/myapp
claude-antigravity
```

## 維護與更新

### 更新工具

```bash
cd ~/Projects/dotfiles
git pull
make scripts
```

### 查看安裝狀態

```bash
cd ~/Projects/dotfiles
make check
```

應該看到：
```
✓ ~/bin/claude-antigravity -> /home/user/Projects/dotfiles/scripts/claude-antigravity
✓ ~/bin/gemini-antigravity -> /home/user/Projects/dotfiles/scripts/gemini-antigravity
✓ ~/bin/antigravity-monitor -> /home/user/Projects/dotfiles/scripts/antigravity-monitor
```

### 移除工具

```bash
cd ~/Projects/dotfiles
make uninstall
```

## 總結

本專案提供了完整的 Antigravity-manager 整合，讓你可以：

- **統一管理**：透過 Antigravity-manager 使用多個 Google 帳號的 Antigravity
- **自動輪換**：Antigravity-manager 自動進行帳號輪換和 quota 管理
- **靈活選擇**：根據任務選擇 Claude 或 Gemini 模型
- **便捷監控**：隨時查看 quota 和服務狀態
- **高效工作**：整合到日常開發流程

**推薦工作流程**：

1. **程式開發** → `claude-antigravity`
2. **快速查詢** → `gemini-antigravity -m gemini-2.5-flash`
3. **學習探索** → `gemini-antigravity -i`
4. **監控狀態** → `antigravity-monitor quota`

兩個工具搭配使用，可以滿足大部分 AI 輔助需求。
