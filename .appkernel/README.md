# Appkernel 遠端編譯系統

這是一套簡化的自動化流程，讓你可以在 Linux 環境下透過 SSH 和 Samba，在 Windows PC 上編譯 Appkernel 專案。

> **注意**: 這些腳本僅供個人 Linux 開發環境使用，存放在 `.dotfiles` 專案中維護。團隊其他成員不受影響。

## 系統架構

```
Linux (Samba Server)                   Windows PC
│                                       │
│  .dotfiles/                           │
│  └── .appkernel/                     │
│      ├── appkernel-setup.sh           │
│      └── appkernel-build.sh           │
│                                       │
│      [Samba 共享]                     │
│           │                           │
│           └──────────────────────────→ Z:\appkernel\
│                                       │
│  [SSH + sshpass]                     │
│           │                           │
│           └──────────────────────────→ 執行遠端編譯
                                        │  1. Setup: 掛載 + 載入 SDK
                                        │  2. Build: 掛載 + 編譯指定專案
```

## 目錄結構

```
.dotfiles/
└── .appkernel/                        # 所有 appkernel 相關腳本集中管理
    ├── appkernel-setup.sh             # Setup（mount + SDK）
    ├── appkernel-build.sh             # Build（通用編譯腳本）
    ├── appkernel-deploy.sh            # Deploy（部署至控制器）
    ├── omnisharp.json                 # OmniSharp 設定（ReleaseEL|x86）
    ├── .editorconfig                  # C# coding style 規範
    └── README.md                      # 本文件
```

## 核心概念

系統簡化為**三個核心指令**：

### 1. `aksetup` - 環境設定（一次性）
- 掛載 Samba 共享到 Z:
- 載入 SDK 環境
- 自動建立開發環境設定檔（omnisharp.json、.editorconfig）
- **執行時機**：每天第一次使用 / SDK 更新時
- **執行時間**：3-10 分鐘（需下載 SDK）

### 2. `akbuild <PROJECT> <CONFIG>` - 通用編譯
- 掛載 Z: 磁碟機
- 設定 MSBUILD 環境變數
- 編譯指定的專案和組態
- **執行時機**：每次修改程式碼後
- **執行時間**：1-3 分鐘
- **參數說明**：
  - `PROJECT`: 專案名稱（如 `MMICommon32`、`CncMonEL`、`CncMon`）
  - `CONFIG`: 組態名稱（如 `ReleaseEL`、`DebugEL`）

### 3. `akdeploy <PROJECT> <CONFIG>` - 部署至控制器
- 檢查編譯產物並部署至控制器（透過 SSH）
- 支援新舊版本自動相容（`MMICommon.dll` / `MMICommon32.dll`）
- **執行時機**：編譯完成後需要測試時
- **執行時間**：10-30 秒

## 環境變數設定（首次使用必須）

腳本使用環境變數來保護敏感資訊（如密碼）。首次使用前需要在 `~/.env` 中設定：

```bash
# 編輯 ~/.env 檔案
vim ~/.env
```

加入以下內容：
```bash
# Windows PC SSH credentials
export APPKERNEL_WINDOWS_HOST="windows_pc"
export APPKERNEL_WINDOWS_PASSWORD="your_actual_windows_ssh_password"

# Samba credentials (for mounting network share)
export APPKERNEL_SAMBA_USER="your_username"
export APPKERNEL_SAMBA_PASSWORD="your_actual_samba_password"
```

> **注意**: `~/.env` 已在 `.gitignore` 中，不會被提交到 git，確保密碼安全。

設定後重新載入環境：
```bash
source ~/.env
```

## 快速開始

### 第一次使用

```bash
# 1. 設定環境變數（重要！）
vim ~/.env  # 填入 Windows SSH 密碼和 Samba 密碼
source ~/.env

# 2. 啟用 aliases
source ~/.aliases

# 3. 執行 Setup（掛載 + 載入 SDK）
aksetup

# 4. 編譯你的專案
akbuild CncMonEL ReleaseEL
```

### 日常開發流程

```bash
# 早上開始工作，先執行 setup（只需執行一次）
aksetup

# 修改程式碼
cd ~/project/windows_project/appkernel
vim CncMon/Source/MainForm.cs

# 編譯測試（可重複執行多次，使用不同專案/組態）
akbuild CncMonEL ReleaseEL
akbuild MMICommon32 ReleaseEL

# 部署至控制器
akdeploy MMICommon32 ReleaseEL

# 繼續修改、編譯和部署...
```

## 可用的指令 (Aliases)

| 指令         | 功能說明                           | 範例                              |
|-------------|-----------------------------------|----------------------------------|
| `aksetup`   | 掛載共享 + 載入 SDK                | `aksetup`                        |
| `akbuild`   | 編譯指定專案（需要兩個參數）        | `akbuild CncMonEL ReleaseEL`     |
| `akdeploy`  | 部署至控制器（需要兩個參數）        | `akdeploy MMICommon32 ReleaseEL` |

### 啟用 Aliases

新開的終端需要執行（或將此行加入 `.bashrc`）：
```bash
source ~/.aliases
```

建議加入 `.bashrc` 自動載入：
```bash
echo "source ~/.aliases" >> ~/.bashrc
echo "source ~/.env" >> ~/.bashrc
```

## akbuild 使用範例

`akbuild` 是通用編譯腳本，接受任意專案名稱和組態：

```bash
# 編譯 MMICommon32 的 ReleaseEL 組態
akbuild MMICommon32 ReleaseEL

# 編譯 CncMonEL 的 ReleaseEL 組態
akbuild CncMonEL ReleaseEL

# 編譯 CncMon 的 DebugEL 組態
akbuild CncMon DebugEL

# 如果沒有提供參數，會顯示錯誤和使用說明
akbuild
# 輸出：
# ERROR: Missing required parameters
#
# Usage: akbuild <PROJECT> <CONFIG>
#
# Examples:
#   akbuild MMICommon32 ReleaseEL
#   akbuild CncMonEL ReleaseEL
#   akbuild CncMon DebugEL
```


## 編譯輸出

### 成功編譯
- **輸出位置**：`~/project/windows_project/appkernel/Bin/<CONFIG>/`
- **範例**：
  - ReleaseEL: `~/project/windows_project/appkernel/Bin/EL/CncMonEL.exe`
  - DebugEL: `~/project/windows_project/appkernel/Bin/EL/CncMonEL.exe`

### 編譯訊息
- 所有編譯輸出直接顯示在終端機上
- 不會產生額外的錯誤日誌檔案

## 環境配置

### Linux 端設定

1. **Samba 共享配置** (`/etc/samba/smb.conf`)
   ```ini
   [sharedfolder]
   path = /home/your_username/project/windows_project
   browsable = yes
   read only = no
   guest ok = yes
   force user = your_username
   ```

2. **SSH 配置** (`~/.ssh/config`)
   ```
   Host windows_pc
       HostName your_windows_pc_ip
       User your_domain\your_username
       Port 22
   ```

3. **環境變數** (`~/.env`)
   ```bash
   export APPKERNEL_WINDOWS_HOST="windows_pc"
   export APPKERNEL_WINDOWS_PASSWORD="your_password"
   export APPKERNEL_SAMBA_USER="your_username"
   export APPKERNEL_SAMBA_PASSWORD="your_samba_password"
   ```

### Windows 端需求

1. 已安裝 OpenSSH Server
2. 具有網路存取權限以下載 SDK：
   - `\\File\DeveloperZone\BuildSchedule\Newest`
   - `\\File\CncRel`
3. 已安裝 Visual Studio 2022 Professional（含 MSBuild）
   - MSBUILD 路徑：`C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe`

## 常見問題

### 1. Samba 服務未啟動

```bash
sudo systemctl start smbd
sudo systemctl enable smbd
```

### 2. SSH 連線失敗

```bash
ping your_windows_pc_ip
ssh windows_pc "echo test"
```

### 3. 編譯失敗：參數錯誤

akbuild 需要兩個參數，缺一不可：
```bash
# ❌ 錯誤
akbuild
akbuild CncMonEL

# ✅ 正確
akbuild CncMonEL ReleaseEL
```

### 4. 編譯失敗：MSBUILD not found

表示 SDK 尚未載入，執行：
```bash
aksetup
```

### 5. Alias 找不到

重新載入 aliases：
```bash
source ~/.aliases
source ~/.env
```

### 6. Z: 磁碟機掛載失敗

檢查 Samba 帳密是否正確設定在 `~/.env` 中：
```bash
cat ~/.env | grep SAMBA
```

## Vim 開發環境整合

### OmniSharp 與 EditorConfig 支援

系統整合了 OmniSharp 語言伺服器和 EditorConfig，提供完整的 C# 開發環境。

#### 自動設定

執行 `aksetup` 時，會在專案目錄自動建立兩個設定檔的軟連結：

```bash
cd ~/project/windows_project/appkernel
aksetup

# 自動建立以下軟連結：
# omnisharp.json  -> ~/.dotfiles/.appkernel/omnisharp.json
# .editorconfig   -> ~/.dotfiles/.appkernel/.editorconfig
```

**或者**，直接開啟任何 C# 檔案時，vim 也會自動偵測並建立軟連結（防呆機制）。

#### OmniSharp 設定

`omnisharp.json` 設定檔內容：
```json
{
  "MSBuild": {
    "LoadProjectsOnDemand": false,
    "Configuration": "ReleaseEL",
    "Platform": "x86"
  }
}
```

這確保 OmniSharp 使用正確的 Configuration（ReleaseEL|x86），讓 IntelliSense 和 go-to-definition 能讀取正確的條件編譯程式碼。

#### EditorConfig 設定

`.editorconfig` 定義了團隊統一的 C# coding style：
- **縮排**：Tab（不是空格）
- **換行規則**：methods, types, accessors, properties 前換行
- **空格規則**：控制流程語句、括號、逗號等的空格

#### Vim 快捷鍵

開啟 C# 檔案後可使用以下快捷鍵：

**導航**：
- `gd` - 跳轉到定義（go to definition）
- `Ctrl-O` - 回到上一個位置
- `Ctrl-I` / `Tab` - 往前跳
- `[[` / `]]` - 在方法間上下跳轉

**格式化**：
- `,f` - 格式化整個檔案（Normal mode）
- `,f` - 調整選取範圍的縮排（Visual mode）
- `,os=` - 格式化整個檔案（完整版）

**其他功能**：
- `,osfu` - 尋找所有使用處（find usages）
- `,osfi` - 尋找實作（find implementations）
- `,osfx` - 修正 using 語句
- `,osre` - 重新啟動 OmniSharp server
- `:OmniSharpStatus` - 檢查 OmniSharp 狀態

**重要提醒**：
- OmniSharp 需要時間分析專案（首次開啟可能需要 1-2 分鐘）
- 如果修改了 `omnisharp.json`，需要執行 `,osre` 重新啟動 server
- 如果 go-to-definition 跳轉錯誤，確認 Configuration 是否正確設定為 ReleaseEL|x86

### 中文顯示與顏色輸出

系統已針對 SSH 遠端執行進行編碼優化：

- **UTF-8 編碼**：自動設定 Windows CMD 為 UTF-8（`chcp 65001`），正確顯示中文訊息
- **ANSI 顏色**：啟用虛擬終端支援，保留 MSBuild 的彩色輸出
  - 綠色：成功訊息（BUILD SUCCEEDED）
  - 紅色：錯誤訊息（error C1234）
  - 黃色：警告訊息（warning C4567）

## 技術說明

### SSH Session 獨立性

每次 SSH 連線都是獨立的 session，因此：
- `aksetup` 載入的 SDK 環境變數**不會**延續到 `akbuild`
- 每個指令都需要**獨立掛載** Z: 磁碟機
- `aksetup` 使用 `persistent:yes`（永久掛載）
- `akbuild` 使用 `persistent:no`（臨時掛載）

### MSBUILD 環境

`akbuild` 會在每次編譯前設定 MSBUILD 環境變數：
```batch
set MSBUILD="C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
```

這樣就不需要依賴 SDK 載入的環境變數。

## 效能說明

| 操作    | 預估時間     | 執行頻率            |
|---------|-------------|---------------------|
| Setup   | 3-10 分鐘   | 每天一次 / SDK更新時 |
| Build   | 1-3 分鐘    | 每次修改程式碼後     |

## 系統需求

- **Linux**: Ubuntu/Debian with Samba & sshpass
- **Windows**: Windows 10/11 with OpenSSH Server
- **Network**: 兩台機器需在同一網段
- **Visual Studio**: 2022 Professional with MSBuild

## Git 工作流程

所有腳本都在 `.dotfiles` 專案中版控：

```bash
cd ~/.dotfiles

# 查看修改
git status

# 提交變更
git add .appkernel/
git commit -m "feat: update appkernel build system"
git push

# 在其他機器同步
git pull
aksetup  # 重新部署批次檔和設定環境
```

---

**建立日期**: 2025-11-21
**更新日期**: 2025-11-28
**版本**: 5.0（整合 OmniSharp 與 EditorConfig，優化編碼與顏色輸出）
