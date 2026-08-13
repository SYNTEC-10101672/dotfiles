## REMOVED Requirements

### Requirement: /opsx:upgrade command 執行上游 skills 升級
**Reason**: OpenSpec 上游 skills/commands 近乎不再更新，此自動化升級流程已無實際使用價值。command 定義檔 (`claude/commands/opsx/upgrade.md`) 已刪除。
**Migration**: 若未來需要升級上游 OpenSpec 檔案，手動執行 `openspec init /tmp/upgrade-temp --tools claude` 後比對複製即可，不需自動化 command。

### Requirement: 自有客製化檔案不被覆蓋
**Reason**: 隨 `/opsx:upgrade` command 一併移除。排除清單只服務該 command 的複製流程，command 不存在即無適用場景。
**Migration**: 手動升級時自行注意不覆蓋 `claude/skills/openspec-tdd-verify/` 與 `claude/commands/opsx/tdd-verify.md`。

### Requirement: 顯示可讀的 diff 摘要
**Reason**: 隨 `/opsx:upgrade` command 一併移除。diff 摘要只服務該 command 的確認流程。
**Migration**: 手動升級時直接用 `diff -ru` 或 `vimdiff` 比對。
