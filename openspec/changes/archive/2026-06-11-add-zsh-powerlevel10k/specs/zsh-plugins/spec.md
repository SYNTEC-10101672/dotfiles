## ADDED Requirements

### Requirement: zsh-autosuggestions 安裝並啟用

`zsh-autosuggestions` SHALL 以 git clone 方式安裝至 `~/.zsh/zsh-autosuggestions/`，並在 `.zshrc` 中載入。

#### Scenario: 補全提示顯示

- **WHEN** 使用者輸入指令前幾個字元
- **THEN** 灰色文字顯示 history 中最近相符的完整指令（Gruvbox comment grey `#928374`）

#### Scenario: 按右方向鍵接受補全

- **WHEN** 使用者按下右方向鍵或 `End`
- **THEN** 補全提示被接受，填入命令列

### Requirement: zsh-syntax-highlighting 安裝並啟用

`zsh-syntax-highlighting` SHALL 以 git clone 方式安裝至 `~/.zsh/zsh-syntax-highlighting/`，並在 `.zshrc` 中載入（必須在 autosuggestions 之後 source）。

#### Scenario: 有效指令顯示綠色

- **WHEN** 使用者輸入已存在的指令（如 `git`、`ls`）
- **THEN** 指令名稱顯示為綠色

#### Scenario: 無效指令顯示紅色

- **WHEN** 使用者輸入不存在的指令
- **THEN** 指令名稱顯示為紅色，即時提示錯誤

#### Scenario: 路徑顯示底線

- **WHEN** 使用者輸入存在的路徑作為參數
- **THEN** 路徑顯示底線標記

### Requirement: Plugins 安裝冪等

Makefile `zshrc` target SHALL 在 clone plugins 前確認目錄是否已存在，已安裝則跳過。

#### Scenario: 重複執行 make install 不報錯

- **WHEN** plugins 已安裝，再次執行 `make install`
- **THEN** 不重複 clone，不產生錯誤訊息
