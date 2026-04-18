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
| bash-completion | Bash tab 補全 | `apt install bash-completion` |
| Claude Code plugins | skills、MCP servers、工作流自動化 | 見下方說明 |

## 強烈建議

| 套件 | 用途 | 安裝方式 |
|------|------|----------|
| fzf | Tig 檔案選擇、模糊搜尋 | 見下方說明 |
| tig 2.0+ | Git TUI 介面 | `apt install tig` |
| ripgrep | Telescope grep 搜尋 | `apt install ripgrep` |
| fd | 快速檔案搜尋 | 見下方說明 |
| node.js (via nvm) | LSP servers、MCP servers | 見下方說明 |
| atuin | Shell history 魔法搜尋 | 見下方說明 |
| opencode | AI coding agent | 見下方說明 |

## 選用（依開發語言）

| 套件 | 用途 | 安裝方式 |
|------|------|----------|
| python3 | Python LSP (pyright) | `apt install python3` |
| .NET SDK 6.0+ | C# 開發 (OmniSharp) | 見下方說明 |
| OmniSharp | C# LSP server（neovim） | 見下方說明 |
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

### Claude Code Plugins

`~/.claude/settings.json` 的 `enabledPlugins` 列出所有啟用的 plugins，但部署設定檔不會自動安裝它們，需手動執行以下指令：

```bash
claude plugin install code-simplifier@claude-plugins-official
claude plugin install superpowers@claude-plugins-official
claude plugin install code-review@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install commit-commands@claude-plugins-official
claude plugin install atlassian@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
claude plugin install skill-creator@claude-plugins-official
claude plugin install claude-code-setup@claude-plugins-official
claude plugin install vercel@claude-plugins-official
claude plugin install csharp-lsp@claude-plugins-official
claude plugin install clangd-lsp@claude-plugins-official
claude plugin install notion@claude-plugins-official
```

安裝後 `settings.json` 的 `enabledPlugins` 會自動生效，無需額外設定。

### .NET SDK

使用 Microsoft 官方 install script 安裝：

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 6.0
# 加入 PATH
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### OmniSharp

neovim 的 C# LSP server，需要先安裝 .NET SDK：

```bash
curl -L https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-linux-x64-net6.0.zip \
  -o /tmp/omnisharp.zip
mkdir -p ~/.omnisharp
unzip -o /tmp/omnisharp.zip -d ~/.omnisharp/
chmod +x ~/.omnisharp/OmniSharp
ln -sf ~/.omnisharp/OmniSharp ~/.omnisharp/omnisharp
```

> **注意**：neovim config 期望 binary 位於 `~/.omnisharp/omnisharp`，但 release zip 中的執行檔名為 `OmniSharp`（大寫 O），需建立 symlink。安裝後需在專案目錄執行一次 `dotnet build`（或 `dotnet restore`）讓 NuGet packages 還原，OmniSharp 才能正確解析專案。

### atuin

安裝後 binary 位於 `~/.atuin/bin/`，需重開 terminal 讓 `.bashrc` 自動載入：

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

`.bashrc` 依賴 `bash-preexec` 讓 atuin 攔截每次指令，需另外下載：

```bash
curl -sS https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

### opencode

需先安裝 node.js（via nvm）。透過 npm global 安裝：

```bash
npm install -g opencode@latest
```

安裝後執行 `make opencode` 會建立 `~/.config/opencode/commands` symlink，讓 opencode 與 Claude Code 共用相同指令集。

### oh-my-openagent（opencode 外掛）

需先安裝 bun runtime：

```bash
curl -fsSL https://bun.sh/install | bash
```

再執行安裝指令（依實際訂閱調整 flags）：

```bash
# Claude only
bunx oh-my-opencode install --no-tui --claude=no --gemini=no --copilot=yes
# 驗證安裝與設定
bunx oh-my-opencode doctor
```

安裝後會在 `~/.config/opencode/opencode.json` 的 `plugin` 陣列加入 `oh-my-openagent`。

內建 agents：
- **Sisyphus** — orchestrator，任務路由
- **Prometheus** — 規劃模式（Tab 鍵啟動）
- **Hephaestus** — 深度自主執行
- **Oracle** — 架構分析與除錯
- **Librarian** — 文件與程式碼搜尋
- **Explore** — codebase grep

在 prompt 加入 `ultrawork`（或縮寫 `ulw`）可啟動完整 agent 協作流程。

## 快速檢查

確認目前系統上已安裝哪些套件：

```bash
for cmd in bash git make nvim tmux jq curl fzf tig rg fd node python3 opencode; do
  command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd: NOT FOUND"
done
# atuin 安裝在 ~/.atuin/bin/，需開新 terminal 後才能用 command -v 查到
~/.atuin/bin/atuin --version &>/dev/null && echo "✓ atuin" || echo "✗ atuin: NOT FOUND"
# dotnet 安裝在 ~/.dotnet/，需開新 terminal 或 source ~/.bashrc 後才能用
~/.dotnet/dotnet --version &>/dev/null && echo "✓ dotnet" || echo "✗ dotnet: NOT FOUND"
# OmniSharp 安裝在 ~/.omnisharp/
~/.omnisharp/omnisharp --version &>/dev/null && echo "✓ omnisharp" || echo "✗ omnisharp: NOT FOUND"
# oh-my-openagent
bunx oh-my-opencode doctor &>/dev/null && echo "✓ oh-my-openagent" || echo "✗ oh-my-openagent: NOT INSTALLED"
```

確認 Claude Code plugins 是否已全部安裝：

```bash
for plugin in code-simplifier superpowers code-review context7 commit-commands \
              atlassian frontend-design skill-creator claude-code-setup vercel \
              csharp-lsp clangd-lsp notion; do
  claude plugin list 2>/dev/null | grep -q "$plugin" \
    && echo "✓ $plugin" || echo "✗ $plugin: NOT INSTALLED"
done
```
