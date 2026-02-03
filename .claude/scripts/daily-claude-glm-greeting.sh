#!/bin/bash
# ============================================
# Claude-GLM Daily Greeting Script
# ============================================
# 每日自動向 Claude-GLM (Z.AI GLM API) 問好並取得回應
# 用於 crontab 排程執行

# 確保環境變數正確設定（cron 環境）
export HOME="${HOME:-/home/10101672}"
export PATH="$HOME/.nvm/versions/node/v22.17.1/bin:$PATH"
export NODE_PATH="$HOME/.nvm/versions/node/v22.17.1/lib/node_modules"

# 設定
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/daily-glm-greeting.log"
RESPONSE_FILE="$LOG_DIR/glm-greeting-response-$(date '+%Y%m%d-%H%M%S').txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
WORK_DIR="$HOME/.dotfiles"

# 建立日誌目錄
mkdir -p "$LOG_DIR"

# 記錄執行時間
echo "[$TIMESTAMP] Daily GLM greeting started" >> "$LOG_FILE"

# 檢查 claude-glm 是否安裝
if ! command -v claude-glm &> /dev/null; then
    echo "[$TIMESTAMP] ERROR: claude-glm not found in PATH" >> "$LOG_FILE"
    exit 1
fi

# 取得 claude-glm 版本
GLM_VERSION=$(claude-glm --version 2>&1 || echo "unknown")
echo "[$TIMESTAMP] claude-glm version: $GLM_VERSION" >> "$LOG_FILE"

# 切換到工作目錄
cd "$WORK_DIR" || {
    echo "[$TIMESTAMP] ERROR: Cannot change to directory $WORK_DIR" >> "$LOG_FILE"
    exit 1
}

# 準備問候訊息（根據時間選擇不同的問候語）
HOUR=$(date '+%H')
if [ "$HOUR" -lt 12 ]; then
    GREETING="早安！今天是個美好的一天，有什麼可以幫助你的嗎？"
elif [ "$HOUR" -lt 18 ]; then
    GREETING="午安！希望你今天工作順利，需要什麼協助嗎？"
else
    GREETING="晚安！辛苦了一天，有什麼我可以幫忙的嗎？"
fi

echo "[$TIMESTAMP] Sending greeting to claude-glm..." >> "$LOG_FILE"
echo "[$TIMESTAMP] Message: $GREETING" >> "$LOG_FILE"

# 呼叫 claude-glm 並記錄回應
# 使用 --print 選項進行非互動式輸出
# 使用 timeout 避免卡住，最多等待 60 秒
RESPONSE=$(timeout 60s claude-glm --print "$GREETING" 2>&1)
GLM_EXIT_CODE=$?

if [ $GLM_EXIT_CODE -eq 0 ]; then
    echo "[$TIMESTAMP] claude-glm responded successfully" >> "$LOG_FILE"

    # 儲存完整回應到檔案
    echo "=== Claude-GLM Daily Greeting Response ===" > "$RESPONSE_FILE"
    echo "Time: $TIMESTAMP" >> "$RESPONSE_FILE"
    echo "Greeting: $GREETING" >> "$RESPONSE_FILE"
    echo "=========================================" >> "$RESPONSE_FILE"
    echo "" >> "$RESPONSE_FILE"
    echo "$RESPONSE" >> "$RESPONSE_FILE"

    # 記錄回應摘要（前3行）
    echo "[$TIMESTAMP] Response preview:" >> "$LOG_FILE"
    echo "$RESPONSE" | head -3 >> "$LOG_FILE"
    echo "[$TIMESTAMP] Full response saved to: $RESPONSE_FILE" >> "$LOG_FILE"

elif [ $GLM_EXIT_CODE -eq 124 ]; then
    echo "[$TIMESTAMP] ERROR: claude-glm timeout (60s)" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] ERROR: claude-glm failed with exit code $GLM_EXIT_CODE" >> "$LOG_FILE"
    echo "[$TIMESTAMP] Error output: $RESPONSE" >> "$LOG_FILE"
fi

# 檢查 MCP server 狀態（如果有設定）
if [ -f "$HOME/.claude/scripts/check-mcp-connection.sh" ]; then
    MCP_STATUS=$("$HOME/.claude/scripts/check-mcp-connection.sh" 2>&1 | head -1)
    echo "[$TIMESTAMP] MCP Status: $MCP_STATUS" >> "$LOG_FILE"
fi

# 清理舊的回應檔案（保留最近 7 天）
find "$LOG_DIR" -name "glm-greeting-response-*.txt" -type f -mtime +7 -delete 2>/dev/null

# 清理舊日誌（保留最近 30 天）
find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null

echo "[$TIMESTAMP] GLM greeting completed" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
exit 0
