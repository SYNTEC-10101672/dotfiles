# Delta Spec: skill-authoring-governance

## MODIFIED Requirements

### Requirement: explore mode 寫檔白名單

`opencode/commands/opsx/explore.md` SHALL 以白名單制規範 explore mode 的檔案寫入：僅允許寫入 OpenSpec artifacts（`openspec/changes/**`）與經 domain-modeling 程序 resolved 的 `CONTEXT.md`。Command 檔案 SHALL NOT 含有「"capturing thinking" 類比的模糊例外」或「未經程序即寫入 `CONTEXT.md`（如 right away）」的指示；此類指示與 "Don't auto-capture" guardrail 的矛盾 SHALL 被消除。

#### Scenario: 白名單文字存在

- **WHEN** 檢視 `opencode/commands/opsx/explore.md` 的寫檔規範段落（開頭 IMPORTANT 段與 Guardrails 段）
- **THEN** 該段落明列允許寫入的路徑（`openspec/changes/**` 與 `CONTEXT.md`），且不含 "that's capturing thinking, not implementing" 類比句與 "right away" 寫入指示

#### Scenario: 引導實作請求至 propose

- **WHEN** explore mode 中使用者要求直接修改 code（如「那你直接改一改」）
- **THEN** command 指示 AI 拒絕寫入並引導使用者執行 `/opsx:propose`，且此行為以對話範例（few-shot）形式呈現於 command 的 entry-point 範例區

### Requirement: CONTEXT.md 寫入須走 domain-modeling 程序

`opencode/commands/opsx/explore.md` 與 `opencode/commands/opsx/propose.md` 中所有涉及 `CONTEXT.md` 寫入的指示 SHALL 遵循一致程序：詞彙 crystallize 時 invoke `domain-modeling` skill（或至少先讀 `opencode/skills/domain-modeling/` 下的 `SKILL.md` 與 `CONTEXT-FORMAT.md`），經挑戰程序 resolved 後才寫入。兩個 command SHALL NOT 含有 "right away"、"immediately"、"Do not batch" 等繞過程序的寫入指示。

#### Scenario: explore command 程序指示

- **WHEN** 檢視 `opencode/commands/opsx/explore.md` 的 domain vocabulary 條目
- **THEN** 指示要求 invoke `domain-modeling` skill 走挑戰程序（challenge → resolve → write），而非直接寫入

#### Scenario: propose command 程序指示

- **WHEN** 檢視 `opencode/commands/opsx/propose.md` 的 domain vocabulary 條目
- **THEN** "immediately / right away / Do not batch" 字眼已移除，指示與 explore command 的程序一致

#### Scenario: grep 驗證舊字眼消除

- **WHEN** 在 `opencode/commands/opsx/explore.md` 與 `opencode/commands/opsx/propose.md` 內 grep `right away`、`immediately`、`Do not batch`
- **THEN** 兩檔案的 `CONTEXT.md` 寫入指示段落無這些字眼（非 CONTEXT.md 語境的其他用法不在此限）
