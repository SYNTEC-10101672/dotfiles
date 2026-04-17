#!/bin/bash

# 檢查 SYNTEC MCP Server 連線狀態

PORT=8001

echo "檢查 MCP Server 連線狀態..."

# 檢查 SSE 端點
echo "測試 SSE 連線: http://127.0.0.1:$PORT/sse"
if curl -s -f "http://127.0.0.1:$PORT/sse" > /dev/null; then
    echo "✓ SSE 端點可用"
    SSE_AVAILABLE=true
else
    echo "✗ SSE 端點無法連線"
    SSE_AVAILABLE=false
fi

# 檢查 MCP 端點
echo "測試 MCP 連線: http://127.0.0.1:$PORT/mcp/"
if curl -s -f "http://127.0.0.1:$PORT/mcp/" > /dev/null; then
    echo "✓ MCP 端點可用"
    MCP_AVAILABLE=true
else
    echo "✗ MCP 端點無法連線"
    MCP_AVAILABLE=false
fi

# 總結
if [ "$SSE_AVAILABLE" = true ] || [ "$MCP_AVAILABLE" = true ]; then
    echo ""
    echo "🟢 MCP Server 運行中"
    if [ "$SSE_AVAILABLE" = true ]; then
        echo "   SSE URL: http://127.0.0.1:$PORT/sse"
    fi
    if [ "$MCP_AVAILABLE" = true ]; then
        echo "   MCP URL: http://127.0.0.1:$PORT/mcp/"
    fi
else
    echo ""
    echo "🔴 MCP Server 未運行"
    echo "請執行 ./start-mcp-server.sh 啟動服務"
    exit 1
fi