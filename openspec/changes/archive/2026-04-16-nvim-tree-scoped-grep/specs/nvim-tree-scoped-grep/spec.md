## ADDED Requirements

### Requirement: FF 在 nvim-tree 中搜尋游標所在目錄

當游標位於 nvim-tree buffer 時，按下 `FF` SHALL 以游標節點對應的目錄為範圍執行 Telescope live_grep，而非搜尋整個 cwd。

#### Scenario: 游標在目錄節點上
- **WHEN** 使用者在 nvim-tree buffer 中，游標停在一個目錄節點上，並按下 `FF`
- **THEN** Telescope live_grep 以該目錄的 absolute path 作為 `search_dirs` 開啟

#### Scenario: 游標在檔案節點上
- **WHEN** 使用者在 nvim-tree buffer 中，游標停在一個檔案節點上，並按下 `FF`
- **THEN** Telescope live_grep 以該檔案的父目錄作為 `search_dirs` 開啟

#### Scenario: 游標在一般 buffer 中
- **WHEN** 使用者的游標不在 nvim-tree buffer 中，按下 `FF`
- **THEN** Telescope live_grep 以整個 cwd 為範圍執行（維持現有行為）

#### Scenario: nvim-tree.api 無法載入
- **WHEN** `nvim-tree.api` require 失敗，使用者按下 `FF`
- **THEN** fallback 到全域 live_grep，不產生 error
