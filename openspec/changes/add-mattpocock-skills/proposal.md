## Why

目前的 opsx:explore 是發散式探索，缺乏「嚴苛逼問到每個決策分支都 resolved」的收斂機制；需求想得不夠嚴謹就進入實作，常導致反覆修改。同時缺少兩個長期缺口：(1) 撰寫新 skill / 文件時的設計參考規範；(2) 跨 session 累積 shared glossary 的機制，讓 agent 每次都得重新理解專案術語。

mattpocock/skills repo 的 grill-me / grilling / writing-great-skills / domain-modeling 正好補這三個缺口，且 SKILL.md 格式與現有 openspec-* / tutoring skills 完全相容，可透過既有 `claude-config-symlink` 機制無縫接入。

## What Changes

- 新增 4 個 skill 到 `dotfiles/claude/skills/`（透過 vendor copy，不用 submodule / 不用 `npx skills` installer）：
  - `grill-me/`（user-invoked）：嚴苛逼問 session，定位為 `opsx:explore` 之後的驗證關卡
  - `grilling/`（model-invoked）：`grill-me` 的核心依賴，純 interview 邏輯
  - `writing-great-skills/`（user-invoked）：寫 skill 與文件的設計參考（progressive disclosure、information hierarchy、leading words 等）
  - `domain-modeling/`（model-invoked）：主動維護專案 `CONTEXT.md`（glossary only）與 `docs/adr/`（嚴格三條件才開）
- 不安裝其他 mattpocock skills（如 `grill-with-docs`、`teach`、`to-spec`、`implement`、`code-review` 等），理由：與既有 openspec workflow 重疊或目前無明確使用情境
- 不設定自動更新策略（手動重新 vendor 當需要新版時）

## Capabilities

### New Capabilities

- `mattpocock-skills`: 從 mattpocock/skills repo 挑選安裝 4 個 skill（grill-me、grilling、writing-great-skills、domain-modeling），作為 explore 後的嚴謹驗證、skill 撰寫參考、與 shared glossary 自動維護機制

### Modified Capabilities

無。本變更只新增檔案，不修改既有 spec 的行為。`claude-config-symlink` 的 symlink 機制不變，只是 `dotfiles/claude/skills/` 目錄下多了 4 個子目錄。

## Impact

- **檔案系統**：`dotfiles/claude/skills/` 新增 4 個子目錄（grill-me、grilling、writing-great-skills、domain-modeling），每個含一個 `SKILL.md`
- **即時生效**：透過 `~/.claude/skills/ → dotfiles/claude/skills/` symlink，opencode 下一個 session 即可使用
- **model-invoked 行為**：`grilling` 與 `domain-modeling` 的 description 會進入每個 session 的 context load，agent 偵測到對應情境時自動載入
- **CONTEXT.md 副作用**：`domain-modeling` 被觸發時會在當前 repo 懶建立 `CONTEXT.md` 與 `docs/adr/`。本變更不安裝 hook 強制讀取 CONTEXT.md（該策略屬於各專案自己的 CLAUDE.md / AGENTS.md 設定，非 dotfiles 層級職責）
- **與 openspec 邊界**：CONTEXT.md（root）與 `openspec/specs/`、`openspec/changes/` 檔案路徑不衝突；後續各專案可自行決定是否在 CLAUDE.md 加「session 開始讀 CONTEXT.md」指令
- **無 breaking change**：不修改、不刪除既有檔案
