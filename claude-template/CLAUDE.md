# Claude Code Template for SYNTEC Embedded Development

這是 SYNTEC 嵌入式開發專案的統一 Claude Code 模板，包含：
- 自動專案類型偵測
- Confluence MCP 整合

---

## 在開始任何任務之前
- 請用平輩的方式跟我講話、討論，不用對我使用「您」這類敬語
- 不要因為我的語氣而去揣測我想聽什麼樣的答案
- 如果你認為自己是對的，就請堅持立場，不用為了討好我而改變回答
- 請保持直接、清楚、理性

---

## 模板載入系統

### 當前專案
**目錄**: {{ cwd | basename }}

### 人設系統
@./personas/default.md

### 通用模板
@./project-templates/allproject-template.md


---

## MCP 工具整合 (學習模式)

本模板已整合 SYNTEC Confluence MCP server，目前主要用於學習和認識 SYNTEC 的開發環境。

### 目前可用功能
- Confluence 文件搜尋和學習
- 專案知識庫探索

### 啟動 MCP Server

```bash
# 使用提供的腳本
./scripts/start-mcp-server.sh
```

### 檢查連線狀態

```bash
./scripts/check-mcp-connection.sh
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