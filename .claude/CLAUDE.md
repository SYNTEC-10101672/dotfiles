# Claude Code Template for SYNTEC Embedded Development

這是 SYNTEC 嵌入式開發專案的統一 Claude Code 模板，包含：
- 自動專案類型偵測
- Confluence/JIRA MCP 整合
- 硬體平台特定工作流程

---

## 模板載入系統

### 當前專案
**目錄**: {{ cwd | basename }}

### 人設系統
@./personas/default.md

### 通用模板
@./project-templates/allproject-template.md

### 專案特定模板
<!-- 根據專案類型自動載入對應模板 -->
{% if cwd | basename == "appkernel" %}
@./project-templates/appkernel-template.md
{% elif cwd | basename | startswith("workspace-imx8") %}
@./project-templates/workspace-imx8-template.md
{% elif cwd | basename | startswith("workspace-am625") %}
@./project-templates/workspace-am625-template.md
{% endif %}

### 自動偵測規則
- `appkernel` → AppKernel 專案模板
- `workspace-imx8-*` → IMX8 工作空間模板
- `workspace-am625-*` → AM625 工作空間模板

---

## MCP 工具整合 (學習模式)

本模板已整合多個 MCP server，主要用於學習和認識開發環境：

### SYNTEC Confluence/JIRA MCP
- Confluence 文件搜尋和學習
- JIRA 議題搜尋和分析
- 專案知識庫探索

### Notion MCP
- Notion 頁面和資料庫存取
- 個人知識庫管理
- 專案文件整理

### 環境變數設定

```bash
# 1. 複製範例檔案
cd .claude
cp .env.example .env

# 2. 編輯 .env 檔案，填入你的實際帳號資訊
nano .env
```

.env 檔案內容範例：
```
# SYNTEC Confluence/JIRA
SYNTEC_EMAIL=your.email@syntecclub.com.tw
SYNTEC_API_TOKEN=your_api_token_here

# Notion
NOTION_TOKEN=ntn_your_token_here
```

### 啟動 MCP Server

#### SYNTEC Confluence/JIRA (需要 Docker)
```bash
./scripts/start-mcp-server.sh
```

檢查連線狀態：
```bash
./scripts/check-mcp-connection.sh
```

#### Notion MCP (自動啟動)
Notion MCP 會在 Claude Code 啟動時自動透過 npx 執行，無需手動啟動。

## 使用說明

### 設定步驟
1. 確保環境準備完成：
   - Docker 已安裝並運行（SYNTEC MCP 需要）
   - Node.js 已安裝（Notion MCP 需要）
2. 設定環境變數（參考上方說明）
3. 啟動所需的 MCP server

### MCP 功能使用

#### SYNTEC Confluence/JIRA
當 SYNTEC MCP server 運行時，你可以直接要求我：
- 搜尋並學習 Confluence 技術文件
- 分析 JIRA 議題了解專案狀況
- 探索專案的架構和開發規範
- 學習團隊的工作流程和最佳實務

#### Notion
當 Notion token 設定完成後，你可以：
- 存取 Notion 頁面和資料庫
- 搜尋個人知識庫內容
- 整理和管理專案文件
- 同步開發筆記和文件

### 人設切換指令

可以使用以下指令切換不同的專業人設：

```
# 切換為除錯專家
/persona debugger

# 切換為系統架構師
/persona architect

# 切換為程式碼審查員
/persona reviewer

# 切換為測試專家
/persona tester

# 回到預設人設
/persona default
```

### 學習導向的使用範例

#### SYNTEC Confluence/JIRA 範例
```
# 學習專案架構
請搜尋 Confluence 中關於 IMX8 專案的架構文件，幫我了解系統設計

# 了解開發規範
請搜尋 Confluence 中的編碼標準和開發流程文件

# 分析問題模式
請搜尋 JIRA 中最近的 Bug 報告，讓我了解常見問題類型

# 學習 API 使用
請搜尋 Confluence 中的 API 文件，教我如何正確使用這些介面
```

#### Notion 範例
```
# 搜尋專案文件
請搜尋我 Notion 中關於 [專案名稱] 的筆記和文件

# 查看任務清單
請列出我 Notion 中待辦事項資料庫的內容

# 整理學習筆記
請幫我在 Notion 中整理關於 [技術主題] 的學習筆記
```

---

## 控制器設定

### SSH 連接配置
- **主機別名**: cnc (設定於 ~/.ssh/config)
- **使用者**: root
- **密碼**: CRokub7L
- **SSH 金鑰**: ~/.ssh/10101672_rsa

### 控制器重置後必要操作
控制器重置時（包含刷機、重新安裝 SWU 後），需要重新認證 SSH 金鑰：

```bash
# 重新複製 SSH 金鑰到控制器
ssh-copy-id -i ~/.ssh/10101672_rsa cnc

# 或使用 IP 直接連接
ssh-copy-id -i ~/.ssh/10101672_rsa root@控制器IP
```

---

*模板版本: 1.0*
*最後更新: {{ "now" | date: "%Y-%m-%d" }}*
