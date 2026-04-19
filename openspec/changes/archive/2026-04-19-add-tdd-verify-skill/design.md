## Context

目前 `openspec-apply-change` skill 實作 task 後直接 mark `[x]`，沒有驗證步驟。驗收條件的定義與執行都缺席，導致「完成」只代表「程式碼寫了」，不代表「功能正常」。

此 change 採用最小介入策略：不修改現有 opsx skills，改以 CLAUDE.md 規則 + 新 skill 補強驗證環節。

## Goals / Non-Goals

**Goals:**
- tasks.md 產出時，每個 task 就帶有可執行的驗收條件
- 實作後有明確的驗證步驟，通過才算完成
- 無法自動驗證的情況有標準的注記方式

**Non-Goals:**
- 不修改 `openspec-apply-change` 或 `opsx:apply` 現有邏輯
- 不強制使用特定測試框架
- 不處理 CI/CD 整合

## Decisions

### 決策 1：驗證區塊格式用 `> 驗證：`

```markdown
- [ ] 實作 login API
  > 驗證：`npm test auth/login.test.ts` 全部通過
```

**理由**：blockquote 語法在 Markdown 視覺上與 task 描述明顯區隔，且不干擾 `- [ ]` checkbox 的解析。

替代方案考慮過：
- 用 comment `<!-- 驗證：... -->` → 不可見，難以追蹤
- 獨立的 `## 驗證` section → 與 task 脫鉤，對應關係不清楚

### 決策 2：新 skill 只負責驗證，不包含實作流程

`openspec-tdd-verify` 只做一件事：讀 `> 驗證` → 執行 → 回報結果。

**理由**：
- 保持 skill 單一職責，易於維護
- `opsx:apply` 實作完後呼叫，銜接自然
- CLAUDE.md 規則可強制這個順序

### 決策 3：TDD 規範放 CLAUDE.md，細節放 skill

CLAUDE.md 只寫「要做什麼」（2 條規則），skill 寫「怎麼做」（流程細節）。

**理由**：CLAUDE.md 每次都載入，適合放強制規範；skill 只在呼叫時載入，適合放操作細節。

## Risks / Trade-offs

- **CLAUDE.md 規則依賴 Claude 遵守** → 無法硬性阻止跳過驗證，但 CLAUDE.md 的強制性已足夠
- **`> 驗證` 格式需要 Claude 在產出 tasks.md 時自律遵守** → 靠 CLAUDE.md 規則約束，若缺少驗證區塊，`openspec-tdd-verify` 會暫停要求補上
- **驗證指令可能因環境不同而失敗** → 注記「無法自動驗證」是合法的 escape hatch

## Migration Plan

1. 修改 `claude/CLAUDE.md`，新增 OpenSpec 規範段落
2. 新增 `claude/skills/openspec-tdd-verify/SKILL.md`
3. 新增 `claude/commands/opsx/tdd-verify.md`
4. 無需 `make install`（skills/ 和 commands/ 已是整個目錄的 symlink）
