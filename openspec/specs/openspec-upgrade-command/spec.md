## ADDED Requirements

### Requirement: /opsx:upgrade command 執行上游 skills 升級
`/opsx:upgrade` command SHALL 自動化上游 openspec skills 與 commands 的升級流程，包含版本比對、diff 確認、使用者同意後複製。

#### Scenario: 已是最新版
- **WHEN** 使用者執行 `/opsx:upgrade`，且目前 CLI 版本與 npm 最新版相同
- **THEN** command 回報「目前已是最新版（vX.Y.Z）」並結束，不做任何變更

#### Scenario: 有新版可升級
- **WHEN** 使用者執行 `/opsx:upgrade`，且 npm 有更新版本
- **THEN** command 顯示目前版本與最新版本，列出有實質內容差異的 skill/command 檔案清單，詢問使用者確認後繼續

#### Scenario: 使用者確認升級
- **WHEN** 使用者確認升級
- **THEN** command 升級 CLI（`npm install -g`），在 temp 目錄生成新版 skills，複製至 dotfiles（跳過自有客製化檔案），回報升級結果

#### Scenario: 使用者取消升級
- **WHEN** 使用者取消升級
- **THEN** command 不做任何變更並結束

### Requirement: 自有客製化檔案不被覆蓋
`/opsx:upgrade` command SHALL 維護一份排除清單，升級時跳過這些自有檔案，確保客製化內容不被上游版本覆蓋。

排除清單（初始）：
- `claude/skills/openspec-tdd-verify/`（完全自有，上游無對應）
- `claude/commands/opsx/tdd-verify.md`（完全自有，上游無對應）

#### Scenario: 複製新版 skills 時跳過自有檔案
- **WHEN** command 將新版 skills 複製至 dotfiles
- **THEN** 排除清單內的檔案維持原樣，不被新版覆蓋；其餘 skills 更新至新版

#### Scenario: 顯示 diff 摘要時標示自有檔案
- **WHEN** command 顯示升級 diff 摘要
- **THEN** 自有客製化檔案以「（保留，不更新）」標示，上游更新的檔案列出差異行數

### Requirement: 顯示可讀的 diff 摘要
`/opsx:upgrade` command SHALL 在使用者確認前顯示 diff 摘要，讓使用者了解此次升級的實際影響範圍。

#### Scenario: 無實質差異的檔案
- **WHEN** 某個 skill 的新版與目前版本除版本號外無其他差異
- **THEN** diff 摘要中標示「版本號更新，無實質內容變更」

#### Scenario: 有實質差異的檔案
- **WHEN** 某個 skill 的新版與目前版本有實質內容差異
- **THEN** diff 摘要中列出該檔案名稱與差異行數，讓使用者決定是否繼續
