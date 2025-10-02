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

本模板已整合 SYNTEC Confluence 和 JIRA MCP server，目前主要用於學習和認識 SYNTEC 的開發環境。

### 目前可用功能
- Confluence 文件搜尋和學習
- JIRA 議題搜尋和分析
- 專案知識庫探索

### 啟動 MCP Server

```bash
./scripts/start-mcp-server.sh
```

### 檢查連線狀態

```bash
./scripts/check-mcp-connection.sh
```

### 環境變數設定

```bash
# 複製範例檔案
cp .env.example .env

# 編輯 .env 檔案，填入你的實際帳號資訊
nano .env
```

.env 檔案內容：
```
SYNTEC_EMAIL=your.email@syntecclub.com.tw
SYNTEC_API_TOKEN=your_api_token_here
```

## 使用說明

1. 確保 Docker 已安裝並運行
2. 設定必要的環境變數
3. 啟動 MCP server
4. 在 Claude Code 中直接使用 Confluence/JIRA 工具

當 MCP server 運行時，你可以直接要求我：
- 搜尋並學習 Confluence 技術文件
- 分析 JIRA 議題了解專案狀況
- 探索專案的架構和開發規範
- 學習團隊的工作流程和最佳實務

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