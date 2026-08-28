# Delta Spec: dotfiles-install

## ADDED Requirements

### Requirement: Makefile 禁止 backup/restore/clean target

Makefile SHALL NOT 提供 `backup`、`restore`、`clean` 三個 target。`install` target SHALL 直接執行各模組安裝，不建立備份目錄。

#### Scenario: make install 不自動備份
- **WHEN** 執行 `make install`
- **THEN** 系統直接安裝各模組，不建立備份目錄

#### Scenario: make help 不顯示 backup 相關指令
- **WHEN** 執行 `make help`
- **THEN** 輸出中不包含 backup、restore、clean 指令
