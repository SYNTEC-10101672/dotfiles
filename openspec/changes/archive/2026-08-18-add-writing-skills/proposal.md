## Why

使用者的寫作場景有兩個：(1) 公司 CF 設計架構／設計理念文件（explanation 型），目前「隨便請 AI 寫」的流程無法把腦中真正的設計取捨（why）寫進成品；(2) 日常文件撰寫（筆記、技術隨筆等任何有論點的 writing）。mattpocock/skills 的三個 writing skills 提供 explore→exploit 寫作 pipeline（fragments 採訪挖料 → shape/beats 逐段組裝），同時覆蓋兩個場景。Upstream 為 MIT license 且位於 in-progress bucket（不進 plugin、隨時會變），必須 vendor copy 進 dotfiles 才能穩定使用。

## What Changes

- 從 `https://github.com/mattpocock/skills` main 分支 `skills/in-progress/` vendor 三個 skill 到 `dotfiles/claude/skills/`：
  - `writing-fragments/`（explore：grilling 採訪挖 fragments）
  - `writing-shape/`（exploit：線性逐段組稿）
  - `writing-beats/`（exploit：choose-your-own-adventure 逐 beat 組稿）
- 每個 skill 目錄包含 `SKILL.md` + `agents/openai.yaml`（與既有 vendor 慣例一致，不修改原檔）
- 透過既有 `~/.claude/skills/ → dotfiles/claude/skills/` symlink（`claude-config-symlink` capability）自動部署，無需其他設定

## Capabilities

### New Capabilities
- `writing-skills`: vendor 三個 mattpocock writing skills（writing-fragments、writing-shape、writing-beats）到 dotfiles Claude skills 目錄，保留 upstream 內容與 user-invoked 分類，並透過既有 symlink 部署。

### Modified Capabilities

（無 — 既有 `mattpocock-skills` spec 只規範 5 個 productivity/engineering skills 的存在與一致性，新增目錄不違反其 requirements。）

## Impact

- 新增檔案：`claude/skills/writing-fragments/`、`claude/skills/writing-shape/`、`claude/skills/writing-beats/`（共 6 個檔案：3×SKILL.md + 3×agents/openai.yaml）
- 不修改任何既有檔案
- 依賴既有 capability：`claude-config-symlink`（部署機制不變）
- License 義務：MIT（upstream repo LICENSE），vendor copy 合法
