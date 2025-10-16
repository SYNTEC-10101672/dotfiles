#!/bin/bash

# SYNTEC MCP Server 啟動腳本
# 使用方式: ./start-mcp-server.sh [sse|streamable-http]

set -e

TRANSPORT=${1:-sse}
PORT=8001

# 載入 .env 檔案 (統一從 ~/.env 載入)
ENV_FILE=~/.env

if [ -f "$ENV_FILE" ]; then
    echo "載入環境變數檔案: $ENV_FILE"
    source "$ENV_FILE"
else
    echo "警告: 找不到 .env 檔案 ($ENV_FILE)"
    echo "請複製 ~/dotfiles/env.example 為 ~/.env 並填入你的帳號資訊"
fi

echo "啟動 SYNTEC Confluence/JIRA MCP Server..."
echo "傳輸方式: $TRANSPORT"
echo "連接埠: $PORT"

# 檢查環境變數
if [ -z "$SYNTEC_EMAIL" ]; then
    echo "錯誤: 請設定 SYNTEC_EMAIL 環境變數"
    echo "可以在 .env 檔案中設定或使用環境變數"
    echo "範例: SYNTEC_EMAIL=your.email@syntecclub.com.tw"
    exit 1
fi

if [ -z "$SYNTEC_API_TOKEN" ]; then
    echo "錯誤: 請設定 SYNTEC_API_TOKEN 環境變數"
    echo "可以在 .env 檔案中設定或使用環境變數"
    echo "API Token 請從 https://id.atlassian.com/manage-profile/security/api-tokens 產生"
    exit 1
fi

# 檢查 Docker 是否運行
if ! docker info > /dev/null 2>&1; then
    echo "錯誤: Docker 未運行，請先啟動 Docker"
    exit 1
fi

# 啟動 MCP Server
echo "正在啟動 Docker 容器..."
echo "Confluence: https://syntecclub.atlassian.net/wiki"
echo "JIRA: https://syntecclub.atlassian.net"
echo "使用者: $SYNTEC_EMAIL"

docker run --rm -i -p ${PORT}:8000 \
    -e CONFLUENCE_URL="https://syntecclub.atlassian.net/wiki" \
    -e CONFLUENCE_USERNAME="$SYNTEC_EMAIL" \
    -e CONFLUENCE_API_TOKEN="$SYNTEC_API_TOKEN" \
    -e JIRA_URL="https://syntecclub.atlassian.net" \
    -e JIRA_USERNAME="$SYNTEC_EMAIL" \
    -e JIRA_API_TOKEN="$SYNTEC_API_TOKEN" \
    ghcr.io/sooperset/mcp-atlassian:latest \
    --transport $TRANSPORT --port 8000 -vv

echo "MCP Server 已停止"