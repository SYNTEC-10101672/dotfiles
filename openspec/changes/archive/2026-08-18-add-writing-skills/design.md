# Design: add-writing-skills

## Context

- 使用者透過 `~/.claude/skills/ → /home/syntec/personal/dotfiles/claude/skills/` symlink（`claude-config-symlink` capability）部署 Claude skills，skill 進 dotfiles 即自動生效。
- 既有前例：`mattpocock-skills` change 已從同一 upstream repo vendor 5 個 skills（grill-me、grilling、writing-for-agents、domain-modeling、grill-with-docs），確立慣例：**vendor copy 不修改原檔**、附帶 `agents/openai.yaml` 一併複製、下一個 session 自動可用。
- Upstream 三個 writing skills 位於 `skills/in-progress/` bucket（beta：不進 plugin、無 docs page、可隨時變更或消失），每個目錄結構為 `SKILL.md` + `agents/openai.yaml`。
- Upstream license 為 MIT，vendor copy 合法。
- 使用場景：公司 CF explanation 文件 + 日常文件撰寫，兩者共用同一 pipeline；本 change 只負責 vendor 安裝，usage 是純採訪／組稿行為，不需要為日常寫作另做設定。

## Goals / Non-Goals

**Goals:**
- Vendor 三個 writing skills（`writing-fragments`、`writing-shape`、`writing-beats`）到 `dotfiles/claude/skills/`，內容與 upstream main 分支完全一致
- 透過既有 symlink 部署，下一個 Claude Code / opencode session 即可用 slash command（`/writing-fragments` 等）召喚
- 保留 upstream 的 user-invoked 分類（三者 frontmatter 皆為 `disable-model-invocation: true`）

**Non-Goals:**
- 不修改、不客製化 SKILL.md 內容（含不改 frontmatter；三者已有 `name` + `description`，與 oh-my-openagent 解析格式相容）
- 不改動既有 5 個 mattpocock skills 與其他 skills
- 不建立 CF 文件模板或 writing workflow 自動化（後續評估試用後再議）
- 不處理公司環境同步（dotfiles 是否同步到公司機器是既有部署機制的事）

## Decisions

### D1: Vendor copy（原封複製），不作 fork 改編

**選項**：(a) 原封 vendor copy；(b) fork 後改編成 CF 專用版。
**決定**：(a)。
**理由**：三者為 in-progress beta，未實際跑過就改編是瞎改。先原裝試用一輪（拿真實 CF explanation 文件跑 fragments→shape 全程），有需求再開新 change 做 CF 版改編。與 `mattpocock-skills` 的 vendor 慣例一致。

### D2: 檔案來源用 raw.githubusercontent.com 抓 main 分支

**選項**：(a) `curl raw.githubusercontent.com/mattpocock/skills/main/skills/in-progress/<skill>/...`；(b) `git clone` 整個 repo 再 copy。
**決定**：(a)。
**理由**：只需 6 個檔案，raw URL 直接、可驗證（frontmatter name 比對）。clone 整 repo（220k stars 的大型 repo）浪費。

### D3: 沿用既有 capability `mattpocock-skills` 的驗證模式

三個 skill 的驗證比照 `openspec/specs/mattpocock-skills/spec.md` 既有 scenario：檔案存在、內容與 upstream 一致（diff）、frontmatter 分類正確、symlink 透通。在新 capability `writing-skills` 的 spec 中重述這些 requirement（而非修改舊 spec，見 proposal）。

## Risks / Trade-offs

- [Upstream 為 in-progress bucket，可能變動或消失] → vendor copy 本身就是 freeze（這是 feature 不是 bug）；未來要更新時開新 change 重抓比對。
- [MIT license 標示] → upstream 要求保留 copyright notice；dotfiles 為私人使用且不重新散布，風險極低；不改原檔即已保留 upstream 內的一切標示。
- [SKILL.md frontmatter 與 oh-my-openagent 相容性] → 三者已有 `name` + `description` 欄位，與既有 13 個 skills 格式一致；部署後以 T* 驗證 symlink 透通即涵蓋。

## Migration Plan

1. 抓取 6 個檔案放入 `dotfiles/claude/skills/{writing-fragments,writing-shape,writing-beats}/`
2. 驗證（見 tasks T*）
3. Rollback：`rm -rf` 三個目錄即可，無其他副作用

## Open Questions

（無 — 試用後的改編需求留給未來 change。）
