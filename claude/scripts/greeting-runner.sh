#!/bin/bash
# ============================================
# Shared greeting runner for Claude CLI tools
# ============================================
# Usage: greeting-runner.sh <cli-command> <log-prefix> <display-name>
# Example: greeting-runner.sh claude greeting "Claude Code"
#          greeting-runner.sh claude-glm glm-greeting "claude-glm"

CLI_COMMAND="${1:?Missing CLI command}"
LOG_PREFIX="${2:?Missing log prefix}"
DISPLAY_NAME="${3:?Missing display name}"

# Resolve HOME dynamically for cron environments
export HOME="${HOME:-$(getent passwd "$(whoami)" | cut -d: -f6)}"
export PATH="$HOME/bin:$HOME/.nvm/versions/node/v22.17.1/bin:$HOME/.local/bin:$PATH"

# Config
LOG_DIR="$HOME/.claude/logs"
WORK_DIR="$HOME/.claude/workspace"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATESTAMP=$(date '+%Y%m%d-%H%M%S')
HOUR=$(date '+%H')
LOG_FILE="$LOG_DIR/daily-${LOG_PREFIX}.log"
RESPONSE_FILE="$LOG_DIR/${LOG_PREFIX}-response-${DATESTAMP}.txt"

# Initialize directories
mkdir -p "$LOG_DIR" "$WORK_DIR"

echo "[$TIMESTAMP] Daily ${DISPLAY_NAME} greeting started" >> "$LOG_FILE"

# Check CLI is available
if ! command -v "$CLI_COMMAND" &> /dev/null; then
    echo "[$TIMESTAMP] ERROR: $CLI_COMMAND not found in PATH" >> "$LOG_FILE"
    exit 1
fi

VERSION=$("$CLI_COMMAND" --version 2>&1 || echo "unknown")
echo "[$TIMESTAMP] $DISPLAY_NAME version: $VERSION" >> "$LOG_FILE"

# Change to work directory
cd "$WORK_DIR" || {
    echo "[$TIMESTAMP] ERROR: Cannot change to directory $WORK_DIR" >> "$LOG_FILE"
    exit 1
}

# Select greeting based on time of day
if [ "$HOUR" -lt 12 ]; then
    GREETING="早安！今天是個美好的一天，有什麼可以幫助你的嗎？"
elif [ "$HOUR" -lt 18 ]; then
    GREETING="午安！希望你今天工作順利，需要什麼協助嗎？"
else
    GREETING="晚安！辛苦了一天，有什麼我可以幫忙的嗎？"
fi

echo "[$TIMESTAMP] Sending greeting to $DISPLAY_NAME..." >> "$LOG_FILE"
echo "[$TIMESTAMP] Message: $GREETING" >> "$LOG_FILE"

# Call CLI with 60s timeout
RESPONSE=$(timeout 60s "$CLI_COMMAND" --print "$GREETING" 2>&1)
EXIT_CODE=$?

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "[$TIMESTAMP] $DISPLAY_NAME responded successfully" >> "$LOG_FILE"

    {
        echo "=== $DISPLAY_NAME Daily Greeting Response ==="
        echo "Time: $TIMESTAMP"
        echo "Greeting: $GREETING"
        echo "==========================================="
        echo ""
        echo "$RESPONSE"
    } > "$RESPONSE_FILE"

    echo "[$TIMESTAMP] Response preview:" >> "$LOG_FILE"
    echo "$RESPONSE" | head -3 >> "$LOG_FILE"
    echo "[$TIMESTAMP] Full response saved to: $RESPONSE_FILE" >> "$LOG_FILE"

elif [ "$EXIT_CODE" -eq 124 ]; then
    echo "[$TIMESTAMP] ERROR: $DISPLAY_NAME timeout (60s)" >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] ERROR: $DISPLAY_NAME failed with exit code $EXIT_CODE" >> "$LOG_FILE"
    echo "[$TIMESTAMP] Error output: $RESPONSE" >> "$LOG_FILE"
fi

# Check MCP server status if script exists
MCP_CHECK="$HOME/.claude/scripts/check-mcp-connection.sh"
if [ -x "$MCP_CHECK" ]; then
    MCP_STATUS=$("$MCP_CHECK" 2>&1 | head -1)
    echo "[$TIMESTAMP] MCP Status: $MCP_STATUS" >> "$LOG_FILE"
fi

# Cleanup old response files (keep 7 days) and logs (keep 30 days)
find "$LOG_DIR" -name "${LOG_PREFIX}-response-*.txt" -type f -mtime +7 -delete 2>/dev/null
find "$LOG_DIR" -name "*.log" -type f -mtime +30 -delete 2>/dev/null

echo "[$TIMESTAMP] Greeting completed" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
