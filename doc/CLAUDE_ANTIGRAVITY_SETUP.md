# Claude Antigravity 使用說明

## 概述

這個專案提供兩種方式使用 Claude Code：

1. **`claude`** - 使用你原本的 Claude API key（官方 API）
2. **`claude-antigravity`** - 使用 Antigravity proxy（透過 Google 帳號授權的 AI 流量）

## 設定步驟

### 1. 配置環境變數

複製 `env.example` 到 `~/.env`：

```bash
cp ~/Projects/dotfiles/env.example ~/.env
```

編輯 `~/.env`，填入你的設定：

```bash
# Claude 官方 API key（選填，如果你不用原本的 claude 命令可以不填）
export ANTHROPIC_API_KEY="sk-ant-your_api_key_here"

# Antigravity proxy URL（必填）
export ANTIGRAVITY_BASE_URL="http://127.0.0.1:8045"
```

### 2. 部署 claude-antigravity 命令

```bash
cd ~/Projects/dotfiles
make scripts
```

這會將 `claude-antigravity` 部署到 `~/bin/`。

### 3. 重新載入環境變數

```bash
source ~/.bashrc
# 或
source ~/.zshrc
```

### 4. 驗證安裝

```bash
# 檢查 claude-antigravity 是否存在
which claude-antigravity

# 檢查環境變數
echo $ANTIGRAVITY_BASE_URL
```

## 使用方式

### 使用原本的 Claude API

```bash
claude "explain this code"
```

這會使用 `$ANTHROPIC_API_KEY` 呼叫官方 Anthropic API。

### 使用 Antigravity Proxy

```bash
claude-antigravity "explain this code"
```

這會透過 Antigravity proxy（`$ANTIGRAVITY_BASE_URL`）呼叫，使用你透過 Google OAuth 授權的帳號額度。

## 常見使用場景

### 1. 互動式對話

```bash
# 官方 API
claude

# Antigravity
claude-antigravity
```

### 2. 單次查詢

```bash
# 官方 API
claude "what is the meaning of life?"

# Antigravity
claude-antigravity "what is the meaning of life?"
```

### 3. 程式碼輔助

```bash
# 官方 API
claude "review this code" < main.rs

# Antigravity
claude-antigravity "review this code" < main.rs
```

### 4. 在專案中使用

```bash
# 進入專案目錄
cd ~/myproject

# 使用 Antigravity 分析專案
claude-antigravity "analyze this codebase"
```

## 架構說明

```
命令層:
┌─────────────────┐         ┌──────────────────────┐
│     claude      │         │  claude-antigravity  │
└────────┬────────┘         └──────────┬───────────┘
         │                              │
         │                              │
環境變數: │                              │
         │                              │
   ANTHROPIC_API_KEY          ANTIGRAVITY_BASE_URL
         │                              │
         │                              │
後端:     │                              │
         ▼                              ▼
┌─────────────────┐         ┌──────────────────────┐
│ Anthropic API   │         │ Antigravity Proxy    │
│ (官方服務)       │         │ (http://127.0.0.1:8045)│
└─────────────────┘         └──────────┬───────────┘
                                       │
                                       ▼
                            ┌──────────────────────┐
                            │  Google OAuth 帳號   │
                            │   (AI 流量額度)      │
                            └──────────────────────┘
```

## 故障排除

### 問題 1：claude-antigravity: command not found

**解決方式**：

```bash
# 確認 ~/bin 在 PATH 中
echo $PATH | grep -q "$HOME/bin" && echo "✓ ~/bin in PATH" || echo "✗ ~/bin not in PATH"

# 如果不在 PATH 中，檢查 ~/.bashrc 是否有載入
grep -q 'PATH.*bin' ~/.bashrc || echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 重新部署
cd ~/Projects/dotfiles
make scripts
```

### 問題 2：Connection refused

**症狀**：執行 `claude-antigravity` 時出錯

**檢查清單**：

1. Antigravity Docker 是否運行：
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

4. 重啟 Antigravity：
   ```bash
   docker restart antigravity
   ```

### 問題 3：環境變數未載入

**解決方式**：

```bash
# 確認 ~/.bashrc 有載入 ~/.env
grep -q '~/.env' ~/.bashrc

# 如果沒有，手動加入
echo 'if [ -f ~/.env ]; then source ~/.env; fi' >> ~/.bashrc
source ~/.bashrc
```

### 問題 4：想切換回官方 API

直接使用 `claude` 命令即可，不會受 `claude-antigravity` 影響。

## 進階配置

### 動態切換 Proxy URL

如果你有多個 Antigravity 實例，可以在執行時指定：

```bash
ANTIGRAVITY_BASE_URL="http://192.168.1.100:8045" claude-antigravity "hello"
```

### 建立別名

在 `~/.bashrc` 或 `~/.aliases` 中：

```bash
# 快速別名
alias cag='claude-antigravity'
alias c='claude'

# 使用
cag "hello world"
c "hello world"
```

### 檢查當前使用的 API

建立一個 helper function：

```bash
# 加到 ~/.bashrc
check-claude-api() {
    echo "claude command:"
    echo "  API Key: ${ANTHROPIC_API_KEY:0:10}..."
    echo ""
    echo "claude-antigravity command:"
    echo "  Proxy URL: ${ANTIGRAVITY_BASE_URL}"
}
```

使用：
```bash
check-claude-api
```

## 維護與更新

### 更新 claude-antigravity script

```bash
cd ~/Projects/dotfiles
git pull  # 如果有更新
make scripts
```

### 查看當前部署狀態

```bash
cd ~/Projects/dotfiles
make check
```

應該看到：
```
✓ ~/bin/claude-antigravity -> /home/s911336/Projects/dotfiles/scripts/claude-antigravity
```

### 移除 claude-antigravity

```bash
cd ~/Projects/dotfiles
make uninstall
```

## 相關文件

- [Antigravity 部署指南](~/antigravity-manager/DEPLOYMENT_GUIDE.md) - Antigravity Docker 部署說明
- [env.example](~/Projects/dotfiles/env.example) - 環境變數模板

## 總結

現在你有兩個獨立的命令：

- **`claude`** - 保持原樣，使用官方 API
- **`claude-antigravity`** - 新增的，使用 Antigravity proxy

兩者互不干擾，可以根據需求選擇使用。建議：
- 正式工作使用 `claude`（穩定可靠）
- 實驗或大量使用時用 `claude-antigravity`（節省成本）
