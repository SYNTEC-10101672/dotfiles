---
status: accepted
---

# matt skills 取代 openspec 為 spec-driven workflow

openspec 自 2026-04 起作為本 repo 的 spec-driven workflow（opsx 系列 commands、openspec-* skills、openspec CLI 與 `openspec/` 目錄），活躍期 2026-04~09，`changes/archive/` 累積 30+ 個 archived changes。matt 系列 skills 自 2026-07 起 vendor（初於 claude 配置引入，vendor 基準線記錄於 `opencode/VENDORED.md`），`.scratch/` local issue tracker 與 to-spec / to-tickets / implement-spec / wayfinder 上線後，spec → tickets → implementation 的迴路已由 matt 體系完整接手，遷移實質完成，openspec 只剩無人使用的工作流殘骸。決定：openspec 在本 repo 完全退役——`openspec/` 目錄（含 `changes/archive/`）、opsx 系列 commands、openspec-* skills、`handover` command 與 openspec CLI 安裝步驟一併移除，spec 工作流全面改用 matt pocock skill 體系，本 ADR 記錄這次遷移的最終收尾。

## Considered Options

- 保留 commit-gate plugin、只 revert `implement` command 的客製：拒絕——commit-gate 以 sessionID 為授權單位，gate 授權刻意不繼承給 subagents（subagent 各有自己的 sessionID、未經 `/commit` 授權），與 implement-spec 要求 implementer / merger subagents 直接執行 `git commit` 的並行流程結構性衝突：並行 commit 會全數被 gate 擋下，除非放棄「授權不繼承」的設計，兩者無法並存。
- 保留 `openspec/changes/archive/` 作為歷史文件：拒絕——git history 已完整保存一切，working tree 留 30+ 個 archived changes 只是搜尋噪音；仍在治理的規則已有活著的 home（決策在 ADR、vendor 基準在 `opencode/VENDORED.md`、詞彙在 `GLOSSARY.md`、agent 慣例在 `docs/agents/`），不必回 archive 考古。

## Consequences

- AI 的 `git commit` 恢復直接執行：implement-spec 的 implementer / merger subagents 並行 commit 不再被擋，防護由 Secret Guard（`guard.ts` 的 gitleaks staged 掃描、fail-closed）與 `git push` 的 ask-permission 繼續承擔；`implement.md` revert 回 upstream v1.3.1 原文，客製回到僅剝 frontmatter 的包裝層。
- session 交接定為兩層：拋棄式交接用 `handoff` command（交接文件存 OS temp dir，用完即丟），跨 session 的持久層是 issue tracker 的 `.scratch/` tickets；openspec 時代的 `handover`（HANDOVER.md）隨退役移除。
- openspec CLI 自新機器建置清單（`docs/SETUP.md`）移除，環境不再需要它。
