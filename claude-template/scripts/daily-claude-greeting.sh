#!/bin/bash

# Daily Claude Greeting Script
# 每天早上5點自動在當前工作目錄開啟 Claude 並說 hi

# 設定日誌檔案
LOG_FILE="/home/10101672/.claude/logs/daily-claude-greeting.log"

# 確保日誌目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# 記錄執行時間
echo "$(date '+%Y-%m-%d %H:%M:%S') - Daily Claude greeting started" >> "$LOG_FILE"

# 取得當前工作目錄 (使用環境變數或預設目錄)
WORK_DIR="${CLAUDE_WORK_DIR:-$(pwd)}"

# 如果 CLAUDE_WORK_DIR 未設定，嘗試取得使用者的主要工作目錄
if [ -z "$CLAUDE_WORK_DIR" ]; then
    # 檢查常見的工作目錄
    if [ -d "/home/10101672/project" ]; then
        # 取得最近修改的專案目錄
        WORK_DIR=$(find /home/10101672/project -maxdepth 1 -type d -name "*" | head -1)
    elif [ -d "/home/10101672/workspace-imx8-master" ]; then
        WORK_DIR="/home/10101672/workspace-imx8-master"
    else
        WORK_DIR="/home/10101672"
    fi
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Working directory: $WORK_DIR" >> "$LOG_FILE"

# 切換到工作目錄
cd "$WORK_DIR" || {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Cannot change to directory $WORK_DIR" >> "$LOG_FILE"
    exit 1
}

# Claude Code 完整路徑
CLAUDE_CMD="/home/10101672/.nvm/versions/node/v22.17.1/bin/claude"

# 檢查 Claude Code 是否可用
if [ ! -x "$CLAUDE_CMD" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR: Claude command not found at $CLAUDE_CMD" >> "$LOG_FILE"
    exit 1
fi

# 設定完整的 Node.js 環境 (對於 cron job 很重要)
export TERM=xterm-256color
export DISPLAY=:0
export NVM_DIR="/home/10101672/.nvm"
export PATH="/home/10101672/.nvm/versions/node/v22.17.1/bin:$PATH"
export NODE_PATH="/home/10101672/.nvm/versions/node/v22.17.1/lib/node_modules"

# 載入 NVM 環境
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 啟動 Claude 並發送問候訊息
# 使用 --print 選項進行非互動式執行
timeout 30s "$CLAUDE_CMD" --print "hi" >> "$LOG_FILE" 2>&1

# 檢查執行結果
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Claude greeting sent successfully" >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Claude greeting failed with exit code $?" >> "$LOG_FILE"
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Daily Claude greeting completed" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"