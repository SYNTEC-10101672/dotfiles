## Context

目前 dotfiles 管理 bash 環境（`.bashrc`、`.bash_profile`、`.bash_prompt`），透過 Makefile symlink 安裝至三台機器：macOS（已是 zsh default）、Arch Linux、公司 Ubuntu Docker container。三台機器皆可自行控制，均有權限安裝 zsh。

## Goals / Non-Goals

**Goals**
- 以 zsh 取代 bash 作為三台機器的互動 shell
- 透過 Powerlevel10k lean style 提供一致且資訊豐富的 prompt
- 加入 zsh-autosuggestions 與 zsh-syntax-highlighting 提升 shell 使用體驗
- 統一由 dotfiles 管理，`make install` 一次搞定

**Non-Goals**
- 不引入 plugin manager（Oh-My-Zsh、Zinit 等）
- 不修改 shell scripts（`scripts/*.sh`、Makefile）的 shebang
- 不立即刪除 bash 設定檔（保留作為參考，待 zsh 穩定後再清理）

## Decisions

### D1：不用 plugin manager，改用直接 git clone

**選擇**：Makefile 在 `zshrc` target 內 clone p10k 與 plugins 到固定路徑，`.zshrc` 直接 source。

**替代方案**：
- Oh-My-Zsh：功能過重，啟動慢，引入大量不需要的框架
- Zinit：輕量但語法複雜，增加學習成本

**理由**：現有 dotfiles 風格是零依賴直接管理（沒有其他 package manager 管理 shell 設定），git clone 最一致。升級時 `git pull` 即可。

**安裝路徑**：
```
~/powerlevel10k/
~/.zsh/zsh-autosuggestions/
~/.zsh/zsh-syntax-highlighting/
```

### D2：p10k lean style，不用 classic powerline 色塊

**選擇**：`POWERLEVEL9K_MODE=nerdfont-v3`，lean style（無背景色塊），unicode 分隔符。

**理由**：prompt 出現在每行指令之間，滾動 scrollback 時色塊視覺噪音大。lean style 資訊清楚但不搶眼，符合現有 bash prompt 風格。

### D3：配色沿用 Gruvbox dark

**選擇**：所有 prompt 顏色取自 Gruvbox dark 色板。

| 元素 | 顏色 | Gruvbox 對應 |
|------|------|-------------|
| 路徑 | `#458588` | blue |
| git clean | `#98971a` | green |
| git dirty `*` | `#d79921` | yellow |
| git untracked `?` | `#d65d0e` | orange |
| 執行時間 | `#d65d0e` | orange |
| 時間 | `#928374` | grey |
| prompt `❯` 成功 | `#98971a` | green |
| prompt `❯` 失敗 | `#cc241d` | red |

**理由**：nvim 使用 gruvbox，tmux status bar 沿用 gruvbox 色調，三者視覺語言一致。

### D4：`.aliases` 共用，不複製

**選擇**：`.zshrc` 直接 `source ~/.aliases`，不另外維護 zsh 版本。

**理由**：`.aliases` 內容幾乎全是 POSIX 語法，zsh 直接相容。

### D5：Makefile 移除 `bashrc` from `install`，不刪除檔案

**選擇**：`install` target 改為只呼叫 `zshrc`，`bashrc` target 保留但不自動執行。

**理由**：遷移期間 bash 檔案作為參考，待三台機器驗證穩定後再統一刪除。

## Risks / Trade-offs

- **[Risk] Ubuntu container 未裝 zsh** → Makefile `zshrc` target 加入 OS 偵測提示，或在 README 補充安裝指令
- **[Risk] p10k 需要 Nerd Font** → 三台機器終端機須安裝 Nerd Font（macOS iTerm2/Ghostty、Linux terminal emulator）；已在 SETUP.md 補充
- **[Risk] plugin clone 失敗（網路問題）** → Makefile 加 `[ -d path ] || git clone`，已存在則跳過
- **[Trade-off] plugin 無自動更新** → 接受，需要時手動 `git pull`；好處是版本穩定可預期

## Migration Plan

1. dotfiles repo 新增 `.zshrc`、`.p10k.zsh`，更新 Makefile
2. macOS：直接 `make install`（已是 zsh）
3. Arch Linux：`sudo pacman -S zsh && chsh -s /usr/bin/zsh`，然後 `make install`
4. Ubuntu container：`sudo apt-get install -y zsh && chsh -s /usr/bin/zsh`，然後 `make install`
5. 各機器驗證 prompt 正常、aliases 有效、atuin/nvm 正常運作
6. 穩定後刪除 `.bashrc`、`.bash_profile`、`.bash_prompt` 及對應 Makefile target

**Rollback**：切回 bash 只需 `chsh -s /bin/bash`，bash 檔案仍在。

## Open Questions

- 無。設計已在 explore 討論中確認。
