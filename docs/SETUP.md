# 新機器建置指南

在全新 Linux 機器上的完整建置流程，請依序執行每個步驟。

---

## 1. Clone Repository 並安裝 dotfiles

```bash
git clone <your-dotfiles-repo-url> ~/dotfiles
cd ~/dotfiles
make install
```

確認 symlink 狀態：

```bash
make check
```

---

## 2. 系統套件

使用系統套件管理器安裝以下套件：

- `jq` — JSON 處理器（Claude Code statusline 必要）
- `tmux` — 終端機多工器
- `tig` — Git TUI 介面
- `ripgrep` — 快速 grep（Neovim Telescope 使用）
- `fzf` — 模糊搜尋（Tig 檔案選擇器使用）
- `fd` — 快速檔案搜尋（Neovim Telescope 使用）
- `curl` — HTTP 下載工具
- `git` — 版本控制
- `make` — 建置工具
- `bash-completion` — Bash tab 補全
- `python3` — 部分 LSP server 需要
- `sshpass` — 透過密碼 SSH（CNC 硬體控制腳本使用）

若系統套件版本過舊或不存在，`fzf` 可從 source 安裝：

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --bin
sudo ln -sf ~/.fzf/bin/fzf /usr/local/bin/fzf
```

若系統無 `fd` 套件，下載 musl 靜態 binary：

```bash
FD_VER=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name')
curl -L "https://github.com/sharkdp/fd/releases/download/${FD_VER}/fd-${FD_VER}-x86_64-unknown-linux-musl.tar.gz" \
  -o /tmp/fd.tar.gz
tar -xzf /tmp/fd.tar.gz -C /tmp/
sudo cp "/tmp/fd-${FD_VER}-x86_64-unknown-linux-musl/fd" /usr/local/bin/fd
```

---

## 3. nvm 與 Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
nvm alias default 22
```

> **注意**：GitHub Copilot 需要 Node.js 22+，請勿安裝舊版 LTS（如 20.x）。
> glibc < 2.28 的系統（如 Ubuntu 18.04）無法執行 Node.js v18+，最高只能安裝 v16，但將無法使用 GitHub Copilot。

驗證：

```bash
node --version
npm --version
```

---

## 4. bun runtime

```bash
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc
```

驗證：

```bash
bun --version
```

---

## 5. Neovim

若系統套件版本為 0.9+，可直接使用套件管理器安裝。否則從 GitHub 官方 release 安裝：

```bash
# glibc 2.28+（如 Ubuntu 22.04）— 使用 v0.10+，tarball 名稱為 nvim-linux-x86_64
curl -L https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-linux-x86_64.tar.gz \
  -o /tmp/nvim-linux64.tar.gz
sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt/
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

```bash
# glibc 2.17+（如 Ubuntu 18.04）— 最高只能裝 v0.9.x，tarball 名稱為 nvim-linux64
curl -L https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz \
  -o /tmp/nvim-linux64.tar.gz
sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt/
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
```

> **注意**：Neovim v0.10+ 需要 glibc 2.28+。Ubuntu 18.04（glibc 2.27）最高只能安裝 v0.9.x。

安裝後，開啟 Neovim 並安裝 plugins：

```bash
nvim +PlugInstall +qall
```

驗證：

```bash
nvim --version
```

---

## 6. atuin

atuin 是 shell history 管理工具，使用官方腳本安裝：

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
```

安裝 `bash-preexec`（atuin 攔截指令所需）：

```bash
curl -sS https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
```

開啟新 terminal 讓 atuin 生效（`.bashrc` 會自動載入）。

驗證：

```bash
~/.atuin/bin/atuin --version
```

---

## 7. opencode

需先安裝 Node.js（步驟 3）。透過 npm 全域安裝：

```bash
npm install -g opencode-ai@latest
```

建立設定 symlink（`opencode.json`、`package.json`、`commands/`）：

```bash
make opencode
```

> **注意**：`opencode.json` 宣告的 plugin（`@slkiser/opencode-quota`）將在首次啟動 opencode 時自動下載，無需手動執行 `npm install`。

驗證：

```bash
opencode --version
```

---

## 8. openspec

需先安裝 Node.js（步驟 3）。透過 npm 全域安裝：

```bash
npm install -g @fission-ai/openspec@latest
```

驗證：

```bash
openspec --version
```

---

## 9. Claude Code CLI 與 Plugins

安裝 Claude Code CLI：

```bash
npm install -g @anthropic-ai/claude-code
```

安裝 4 個 user-level plugins：

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install code-simplifier@claude-plugins-official
claude plugin install context7@claude-plugins-official
claude plugin install skill-creator@claude-plugins-official
```

驗證：

```bash
claude --version
claude plugin list
```

---

## 10. ~/.env 設定

複製範本並填入 credentials：

```bash
cp ~/dotfiles/env.example ~/.env
nano ~/.env
chmod 600 ~/.env
source ~/.bashrc
```

各變數說明請直接參考 `env.example` 中的註解。

---

## 11. 選用 — .NET SDK 與 OmniSharp（C# 開發）

### .NET SDK

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 6.0
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0
echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### OmniSharp（Neovim C# LSP）

需先安裝 .NET SDK（上方步驟）：

```bash
curl -L https://github.com/OmniSharp/omnisharp-roslyn/releases/latest/download/omnisharp-linux-x64-net6.0.zip \
  -o /tmp/omnisharp.zip
mkdir -p ~/.omnisharp
unzip -o /tmp/omnisharp.zip -d ~/.omnisharp/
chmod +x ~/.omnisharp/OmniSharp
ln -sf ~/.omnisharp/OmniSharp ~/.omnisharp/omnisharp
```

> **注意**：release zip 內的執行檔名為 `OmniSharp`（大寫 O），Neovim config 期望路徑為 `~/.omnisharp/omnisharp`，故需建立 symlink。
> 安裝後在 C# 專案目錄執行一次 `dotnet build`（或 `dotnet restore`），讓 NuGet 還原 packages，OmniSharp 才能正確解析專案。

---

## 12. 驗證

執行 `make check` 確認 symlink 狀態：

```bash
make check
```

確認所有必要工具已安裝：

```bash
for cmd in bash git make nvim tmux jq curl fzf tig rg fd node python3 opencode sshpass; do
  command -v $cmd &>/dev/null && echo "✓ $cmd" || echo "✗ $cmd: NOT FOUND"
done
# atuin 安裝在 ~/.atuin/bin/，需開新 terminal 或 source ~/.bashrc 後才能查到
~/.atuin/bin/atuin --version &>/dev/null && echo "✓ atuin" || echo "✗ atuin: NOT FOUND"
```

確認 Claude Code plugins 是否全部安裝：

```bash
for plugin in superpowers code-simplifier context7 skill-creator; do
  claude plugin list 2>/dev/null | grep -q "$plugin" \
    && echo "✓ $plugin" || echo "✗ $plugin: NOT INSTALLED"
done
```

確認選用工具（若有安裝）：

```bash
~/.dotnet/dotnet --version &>/dev/null && echo "✓ dotnet" || echo "✗ dotnet: NOT INSTALLED (optional)"
~/.omnisharp/omnisharp --version &>/dev/null && echo "✓ omnisharp" || echo "✗ omnisharp: NOT INSTALLED (optional)"
```
