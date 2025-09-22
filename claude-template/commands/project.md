# /project - 專案模板管理指令

管理 Claude Code 的專案模板，可查看當前專案資訊及讀取對應模板。

## 使用方式
```
/project info                    # 顯示當前專案資訊
/project template <模板名稱>     # 讀取並顯示指定模板內容
/project list                    # 列出所有可用模板
/project help                    # 顯示指令幫助
```

## 可用模板
- `allproject` - 通用專案模板
- `appkernel` - AppKernel 專案模板
- `workspace-imx8` - IMX8 工作空間模板
- `workspace-am625` - AM625 工作空間模板

## 使用範例
```
# 顯示當前專案資訊
/project info

# 讀取通用專案模板
/project template allproject

# 讀取 AppKernel 專案模板
/project template appkernel

# 列出所有可用模板
/project list

# 顯示指令幫助
/project help
```

---
## 指令實作

{% set action = args[0] | default("") %}
{% set template_name = args[1] | default("") %}
{% set current_time = "now" | date: "%Y-%m-%d %H:%M:%S" %}
{% set project_dir = cwd | basename %}

<!-- info 功能 -->
{% if action == "info" %}
## 📋 當前專案資訊

**專案目錄**: {{ project_dir }}
**檢查時間**: {{ current_time }}

### 🎯 專案類型識別
{% if project_dir == "appkernel" %}
- **專案類型**: AppKernel 專案
- **對應模板**: appkernel-template.md
{% elif project_dir | startswith("workspace-imx8") %}
- **專案類型**: IMX8 工作空間專案
- **對應模板**: workspace-imx8-template.md
{% elif project_dir | startswith("workspace-am625") %}
- **專案類型**: AM625 工作空間專案
- **對應模板**: workspace-am625-template.md
{% else %}
- **專案類型**: 通用專案
- **對應模板**: allproject-template.md
{% endif %}

### 📁 專案路徑資訊
- **工作目錄**: {{ cwd }}
- **模板路徑**: ~/project-templates/

{% endif %}

<!-- template 功能 -->
{% elif action == "template" %}
{% if template_name %}
## 📄 模板內容: {{ template_name }}

{% if template_name == "allproject" %}
{% assign template_path = "./project-templates/allproject-template.md" %}
{% elsif template_name == "appkernel" %}
{% assign template_path = "./project-templates/appkernel-template.md" %}
{% elsif template_name == "workspace-imx8" %}
{% assign template_path = "./project-templates/workspace-imx8-template.md" %}
{% elsif template_name == "workspace-am625" %}
{% assign template_path = "./project-templates/workspace-am625-template.md" %}
{% else %}
{% assign template_path = "" %}
{% endif %}

{% if template_path %}
### 📖 模板路徑: {{ template_path }}

@{{ template_path }}

{% else %}
### ❌ 錯誤: 未知的模板名稱

**支援的模板**:
- allproject
- appkernel
- workspace-imx8
- workspace-am625

**使用方式**: `/project template <模板名稱>`
{% endif %}

{% else %}
### ❌ 錯誤: 請指定模板名稱

**使用方式**: `/project template <模板名稱>`
**範例**: `/project template appkernel`
{% endif %}
{% endif %}

<!-- list 功能 -->
{% elif action == "list" %}
## 📋 可用模板列表

### 📄 模板檔案
1. **allproject** - 通用專案模板
   - 檔案: `project-templates/allproject-template.md`
   - 用途: 所有專案的通用設定和指令

2. **appkernel** - AppKernel 專案模板
   - 檔案: `project-templates/appkernel-template.md`
   - 用途: 人機介面 AppKernel 專案專用設定

3. **workspace-imx8** - IMX8 工作空間模板
   - 檔案: `project-templates/workspace-imx8-template.md`
   - 用途: IMX8 晶片嵌入式開發環境設定

4. **workspace-am625** - AM625 工作空間模板
   - 檔案: `project-templates/workspace-am625-template.md`
   - 用途: AM625 晶片嵌入式開發環境設定

### 💡 使用方式
```
/project template <模板名稱>
```

{% endif %}

<!-- help 功能 -->
{% elif action == "help" %}
## ❓ /project 指令幫助

### 📋 指令列表
- `/project info` - 顯示當前專案資訊
- `/project template <模板名稱> `- 讀取並顯示指定模板內容
- `/project list` - 列出所有可用模板
- `/project help` - 顯示此幫助資訊

### 📄 模板名稱
- `allproject` - 通用專案模板
- `appkernel` - AppKernel 專案模板
- `workspace-imx8` - IMX8 工作空間模板
- `workspace-am625` - AM625 工作空間模板

### 🎯 使用範例
```
# 顯示當前專案資訊
/project info

# 讀取 AppKernel 專案模板
/project template appkernel

# 列出所有可用模板
/project list

# 顯示幫助資訊
/project help
```

{% endif %}

<!-- 未知指令或空指令 -->
{% elif action == "" %}
## 📋 /project 指令說明

### 可用指令：
- `info` - 顯示當前專案資訊
- `template <模板名稱>` - 讀取並顯示指定模板內容
- `list` - 列出所有可用模板
- `help` - 顯示指令幫助

### 使用流程：
1. `/project info` - 了解當前專案類型
2. `/project template <模板名稱>` - 查看對應模板內容
3. `/project list` - 查看所有可用模板
4. `/project help` - 獲取詳細幫助資訊

{% else %}
## ❌ 未知的指令: {{ action }}

### 可用指令：
- `info` - 顯示當前專案資訊
- `template <模板名稱>` - 讀取並顯示指定模板內容
- `list` - 列出所有可用模板
- `help` - 顯示指令幫助

**使用方式**: `/project <指令> [參數]`

{% endif %}