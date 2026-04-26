---
name: "OPSX: Upgrade"
description: Upgrade upstream OpenSpec skills and commands to the latest version. Compares versions, shows diff summary, skips customized files.
category: Workflow
tags: [workflow, upgrade, maintenance]
---

自動升級上游 OpenSpec skills 與 commands 至最新版，保留自有客製化檔案。

**Steps**

1. **檢查目前版本與最新版本**

   執行以下指令取得目前 CLI 版本：
   ```bash
   openspec --version
   ```

   執行以下指令取得 npm 最新版本：
   ```bash
   npm view openspec version
   ```

   若版本相同：輸出「目前已是最新版（vX.Y.Z）」並結束。

2. **顯示升級計畫**

   列出版本資訊：
   - 目前版本：vX.Y.Z
   - 最新版本：vX.Y.Z

   列出 **排除清單**（保留，不更新）：
   - `claude/skills/openspec-tdd-verify/`（完全自有，上游無對應）
   - `claude/commands/opsx/tdd-verify.md`（完全自有，上游無對應）

3. **在 temp 目錄生成新版 skills**

   ```bash
   mkdir -p /tmp/openspec-upgrade-temp
   openspec init /tmp/openspec-upgrade-temp --tools claude
   ```

4. **比對差異，生成 diff 摘要**

   比對 `/tmp/openspec-upgrade-temp/.claude/skills/` 與 dotfiles 中現有 skills：
   - 排除清單內的檔案標示「（保留，不更新）」
   - 有實質內容差異的檔案列出差異行數
   - 只有版本號差異的檔案標示「版本號更新，無實質內容變更」

   使用 AskUserQuestion 顯示 diff 摘要，詢問使用者是否繼續升級。

5. **複製新版 skills 與 commands（跳過排除清單）**

   若使用者確認：

   ```bash
   # 複製 skills（排除 openspec-tdd-verify）
   for skill in openspec-apply-change openspec-archive-change openspec-bulk-archive-change \
     openspec-continue-change openspec-explore openspec-ff-change openspec-new-change \
     openspec-onboard openspec-propose openspec-sync-specs openspec-verify-change; do
     cp -r /tmp/openspec-upgrade-temp/.claude/skills/$skill/. <dotfiles>/claude/skills/$skill/
   done

   # 複製 commands（排除 tdd-verify.md）
   for cmd in apply.md archive.md bulk-archive.md continue.md explore.md ff.md \
     new.md onboard.md propose.md sync.md verify.md; do
     cp /tmp/openspec-upgrade-temp/.claude/commands/opsx/$cmd <dotfiles>/claude/commands/opsx/$cmd
   done
   ```

   若使用者取消：不做任何變更，結束。

6. **升級 CLI**

   ```bash
   npm install -g openspec
   ```

7. **回報升級結果**

   輸出：
   - 升級前後版本
   - 已更新的 skills/commands 清單
   - 保留未更新的自有檔案清單

**注意事項**
- dotfiles 路徑需根據實際環境判斷（通常為 `~/Projects/dotfiles` 或 `~/.dotfiles`）
- temp 目錄在升級後可手動清除：`rm -rf /tmp/openspec-upgrade-temp`
