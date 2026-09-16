# Tasks: merge-opsx-commands

合併手法（5 項機械調整）見 `design.md` D2；識別字原則見 D3；執行順序理由見 D4。所有路徑相對於 repo 根目錄 `~/personal/dotfiles`。

## 1. 合併 4 個 slash commands 內容

- [x] 1.1 改寫 `opencode/commands/opsx/explore.md`：保留現有 frontmatter（`OPSX: Explore`），將 `opencode/skills/openspec-explore/SKILL.md` 的 body（`---` frontmatter 之後全部）逐字合併至 frontmatter 之後；套用 D2 的 5 項機械調整（刪「Use the `openspec-explore` skill to run this workflow.」指向行、Input 段去重保留 skill 版、刪 `<!-- CUSTOM: ... -->` markers、`same skills directory` 措辭改 `opencode/skills/domain-modeling/`、不帶入 skill frontmatter 欄位）（→ T1, T4）
- [x] 1.2 改寫 `opencode/commands/opsx/propose.md`：同 1.1 手法，來源 `opencode/skills/openspec-propose/SKILL.md`，指向行為「Use the `openspec-propose` skill to run this workflow.」（→ T1, T4）
- [x] 1.3 改寫 `opencode/commands/opsx/apply.md`：同 1.1 手法，來源 `opencode/skills/openspec-apply-change/SKILL.md`，指向行為「Use the `openspec-apply-change` skill to run this workflow.」（→ T1, T4）
- [x] 1.4 改寫 `opencode/commands/opsx/archive.md`：同 1.1 手法，來源 `opencode/skills/openspec-archive-change/SKILL.md`，指向行為「Use the `openspec-archive-change` skill to run this workflow.」（→ T1, T4）

## 2. Helper skill description 識別字替換

- [x] 2.1 `opencode/skills/openspec-code-review/SKILL.md` frontmatter description：`Use when openspec-apply completes` → `Use when /opsx:apply completes`（僅此字串，其餘不動）（→ T4）
- [x] 2.2 `opencode/skills/openspec-artifact-review/SKILL.md` frontmatter description：`Use after openspec-propose completes` → `Use after /opsx:propose completes`（僅此字串，其餘不動）（→ T4）

## 3. 主 specs 前言段識別字更新（delta sync 不涵蓋的 prose 段）

主 specs 的 description 行（`# <name>` 下一行）與 `## Purpose` 段不是 requirement block，archive sync 不會改寫，須直接編輯。Requirement 塊的更新由本 change 的 delta specs 在 archive 時 sync，此階段不動。

- [x] 3.1 `openspec/specs/openspec-skill-command-parity/spec.md`：重寫 description 行與 Purpose 段——反映「commands 為 workflow 內容本體（單一真相來源）；`openspec-*` skills 僅存 helper 角色」並約束保留集合與 cross-reference 完整性（→ T6）
- [x] 3.2 `openspec/specs/spec-test-contract/spec.md`：description 行 `openspec-propose 與 openspec-apply-change 之間` → `/opsx:propose 與 /opsx:apply 之間`；Purpose 段同步（→ T6）
- [x] 3.3 `openspec/specs/self-contained-tasks/spec.md`：description 行 `規範 \`openspec-propose\` 產出` → `規範 \`/opsx:propose\` 流程產出`（→ T6）
- [x] 3.4 `openspec/specs/openspec-code-review/spec.md`：description 行 `被 \`openspec-apply\` 完成實作後自動觸發` → `被 \`/opsx:apply\` 完成實作後自動觸發`；Purpose 段的 `opsx:apply` 已是 slash form 不動（→ T6）
- [x] 3.5 `openspec/specs/artifact-review-gate/spec.md`：Purpose 段 `定義 \`openspec-propose\` 完成 artifacts 後` → `定義 \`/opsx:propose\` 流程完成 artifacts 後`（→ T6）

## 4. 刪除 4 個 entry skill 目錄

- [x] 4.1 刪除 `opencode/skills/openspec-explore/`、`opencode/skills/openspec-propose/`、`opencode/skills/openspec-apply-change/`、`opencode/skills/openspec-archive-change/` 四個目錄（排在 tasks 1 全數完成之後，見 design.md D4）（→ T2, T3）

## 5. 部署驗證

`~/.config/opencode/skills` 與 `~/.config/opencode/commands` 為指向 `dotfiles/opencode/` 對應目錄的 symlink（`Makefile` `opencode` target），repo 變更自動反映，無需重跑 make。

- [x] 5.1 驗證部署端（→ T5）

## 6. 煙霧測試

- [x] 6.1 開新的 opencode session，執行 `/opsx:explore`，確認 explore 模式指示直接送達（無 skill tool 轉載步驟），且 Guardrails 段完整（→ T7）

## Tests

- [x] T1: 4 個 commands 含 workflow 本體標記且無 skill 指向行
  > Command: `bash -c 'ok=1; grep -q "This is a stance, not a workflow" opencode/commands/opsx/explore.md || ok=0; grep -q "Fact Lookup - eliminate pronouns" opencode/commands/opsx/propose.md || ok=0; grep -q "TDD three-phase implementation flow" opencode/commands/opsx/apply.md || ok=0; grep -q "Assess delta spec sync state" opencode/commands/opsx/archive.md || ok=0; w=$(grep -lE "Use the .openspec-" opencode/commands/opsx/explore.md opencode/commands/opsx/propose.md opencode/commands/opsx/apply.md opencode/commands/opsx/archive.md | wc -l); echo "content_markers=$ok wrapper_lines=$w"'`
  > Expected: `content_markers=1 wrapper_lines=0`
- [x] T2: 4 個 entry skill 目錄不存在於 repo
  > Command: `ls opencode/skills/ | grep -cE "^openspec-(explore|propose|apply-change|archive-change)$"`
  > Expected: `0`
- [x] T3: helper skills 保留且總數正確
  > Command: `bash -c 'echo "openspec_helpers=$(ls opencode/skills/ | grep -cE "^openspec-(tdd-verify|code-review|artifact-review|sync-specs)$") total=$(ls opencode/skills/ | wc -l)"'`
  > Expected: `openspec_helpers=4 total=8`
- [x] T4: `opencode/` 內無舊流程名識別字殘留
  > Command: `grep -rE "openspec-(explore|propose|apply(-change)?|archive-change)" opencode/ | wc -l`
  > Expected: `0`
- [x] T5: 部署端經 symlink 同步
  > Command: `bash -c 'stale=$(ls ~/.config/opencode/skills/ | grep -cE "^openspec-(explore|propose|apply-change|archive-change)$"); body=$(grep -c "TDD three-phase implementation flow" ~/.config/opencode/commands/opsx/apply.md); echo "deploy_stale_skills=$stale deploy_apply_body=$body"'`
  > Expected: `deploy_stale_skills=0 deploy_apply_body=1`
- [x] T6: 7 個主 specs 前言段（`## Requirements` 之前）無舊識別字
  > Command: `bash -c 'n=0; for f in openspec/specs/openspec-skill-command-parity/spec.md openspec/specs/skill-authoring-governance/spec.md openspec/specs/spec-test-contract/spec.md openspec/specs/openspec-code-review/spec.md openspec/specs/self-contained-tasks/spec.md openspec/specs/glossary-maintenance/spec.md openspec/specs/artifact-review-gate/spec.md; do c=$(sed -n "1,/^## Requirements/p" "$f" | grep -cE "openspec-(explore|propose|apply(-change)?|archive-change)"); n=$((n+c)); done; echo "preamble_old_ids=$n"'`
  > Expected: `preamble_old_ids=0`
- [x] T7: 新 session 煙霧測試：`/opsx:explore` 指示直接送達
  > Note: manual verification
