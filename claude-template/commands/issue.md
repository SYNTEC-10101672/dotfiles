# /issue - 議題追蹤和筆記管理指令

簡潔的議題追蹤和筆記管理工具。

## 使用方式
```
/issue set <議題編號>                    # 設定當前議題，建立議題資料夾
/issue log {topic}                       # 記錄當前對話到檔案，topic 中文會轉為英文關鍵字
/issue know                              # 讀取當前議題資料夾，了解處理進度
/issue dailylog                          # 每日進度回顧，討論並更新 TODO.md
```

## 支援的議題格式
- `ATEST-xxxxx` (自動化測試相關)
- `MMI-xxxxx` (人機介面相關)  
- `ISSUE-xxxxx` (一般問題)

## 使用範例
```
/issue set MMI-1234
/issue log 除錯網路連線問題
/issue know
/issue dailylog
```

---

## 指令實作

{% set action = args[0] | default("") %}
{% set current_time = "now" | date: "%Y-%m-%d %H:%M:%S" %}
{% set timestamp = "now" | date: "%Y%m%d_%H%M%S" %}

<!-- 設定當前議題 -->
{% if action == "set" %}
{% set issue_id = args[1] %}

{% if issue_id %}
## 🎯 設定當前議題: {{ issue_id }}

**設定時間**: {{ current_time }}  
**專案路徑**: {{ cwd }}  
**筆記目錄**: `~/project/claude-note/{{ issue_id }}/`

<!-- 儲存議題資訊到 .current-issue.json -->
{% assign current_issue_json = '{"issue_id":"' + issue_id + '","set_time":"' + current_time + '","project_path":"' + cwd + '"}' %}

### 📝 議題資訊儲存
請執行以下指令來儲存議題資訊到 `~/.current-issue.json`：

```bash
echo '{{ current_issue_json }}' > ~/.current-issue.json
```

> **說明**: 由於模板限制，需要手動執行上述指令來建立議題追蹤檔案。此檔案用於在後續的 Claude 會話中自動識別當前處理的議題。

<!-- 建立筆記目錄結構 -->
正在建立筆記目錄: `~/project/claude-note/{{ issue_id }}/`

✅ 議題 {{ issue_id }} 已設定完成！

### 💡 接下來你可以：
- `/issue log "描述"` - 記錄工作進度  
- `/issue know` - 了解目前處理狀況

{% else %}
❌ **錯誤**: 請提供議題編號

**使用方式**: `/issue set <議題編號>`  
**支援格式**: MMI-1234, ATEST-5678, ISSUE-9999  
**範例**: `/issue set MMI-1234`
{% endif %}

<!-- 記錄當前對話 -->
{% elif action == "log" %}
{% set topic = args[1] | default("conversation") %}

## 📝 對話記錄

{% assign current_issue_file = '/home/10101672/.current-issue.json' %}
{% assign current_issue_content = current_issue_file | read %}
{% if current_issue_content %}
{% assign current_issue = current_issue_content | jsonparse %}
{% if current_issue.issue_id %}

**記錄時間**: {{ current_time }}  
**當前議題**: {{ current_issue.issue_id }}  
**原始主題**: {{ topic }}  
**專案路徑**: {{ current_issue.project_path | default: "未記錄" }}

<!-- 中文主題轉英文關鍵字處理提示 -->
{% if topic contains "中文" or topic | regex_test: "[\u4e00-\u9fff]" %}
*正在將中文主題 "{{ topic }}" 轉換為英文關鍵字...*
{% endif %}

**檔案名稱**: `{{ timestamp }}_[英文關鍵字].md`  
**儲存位置**: `~/project/claude-note/{{ current_issue.issue_id }}/`

### 說明
正在整理當前對話內容並寫入檔案...
中文主題將自動轉換為簡單的英文關鍵字作為檔名。

✅ 對話記錄完成！  

{% else %}
❌ **錯誤**: `.current-issue.json` 檔案格式異常，請重新設定議題

**請執行**: `/issue set <議題編號>` 重新設定議題
{% endif %}
{% else %}
❌ **錯誤**: 找不到當前議題資訊

**可能原因**:
- 尚未設定議題 → 使用 `/issue set <議題編號>` 設定
- `.current-issue.json` 檔案不存在 → 重新執行 issue set 指令

**範例**: `/issue set MMI-1234`
{% endif %}

<!-- 了解目前處理狀況 -->
{% elif action == "know" %}

## 🧠 了解目前處理狀況

讓我檢查當前議題設定並分析議題處理狀況...

### 🔍 檢查步驟：

1. **讀取 `~/.current-issue.json` 檔案** - 了解當前設定的議題
2. **分析議題資料夾內容** - 讀取 `~/project/claude-note/[議題編號]/` 內的所有筆記
3. **提供處理狀況總結** - 根據筆記內容分析目前進度

### 📋 執行說明：

當你下 `/issue know` 指令時，我會：
- 自動讀取並解析當前議題設定
- 搜尋對應議題資料夾中的所有 `.md` 檔案  
- 分析筆記內容，了解議題處理進度
- 提供後續建議和行動方案

💡 **如果出現「未設定議題」的錯誤，請先使用 `/issue set <議題編號>` 設定要處理的議題。**

<!-- 每日進度回顧 -->
{% elif action == "dailylog" %}

## 📅 每日進度回顧

**回顧時間**: {{ current_time }}

### 🎯 今日工作討論

讓我們來回顧一下今天的工作進度！請跟我分享：

1. **今天主要完成了什麼任務？**
2. **有遇到什麼技術問題或挑戰嗎？**
3. **這些問題是否已經解決？如何解決的？**
4. **明天的工作重點是什麼？**
5. **有什麼需要特別記錄或跟進的事項嗎？**

### 📝 進度更新說明

討論完後，我會協助你：
- 更新議題資料夾中的 TODO.md 檔案進度狀況
- 記錄今日完成的任務
- 整理遇到的問題和解決方案  
- 規劃明日的工作重點

💡 **請直接在對話中分享你今天的工作狀況，我會根據你的回答來更新該議題的 TODO.md 檔案。**

<!-- 未知指令或空指令 -->
{% elif action == "" %}
## 📋 Issue 指令說明

### 可用指令：
- `set <議題編號>` - 設定當前議題，建立議題資料夾
- `log {topic}` - 記錄當前對話到檔案，中文主題自動轉為英文關鍵字  
- `know` - 讀取當前議題資料夾，了解處理進度
- `dailylog` - 每日進度回顧，討論並更新 TODO.md

### 使用流程：
1. `/issue set MMI-1234` - 設定要處理的議題
2. `/issue log 調試網路問題` - 記錄工作過程  
3. `/issue know` - 讓 AI 了解目前狀況
4. `/issue dailylog` - 每日下班前回顧進度

{% else %}
## ❌ 未知的指令: {{ action }}

### 可用指令：
- `set <議題編號>` - 設定當前議題
- `log {topic}` - 記錄當前對話到檔案
- `know` - 了解目前處理狀況
- `dailylog` - 每日進度回顧

**使用方式**: `/issue <指令> [參數]`

{% endif %}

---
*議題管理系統 - {{ current_time }}*