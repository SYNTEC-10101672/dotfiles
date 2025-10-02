# Workspace IMX8 專案模板

{% set project_dir = cwd | basename %}
{% set ssh_port = project_dir | regex_replace(".*-", "") %}
{% set container_name = project_dir | regex_replace("^workspace_", "") %}

## Overview

### 專案大綱
此專案為 IMX8 晶片的嵌入式 Linux 開發環境，主要工作包括：

- **容器環境**: {{ container_name }}
- **開發重點**: meta-syntec 層的套件開發與維護
- **建置系統**: 使用 Yocto/Bitbake 進行映像檔編譯
- **部署方式**: 透過 SWUpdate 機制進行 OTA 更新
- **工作流程**: SSH 連接 → 載入環境 → 開發編譯 → 生成 SWU → 部署更新

### 硬體平台
- **目標晶片**: NXP i.MX8MP
- **開發板**: imx8mpevk-mel
- **作業系統**: Mentor Graphics Linux (MEL) 12.0.2

### 專案結構
```
{{ cwd | basename }}/            # 主機端專案目錄
│
容器內: /home/syntec/workspace/  # 開發工作目錄
├── meta-syntec/                # SYNTEC 開發層
├── build/                      # 建置輸出
├── downloads/                  # 套件快取
└── init                        # 環境初始化
```

## env

- **專案目錄**: {{ project_dir }}
- **容器名稱**: {{ container_name }}
- **SSH Port**: {{ ssh_port }}
- **SSH 使用者**: syntec
- **SSH 登入目錄**: /home/syntec
- **工作路徑**: /home/syntec/workspace (需要 cd workspace 進入)

### SSH 連接設定

#### 1. SSH 金鑰確認
```bash
# 確認 SSH 金鑰存在並設定正確權限
ls -la ~/.ssh/10101672_rsa*
chmod 600 ~/.ssh/10101672_rsa
chmod 644 ~/.ssh/10101672_rsa.pub
```

#### 2. 容器啟動檢查
```bash
# 檢查容器狀態，如未運行則啟動
if ! docker ps | grep -q {{ container_name }}; then
    docker start {{ container_name }}
    sleep 5  # 等待 SSH 服務啟動
fi
```

#### 3. SSH 連接到容器
```bash
# SSH 連接到容器
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost

# 連接後切換到工作目錄（SSH 登入後預設在 /home/syntec）
cd workspace

# 載入建置環境（每次新的 SSH 連線都需要執行）
source build/setup-environment
```

### 環境載入重要提醒

⚠️ **所有編譯相關操作都必須透過 SSH 進入容器執行**

- **容器架構**: 所有 bitbake/devtool 指令只能在容器內執行
- **SSH 必要性**: 主機端無法直接執行 Yocto 相關指令
- **獨立 Shell**: 每次新的 SSH 連線都是獨立的 shell 環境
- **環境載入**: 每個 SSH 指令都需要重新載入環境
- **Locale 設定**: UTF-8 locale 已包含在 Docker image 中

```bash
# ❌ 錯誤：在主機端執行（不會有作用）
bitbake development-image  # 主機端沒有 bitbake

# ❌ 錯誤：SSH 連入但環境未載入
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost
bitbake development-image  # 會失敗，找不到 bitbake

# ✅ 正確：SSH 進入容器並載入環境
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
cd workspace
source build/setup-environment
bitbake development-image
EOF
```

#### Locale 設定確認
```bash
# 檢查容器內的 locale 設定（UTF-8 已預設於 Docker image）
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
locale
EOF
```

#### 故障排解
```bash
# 若出現 SSH 金鑰衝突，清除舊記錄
ssh-keygen -R [localhost]:{{ ssh_port }}

# 測試 SSH 連接
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} -o ConnectTimeout=5 syntec@localhost "echo 'SSH 連接成功'"
```

## build

⚠️ **重要提醒**:
- **容器操作**: 所有編譯指令都必須透過 SSH 進入容器執行
- **環境載入**: 每個 SSH 連線都需要重新載入 bitbake 環境 
- **UTF-8 Locale**: UTF-8 字元編碼已預設於 Docker image

### 編譯映像檔
```bash
# 批次執行模式（推薦用於自動化）
# 注意：必須透過 SSH 進入容器操作
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
cd workspace
source build/setup-environment
bitbake development-image
EOF
```

### 可用的編譯目標
根據建置環境，常見的編譯目標有：
- `core-image-base` - 基本系統映像
- `development-image` - 開發版映像（包含開發工具）
- `production-image` - 生產版映像（需設定 ROOT_PASSWORD）

### 編譯結果說明
編譯成功時會顯示類似以下資訊：
```
Build Configuration:
MACHINE              = "st-imx8mp-cnc"
DISTRO               = "mel"
DISTRO_VERSION       = "12"
TARGET_SYS           = "aarch64-mel-linux"
GCC_VERSION          = "9.3.0"

NOTE: Tasks Summary: Attempted 7091 tasks of which 7091 didn't need to be rerun and all succeeded.
```

### 常見警告說明
編譯過程中可能出現以下警告（正常現象）：
- `WARNING: signing/encrypting SWUpdate files with the test (default) keys is insecure!`
  - 使用測試金鑰，生產環境需更換自己的金鑰
- `WARNING: hawkBit server URL is not configured correctly`
  - hawkBit OTA 更新伺服器未配置（非必要）

### 編譯單一套件
```bash
# 批次執行模式
# 注意：必須透過 SSH 進入容器操作
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
cd workspace
source build/setup-environment
bitbake 套件名稱
EOF
```

### 套件修改
```bash
# 批次執行模式
# 注意：必須透過 SSH 進入容器操作
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
cd workspace
source build/setup-environment
devtool modify 套件名稱
EOF
```

### 生成 SWU 檔
```bash
# 批次執行模式
# 注意：必須透過 SSH 進入容器操作
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost << 'EOF'
cd workspace
source build/setup-environment
bitbake -c generate_swu development-image
EOF
```

## deploy

### SWU 檔案位置
生成的 SWU 檔案位於容器內：
```
/home/syntec/workspace/build/tmp/deploy/images/st-imx8mp-cnc/development-image-st-imx8mp-cnc.swu
```

### 傳送 SWU 到控制器
```bash
# 從容器複製 SWU 檔案到控制器的 /tmp/ 目錄
scp -i ~/.ssh/10101672_rsa -P {{ ssh_port }} \
    syntec@localhost:/home/syntec/workspace/build/tmp/deploy/images/st-imx8mp-cnc/development-image-st-imx8mp-cnc.swu \
    控制器用戶@控制器IP:/tmp/

# 或者在容器內使用 scp 傳送
ssh -i ~/.ssh/10101672_rsa -p {{ ssh_port }} syntec@localhost
scp workspace/build/tmp/deploy/images/st-imx8mp-cnc/development-image-st-imx8mp-cnc.swu \
    控制器用戶@控制器IP:/tmp/
```

### 控制器更新
```bash
# 在控制器上執行 SWUpdate
swupdate-client -v "/tmp/development-image-st-imx8mp-cnc.swu"
```