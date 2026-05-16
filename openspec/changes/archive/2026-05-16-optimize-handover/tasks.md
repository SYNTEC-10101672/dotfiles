## 測試

- [x] T1 驗證 handover 偵測 active change
  > 指令：在 `openspec/changes/` 下建立測試用 change 目錄（含 proposal.md），執行 `/handover` 的偵測邏輯
  > 預期：正確偵測到 active change 並進入薄入口模式；移除後進入完整模式

- [x] T2 驗證 tasks.md 同步更新
  > 指令：模擬有 active change 的情境，tasks.md 中有 `[ ]` 項目，執行 handover 並確認勾選
  > 預期：已完成的 task 被精確替換為 `[x]`，未完成的不受影響

- [x] T3 驗證 design.md 追加決策
  > 指令：模擬有 active change 的情境，本次 session 有新決策，執行 handover
  > 預期：design.md 的 Decisions 區段末尾被追加新決策，原有內容不被覆蓋

- [x] T4 驗證薄入口模式 HANDOVER.md 結構
  > 指令：在薄入口模式下執行 handover，檢查產生的 HANDOVER.md
  > 預期：包含 active change 指標、session 簡述、進度、下一步、context 指引；總長度 ≤ 50 行

- [x] T5 驗證完整模式 HANDOVER.md 結構
  > 指令：在無 active change 的情況下執行 handover，檢查產生的 HANDOVER.md
  > 預期：包含 session 摘要、已完成工作、剩餘工作（P0/P1/P2）、決策、開放問題、下一步；不包含 Modified Files / Reference Commands / Dependencies

- [x] T6 驗證 CLAUDE.md 自動偵測規則
  > 指令：檢查 `.claude/CLAUDE.md` 中是否包含 HANDOVER.md 自動偵測規則
  > 預期：有一條規則指示 AI 在 session 開始時偵測 HANDOVER.md 並讀取

## 實作

- [x] 1.1 重寫 `claude/commands/handover.md`：加入 active change 偵測邏輯（`ls openspec/changes/*/proposal.md`），根據結果切換薄入口/完整模式（→ T1）

- [x] 1.2 在薄入口模式中加入 artifact 同步步驟：更新 tasks.md 勾選狀態（→ T2）、追加 design.md 決策（→ T3）、視需要更新 proposal.md

- [x] 1.3 撰寫薄入口模式的 HANDOVER.md 模板：active change 指標、session 簡述、進度、下一步、context 指引（→ T4）

- [x] 1.4 撰寫完整模式的 HANDOVER.md 模板：session 摘要、已完成工作、剩餘工作、決策、開放問題、下一步；移除冗餘區段（→ T5）

- [x] 1.5 在 `.claude/CLAUDE.md` 新增 HANDOVER.md 自動偵測規則（→ T6）

- [x] 1.6 處理多個 active change 的情境：詢問使用者要交接哪個 change（→ T1）
