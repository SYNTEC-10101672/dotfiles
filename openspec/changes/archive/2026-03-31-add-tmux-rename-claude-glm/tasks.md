## 1. 實作

- [x] 1.1 在 `.claude/scripts/claude-glm` 中加入 `tmux rename-window "claude-glm"`，以 `$TMUX` 檢查守衛，放在 `exec claude` 之前

## 2. 驗證

- [x] 2.1 確認在 tmux 中執行 `claude-glm` 時 window name 變為 "claude-glm"
- [x] 2.2 確認在 tmux 外執行 `claude-glm` 時行為不變
