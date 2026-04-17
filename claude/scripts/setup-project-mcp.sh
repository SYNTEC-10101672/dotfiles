#!/bin/bash

# SYNTEC Claude Code MCP 專案設定腳本
# 使用方式: ./setup-project-mcp.sh [專案路徑]

PROJECT_DIR="${1:-$(pwd)}"
CLAUDE_DIR="$HOME/.claude"
MCP_CONFIG="$CLAUDE_DIR/.mcp.json"

# 檢查參數
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ 錯誤: 專案目錄不存在: $PROJECT_DIR"
    exit 1
fi

if [ ! -f "$MCP_CONFIG" ]; then
    echo "❌ 錯誤: MCP 設定檔不存在: $MCP_CONFIG"
    echo "請先確保 Claude Code 模板已正確安裝"
    exit 1
fi

# 切換到專案目錄
cd "$PROJECT_DIR" || exit 1

echo "🔧 正在為專案設定 MCP 連接..."
echo "📁 專案目錄: $PROJECT_DIR"

# 檢查是否已存在 .mcp.json
if [ -f ".mcp.json" ] || [ -L ".mcp.json" ]; then
    echo "⚠️  .mcp.json 已存在，是否要覆蓋? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ 取消設定"
        exit 0
    fi
    rm -f .mcp.json
fi

# 建立軟連結
if ln -s "$MCP_CONFIG" .mcp.json; then
    echo "✅ 成功建立 MCP 設定軟連結"
    echo "🔗 .mcp.json -> $MCP_CONFIG"
else
    echo "❌ 建立軟連結失敗，嘗試複製檔案..."
    if cp "$MCP_CONFIG" .mcp.json; then
        echo "✅ 成功複製 MCP 設定檔"
    else
        echo "❌ 複製失敗"
        exit 1
    fi
fi

# 檢查結果
if [ -f ".mcp.json" ]; then
    echo ""
    echo "🎉 MCP 設定完成！"
    echo "💡 現在可以在此專案中使用 Claude Code 的 MCP 功能"
    echo ""
    echo "🚀 建議接下來:"
    echo "   1. 啟動 MCP 伺服器: ~/.claude/scripts/start-mcp-server.sh"
    echo "   2. 開始使用 Claude Code 進行開發"
else
    echo "❌ 設定失敗"
    exit 1
fi