# SYNTEC Claude Code 開發模板

這是 SYNTEC 嵌入式系統開發專案的統一 Claude Code 模板，整合了 Confluence/JIRA MCP 伺服器，提供自動化的專案管理和文件處理功能。

## 功能特色

- 🎯 **自動專案偵測**: 根據資料夾名稱自動載入對應的開發模板
- 🎭 **多重人設系統**: 5種專業人設（開發助手、除錯專家、架構師、審查員、測試專家）
- 🌐 **中文優先**: 預設使用繁體中文進行溝通和協助
- 📝 **Confluence 學習**: 搜尋並學習 Confluence 技術文件和開發規範
- 🎫 **JIRA 分析**: 搜尋分析 JIRA 議題，了解專案狀況和問題模式
- 🔧 **硬體平台支援**: 針對 IMX8、AM625 等硬體平台的特定工作流程
- 📋 **統一開發規範**: 包含程式碼標準、Git 流程、測試策略

## 資料夾結構

```
claude-template/
├── CLAUDE.md                              # 主記憶檔案
├── settings.json                          # Claude 全局設定
├── .mcp.json                              # MCP 伺服器設定
├── .env.example                           # 環境變數範例
├── project-templates/                     # 專案模板目錄
│   ├── allproject-template.md            # 通用開發模板
│   ├── appkernel-template.md             # AppKernel 專案模板
│   ├── workspace-imx8-template.md        # IMX8 工作空間模板
│   ├── workspace-am625-template.md       # AM625 工作空間模板
├── personas/                             # 人設系統
│   ├── default.md                        # 預設開發助手
│   ├── debugger.md                       # 除錯專家
│   ├── architect.md                      # 系統架構師
│   ├── reviewer.md                       # 程式碼審查員
│   └── tester.md                         # 測試專家
├── commands/                             # Slash 指令
│   └── persona.md                        # 人設切換指令
└── scripts/                              # 自動化腳本
    ├── start-mcp-server.sh               # 啟動 MCP 伺服器
    ├── check-mcp-connection.sh           # 檢查連線狀態
    └── setup-project-mcp.sh              # 為專案設定 MCP 連接
```

## 安裝設定

### 1. 複製模板到 Claude Code 目錄

```bash
# 將整個專案複製到 Claude Code 設定目錄
cp -r claude-template ~/.claude/
```

### 2. 設定 Confluence/JIRA 帳號

```bash
# 複製環境變數範例檔案
cd ~/.claude
cp .env.example .env

# 編輯 .env 檔案，填入你的帳號資訊
vim .env
```

在 `.env` 檔案中設定：
```
SYNTEC_USERNAME=你的工號
SYNTEC_PASSWORD=你的密碼
```

### 3. 確保 Docker 已安裝

```bash
# 檢查 Docker 是否已安裝
docker --version

# 如果未安裝，請先安裝 Docker
```

## 使用方式

### 啟動 MCP 伺服器

```bash
# 進入 Claude Code 設定目錄
cd ~/.claude

# 啟動 MCP 伺服器 (SSE 方式)
./scripts/start-mcp-server.sh

# 或使用 HTTP 方式
./scripts/start-mcp-server.sh streamable-http
```

### 檢查連線狀態

```bash
./scripts/check-mcp-connection.sh
```

### 為專案設定 MCP 連接

每個專案都需要 `.mcp.json` 檔案才能連接到 MCP 伺服器。使用自動化腳本設定：

```bash
# 為當前專案設定 MCP 連接
~/.claude/scripts/setup-project-mcp.sh

# 為指定專案設定 MCP 連接
~/.claude/scripts/setup-project-mcp.sh /path/to/your/project
```

### 專案類型自動偵測

當你使用 Claude Code 開啟專案時，會根據資料夾名稱自動載入對應模板：

- `appkernel/` → AppKernel 開發模板
- `workspace-imx8-*` → IMX8 硬體平台模板
- `workspace-am625-*` → AM625 硬體平台模板

所有專案都會載入通用開發模板。

## 人設系統

Claude Code 預設使用繁體中文，並提供 5 種專業人設，可根據不同工作情境切換：

### 🎭 可用人設

1. **default** - 預設開發助手
   - 適用於一般開發任務
   - 平衡的技術知識和建議

2. **debugger** - 除錯專家
   - 專精於問題診斷和效能分析
   - 熟悉各種除錯工具和技術
   - 系統性的問題排查方法

3. **architect** - 系統架構師
   - 專注於系統設計和架構規劃
   - 考慮可擴展性和可維護性
   - 技術選型和設計決策

4. **reviewer** - 程式碼審查員
   - 專精於程式碼品質和安全性
   - 提供具體的改進建議
   - 編碼最佳實務和規範

5. **tester** - 測試專家
   - 專注於測試策略和品質保證
   - 測試案例設計和自動化
   - 品質控制和風險管理

### 🔄 人設切換

使用 slash 指令快速切換人設：

```bash
# 除錯問題時
/persona debugger
我的系統在高負載時會當機，請幫我分析可能的原因

# 設計新功能時  
/persona architect
我需要為現有系統加入新的通訊模組，請幫我設計架構

# 程式碼審查時
/persona reviewer
請幫我檢查這段記憶體管理的程式碼是否有問題

# 規劃測試時
/persona tester
請幫我設計這個新功能的完整測試策略

# 回到預設人設
/persona default
```

### 🌐 中文優先

- Claude Code 預設使用繁體中文回應
- 技術術語和程式碼保持英文
- 可透過 settings.json 調整語言偏好

## MCP 學習功能

啟動 MCP 伺服器後，主要用於讓 Claude Code 學習和認識 SYNTEC 的開發環境：

### Confluence 學習功能
- 搜尋並學習專案技術文件
- 了解系統架構和設計原理
- 學習開發規範和最佳實務
- 探索 API 文件和使用方式

### JIRA 分析功能
- 搜尋分析專案議題狀況
- 了解常見問題類型和解決方案
- 學習團隊的工作流程
- 分析專案進度和優先級

### 學習導向使用範例

```
# 學習專案架構
請搜尋 Confluence 中關於 IMX8 專案的架構文件，
幫我了解系統的整體設計和模組關係

# 了解開發環境
請搜尋 Confluence 中關於開發環境設定的文件，
讓我知道需要安裝哪些工具和如何配置

# 學習編碼規範
請搜尋 Confluence 中的編碼標準文件，
教我如何寫出符合團隊要求的程式碼

# 分析問題趨勢
請搜尋 JIRA 中最近的 Bug 報告，
讓我了解專案中常見的問題類型和解決模式

# 學習 API 使用
請搜尋 Confluence 中的 API 文件，
幫我理解如何正確使用這些介面
```

### 持續學習建議

建議在每次開始新任務時，都先使用 MCP 工具搜尋相關文件，讓 Claude Code 了解：
1. 相關的技術背景和現有實作
2. 團隊的開發規範和標準
3. 類似問題的解決方案
4. 測試和品質要求

## 自訂模板

你可以根據需要修改或新增專案模板：

1. 編輯 `project-templates/` 目錄下的模板檔案
2. 修改 `CLAUDE.md` 中的專案偵測邏輯
3. 更新 `.mcp.json` 中的 MCP 設定

## 故障排除

### MCP 伺服器無法啟動
1. 檢查 Docker 是否正在運行
2. 確認 `.env` 檔案中的帳號密碼正確
3. 檢查網路連線和防火牆設定

### 環境變數未載入
1. 確認 `.env` 檔案位置正確 (`~/.claude/.env`)
2. 檢查檔案權限和內容格式
3. 重新啟動 MCP 伺服器

### 專案模板未自動載入
1. 檢查專案資料夾名稱是否符合規則
2. 確認 `CLAUDE.md` 中的偵測邏輯
3. 重新啟動 Claude Code

## 版本資訊

- **版本**: 1.1
- **支援平台**: Linux, macOS, Windows (with WSL)
- **相依套件**: Docker, Claude Code

## 授權

內部使用，SYNTEC 版權所有。

---

如有問題或建議，請聯繫開發團隊。