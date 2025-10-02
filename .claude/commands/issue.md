# /issue - 議題追蹤和筆記管理指令

議題追蹤、MCP 搜尋和專案筆記管理工具。

## 使用方式
```
/issue set <議題編號>                    # 設定當前議題，自動讀取相關筆記
/issue show                             # 顯示當前議題和筆記摘要
/issue                                 # 同 show (預設行為)
/issue clear                           # 清除當前議題
/issue search                          # 搜尋當前議題編號 (syntec-cf-server)
/issue search <mcp-server> <關鍵字>     # 指定server搜尋關鍵字
/issue log {topic}                     # 記錄當前對話到檔案 (檔名: topic-時間.md)
/issue list                            # 顯示最近處理的議題
```

## 支援的議題格式
- `ATEST-xxxxx` (自動化測試相關)
- `MMI-xxxxx` (人機介面相關)  
- `ISSUE-xxxxx` (一般問題)

## 使用範例
```
/issue set MMI-1234
/issue search
/issue log debug-session
```

---

## 指令實作

{% set action = args[0] | default("show") %}
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
正在設定議題資訊並儲存到 ~/.current-issue.json...

<!-- 建立筆記目錄結構 -->
正在建立筆記目錄: `~/project/claude-note/{{ issue_id }}/`

<!-- 讀取現有筆記內容 -->
### 📚 現有筆記內容
{% assign note_dir = '/home/10101672/project/claude-note/' + issue_id %}
{% assign note_files = note_dir | glob: '**/*' %}
{% if note_files.size > 0 %}
找到 {{ note_files.size }} 個檔案，正在載入內容...

{% for file in note_files %}
#### 📄 {{ file | basename }}
{% assign file_content = file | read %}
{% if file_content %}
```
{{ file_content }}
```
{% else %}
*檔案為空或無法讀取*
{% endif %}

---
{% endfor %}
{% else %}
*目前尚無筆記檔案*
{% endif %}

✅ 議題 {{ issue_id }} 已設定完成！

### 💡 接下來您可以：
- `/issue search` - 搜尋議題相關文件
- `/issue log "描述"` - 記錄工作進度  
- `/issue show` - 查看議題詳細狀態

{% else %}
❌ **錯誤**: 請提供議題編號

**使用方式**: `/issue set <議題編號>`  
**支援格式**: MMI-1234, ATEST-5678, ISSUE-9999  
**範例**: `/issue set MMI-1234`
{% endif %}

<!-- 顯示當前議題 -->
{% elif action == "show" or action == "" %}
## 📋 當前議題狀態

{% assign current_issue_file = '/home/10101672/project/claude-note/.current-issue.json' %}
{% assign current_issue_content = current_issue_file | read %}
{% if current_issue_content %}
{% assign current_issue = current_issue_content | jsonparse %}

### 📌 當前議題資訊
- **議題編號**: {{ current_issue.issue_id }}
- **設定時間**: {{ current_issue.set_time }}
- **筆記目錄**: `~/project/claude-note/{{ current_issue.issue_id }}/`

### 📚 筆記檔案
{% assign note_dir = '/home/10101672/project/claude-note/' + current_issue.issue_id %}
{% assign note_files = note_dir | glob: '**/*' %}
{% if note_files.size > 0 %}
{% for file in note_files %}
- 📄 {{ file | basename }}
{% endfor %}
{% else %}
*目前尚無筆記檔案*
{% endif %}

{% else %}
*請先使用 `/issue set <議題編號>` 設定要處理的議題*
{% endif %}

<!-- 清除當前議題 -->
{% elif action == "clear" %}
## 🗑️ 清除當前議題

正在清除當前議題設定...

✅ 當前議題已清除。

<!-- MCP 搜尋功能 -->
{% elif action == "search" %}

{% if args|length == 1 %}
## 🔍 搜尋當前議題相關資訊

{% assign current_issue_file = '/home/10101672/project/claude-note/.current-issue.json' %}
{% assign current_issue_content = current_issue_file | read %}
{% if current_issue_content %}
{% assign current_issue = current_issue_content | jsonparse %}

**當前議題**: {{ current_issue.issue_id }}

<!-- 搜尋當前議題編號 -->
*正在透過 syntec-cf-server 搜尋議題資訊...*

<!-- 這裡會實際呼叫 MCP 搜尋 -->
{% else %}
❌ **錯誤**: 請先使用 `/issue set <議題編號>` 設定要處理的議題

**範例**: `/issue set MMI-1234`
{% endif %}

{% else %}
{% set mcp_server = args[1] %}
{% set search_query = args[2:] | join(" ") %}

## 🔍 MCP 搜尋: {{ search_query }}

**搜尋伺服器**: {{ mcp_server }}  
**搜尋關鍵字**: {{ search_query }}

*正在搜尋中...*

<!-- 這裡會實際呼叫指定的 MCP 搜尋 -->

{% endif %}

<!-- 記錄當前對話 -->
{% elif action == "log" %}
{% set topic = args[1] | default("conversation") %}

## 📝 對話記錄

{% assign current_issue_file = '/home/10101672/project/claude-note/.current-issue.json' %}
{% assign current_issue_content = current_issue_file | read %}
{% if current_issue_content %}
{% assign current_issue = current_issue_content | jsonparse %}

**記錄時間**: {{ current_time }}  
**當前議題**: {{ current_issue.issue_id }}  
**主題**: {{ topic }}  
**檔案名稱**: `{{ timestamp }}_{{ topic }}.md`  
**儲存位置**: `~/project/claude-note/{{ current_issue.issue_id }}/{{ timestamp }}_{{ topic }}.md`

### 說明
正在整理當前對話內容並寫入檔案...

✅ 對話記錄完成！  
📁 檔案已儲存至: `~/project/claude-note/{{ current_issue.issue_id }}/{{ timestamp }}_{{ topic }}.md`

{% else %}
❌ **錯誤**: 請先使用 `/issue set <議題編號>` 設定要處理的議題

**範例**: `/issue set MMI-1234`
{% endif %}

<!-- 顯示議題清單 -->
{% elif action == "list" %}
## 📚 最近處理的議題

<!-- 讀取並顯示最近的議題清單 -->

*目前尚無議題記錄*

<!-- 未知指令 -->
{% else %}
## ❌ 未知的指令: {{ action }}

### 可用指令：
- `set <議題編號>` - 設定當前議題
- `show` - 顯示當前議題狀態
- `clear` - 清除當前議題
- `search [mcp-server] [關鍵字]` - 搜尋相關資訊
- `log {topic}` - 記錄當前對話到檔案
- `list` - 顯示議題清單

**使用方式**: `/issue <指令> [參數]`

{% endif %}

---
*議題管理系統 - {{ current_time }}*