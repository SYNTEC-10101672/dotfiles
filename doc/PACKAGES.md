# 套件需求

## 必要套件

| 套件 | 用途 | 安裝方式 |
|------|------|----------|
| bash 4.0+ | Shell 本體 | 系統預裝 |
| git 2.0+ | 版本控制 | `apt install git` |
| make | 安裝腳本驅動 | `apt install make` |
| neovim 0.9+ | 主要編輯器 | 見下方說明 |
| tmux | Terminal multiplexer | `apt install tmux` |
| jq | Claude Code statusline JSON 解析 | `apt install jq` |
| curl | 下載工具 | `apt install curl` |

## 強烈建議

| 套件 | 用途 | 安裝方式 |
|------|------|----------|
| fzf | Tig 檔案選擇、模糊搜尋 | 見下方說明 |
| tig 2.0+ | Git TUI 介面 | `apt install tig` |
| ripgrep | Telescope grep 搜尋 | `apt install ripgrep` |
| fd | 快速檔案搜尋 | 見下方說明 |
| node.js (via nvm) | LSP servers、MCP servers | 見下方說明 |
| atuin | Shell history 魔法搜尋 | 見下方說明 |

## 選用（依開發語言）

| 套件 | 用途 | 安裝方式 |
|------|------|----------|
| python3 | Python LSP (pyright) | `apt install python3` |
| .NET SDK | C# 開發 (OmniSharp) | 參考 Microsoft 官方文件 |
| sshpass | CNC 硬體控制 | `apt install sshpass` |

## 特殊安裝說明

### neovim

Ubuntu 18.04 的 apt 版本過舊（0.2.2），需從 GitHub 下載 tarball：

```bash
# 適用 glibc 2.17+（Ubuntu 18.04）
curl -L https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz \
  -o /tmp/nvim-linux64.tar.gz
sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt/
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
```

> **注意**：neovim v0.10+ 需要 glibc 2.28+。Ubuntu 18.04（glibc 2.27）最高只能裝 v0.9.x。

### fzf

建議手動安裝以確保最新版本：

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
# 讓 binary 立即可用
sudo ln -sf ~/.fzf/bin/fzf /usr/local/bin/fzf
```

### fd

Ubuntu 18.04 的 apt 沒有 `fd-find`，從 GitHub 下載 musl 靜態 binary：

```bash
FD_VER=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/sharkdp/fd/releases/download/${FD_VER}/fd-${FD_VER}-x86_64-unknown-linux-musl.tar.gz" \
  -o /tmp/fd.tar.gz
tar -xzf /tmp/fd.tar.gz -C /tmp/
sudo cp "/tmp/fd-${FD_VER}-x86_64-unknown-linux-musl/fd" /usr/local/bin/fd
```

### node.js（via nvm）

```bash
# 安裝 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# 安裝 Node.js（glibc 2.27 的系統最高只能用 v16）
nvm install 16
```

> **注意**：Node.js v18+ 需要 glibc 2.28+。Ubuntu 18.04 只能使用 v16。

### atuin

安裝後 binary 位於 `~/.atuin/bin/`，需重開 terminal 讓 `.bashrc` 自動載入：

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

## 快速檢查

確認目前系統上已安裝哪些套件：

```bash
for cmd in bash git make nvim tmux jq curl fzf tig rg fd node python3; do
  command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd: NOT FOUND"
done
# atuin 安裝在 ~/.atuin/bin/，需開新 terminal 後才能用 command -v 查到
~/.atuin/bin/atuin --version &>/dev/null && echo "✓ atuin" || echo "✗ atuin: NOT FOUND"
```
