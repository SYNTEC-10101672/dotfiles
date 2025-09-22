# Daily Claude Greeting 每日 Claude 問候

這個腳本會在每天早上 5:00 自動在工作目錄開啟 Claude 並說 hi。

## 檔案說明

### 主腳本
- **檔案位置**: `/home/10101672/.claude/scripts/daily-claude-greeting.sh`
- **執行時間**: 每天早上 5:00 (cron job)
- **功能**: 自動在當前工作目錄啟動 Claude 並發送問候訊息

### 日誌檔案
- **日誌位置**: `/home/10101672/.claude/logs/daily-claude-greeting.log`
- **內容**: 記錄每次執行的時間、工作目錄和結果

## Cron Job 設定

```bash
# 查看當前 cron jobs
crontab -l

# 編輯 cron jobs
crontab -e
```

當前設定：
```
0 5 * * * /home/10101672/.claude/scripts/daily-claude-greeting.sh
```

## 工作目錄邏輯

腳本會按以下順序尋找工作目錄：

1. **環境變數**: `$CLAUDE_WORK_DIR` (如果設定的話)
2. **專案目錄**: `/home/10101672/project` 下的第一個目錄
3. **IMX8 工作空間**: `/home/10101672/workspace-imx8-master`
4. **預設目錄**: `/home/10101672` (家目錄)

## 環境變數設定

如果想指定特定的工作目錄，可以在 crontab 中設定環境變數：

```bash
# 編輯 crontab
crontab -e

# 添加環境變數設定
CLAUDE_WORK_DIR=/path/to/your/project
0 5 * * * /home/10101672/.claude/scripts/daily-claude-greeting.sh
```

## 手動測試

```bash
# 手動執行腳本測試
/home/10101672/.claude/scripts/daily-claude-greeting.sh

# 檢查日誌
tail -f /home/10101672/.claude/logs/daily-claude-greeting.log
```

## 停用或修改

### 暫時停用
```bash
# 註解掉 cron job
crontab -e
# 在行首加上 # 註解符號
```

### 修改時間
```bash
# 編輯 cron job 時間
crontab -e
# 修改 "0 5 * * *" 部分
# 例如改為 8:30: "30 8 * * *"
```

### 完全移除
```bash
# 移除 cron job
crontab -r
```

## 問題排解

### 檢查 cron 服務狀態
```bash
systemctl status cron
# 或
service cron status
```

### 檢查腳本權限
```bash
ls -la /home/10101672/.claude/scripts/daily-claude-greeting.sh
# 應該顯示 -rwxr-xr-x (可執行權限)
```

### 檢查 Claude 命令
```bash
which claude
claude --version
```