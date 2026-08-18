## 1. settings.json — attribution 機械控制

- [x] 1.1 在 `claude/settings.json` 頂層加入 `"attribution": { "commit": "", "pr": "" }`（放在 `"alwaysThinkingEnabled"` 之後，依字母序），不加 `includeCoAuthoredBy`（DEPRECATED）
  > 驗證：T2

## 2. commit.md — 移除署名 trailer 與 dangling pointer

- [x] 2.1 `claude/commands/commit.md` :82 改為「**不添加 AI 署名 trailer**：commit message 不含任何 AI 署名（attribution 已由 settings.json 全域隱藏）」，移除「遵循 CLAUDE.md」引用（替換文字不可含 `Co-Authored-By` 字面字串，否則 T3 必 fail）
  > 驗證：T3
- [x] 2.2 `claude/commands/commit.md` :90-98 Phase 4 的 HEREDOC 範例移除 `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>` 行（含其上方空行），範例只留 `<commit message>`
  > 驗證：T3
- [x] 2.3 `claude/commands/commit.md` :104 「**遵循 CLAUDE.md 規則**：commit 前需經用戶確認」改為「**commit 前需經用戶確認**：展示 commit message 並經用戶同意後才執行」（:28 :32 的 style-check CLAUDE.md 引用保留，屬一般規範引用非 Git 規則）
  > 驗證：T3

## 3. CLAUDE.md — 刪 Git 規範 + 全檔 dedup

- [x] 3.1 將 `claude/CLAUDE.md` 全文替換為下方目標內容（56 行 → 41 行；每條保留規則可追溯原行，刪除行歸類：no-op / duplication / 移至 skill+settings）：

````markdown
# 系統設定

## 溝通原則

### 基本溝通
- 使用繁體中文，技術術語保持英文
- 用平輩方式對話，不用敬語
- 如果你認為是對的，請堅持立場並提供理由
- 預設簡短：短句、短段落，白話優先
- 大詞出現時，立刻用一句話解釋
- 要我決定時：最多 2 個選項 + 我會選哪個 + 為什麼
- 檔案路徑、指令、config 值保持原樣精確，不口語化
- OpenSpec artifacts（proposal、design、specs、tasks）使用繁體中文撰寫，技術術語保持英文
- 此原則只規範表達方式，不降低程式碼 / 計畫 / 驗證的精確度

### 釐清優先
- 不確定時停下來指出困惑點並發問，不要自行假設後悶頭實作。如果一個需求有兩種以上合理的解讀，先列出選項讓我選擇。
- 發現我的要求有更簡單的做法時，主動提出。不要因為我說了 A 就照做 A，如果 B 更好你應該說出來。

## 程式碼規範

### 讀後再改
- 程式碼註解使用英文
- 修改前先讀同目錄下至少一個相關檔案，識別慣例（欄位初始化、錯誤處理模式、命名規則），變更完全符合這些慣例。

### 精準與最小變更
- 每個變更行都應能追溯到需求。不做未要求的功能、抽象層或彈性配置；單次使用的程式碼不需要抽象化；不可能發生的場景不需要錯誤處理。
- 50 行能解決就不要寫 200 行。資深工程師會覺得過度複雜就簡化它。
- 無關的 dead code：提一下，不刪除。自己的變更造成的孤立 import / 變數 / 函式：清理，但只清理自己造成的。

## 執行原則
- 非簡單任務（超過 3 步或有不確定性）先列出計畫，每個步驟標注驗證方式。未經驗證不要宣告完成。
- 驗證方式優先用測試表達。把任務轉成可驗證的測試目標：fix bug → 先寫重現測試再修；add feature → 先寫驗證測試再實作；refactor → 確保前後測試都通過。
- 修改既有行為時，先確認修改前的行為（讀 code 或跑測試），修改後再驗證。不要只在腦中推理「應該對了」。
- 明確的成功標準讓你能獨立迭代到完成。模糊的標準（「讓它 work」）則需要不斷來回確認。
- 簡單任務（typo、one-liner、明顯修飾）可依判斷放寬上述要求。準則偏重謹慎勝於速度，但對明顯簡單的事不必走完整流程。

## 領域知識規範
- 開工前，若 repo 根目錄存在 `CONTEXT.md`，先讀取其內容；不存在則靜默繼續，不報錯、不建議建立。
- 輸出（issue 標題、test 名稱、refactor 提案、hypothesis）使用 `CONTEXT.md` 定義的詞彙，不漂移到同義詞。
- 若 repo 根目錄有 `CONTEXT-MAP.md`，讀取後找出與當前主題相關的 per-context `CONTEXT.md`
````

  行號追溯表（原檔 → 處置）：
  - L6-L14 基本溝通：L8「保持客觀理性，不要揣測我想聽什麼答案」刪（anti-sycophancy 與 L9 一義，留正面句）；其餘逐行保留；原 L22 文件規範摺入為 bullet
  - L17-L19 釐清優先：L17 與 L19 合併為一條（不確定 → 指出困惑點 → 問）；L18 保留
  - L27-L28 讀後再改：L28 刪「讀取正在修改的檔案」半句（Edit/Write tool 機械強制），保留慣例識別
  - L31-L38：原「精準產出」「最小變更」兩節合併為「精準與最小變更」；L35「不要順手重構…」L36「不要重構沒壞的…」由「可追溯到需求」涵蓋；L37 L38 保留
  - L41-L45 執行原則：逐字保留
  - L48-L50 Git 規範：整節刪（Conventional Commits → commit.md；確認 → commit.md 流程 + permission；署名 → settings.json attribution）
  - L53-L56 領域知識：L53 與 L56 的「不存在時靜默繼續」語義合併進 bullet 1；L54 L55 保留
  > 驗證：T1、T4

## 4. 部署與載入驗證

- [x] 4.1 執行 `make claude` 確認 symlink 不變（內容變更經既有 symlink 自動生效），`readlink ~/.claude/CLAUDE.md` 仍指向 repo 檔案
  > 驗證：T5

## Tests

- [x] T1: CLAUDE.md 不含 Git 規範段落與規則行
  > Command: `! grep -nE "Git 規範|Conventional Commits|署名|commit 前需" claude/CLAUDE.md`
  > Expected: grep 無輸出（exit code 1），整個指令 exit 0
- [x] T2: settings.json 含 attribution 且 JSON 合法
  > Command: `python3 -c "import json; d=json.load(open('claude/settings.json')); a=d['attribution']; assert a['commit']=='' and a['pr']=='' and 'includeCoAuthoredBy' not in d; print('OK')"`
  > Expected: `OK`
- [x] T3: commit.md 無署名 trailer、無「遵循 CLAUDE.md」pointer
  > Command: `! grep -nE "Co-Authored-By|遵循 CLAUDE" claude/commands/commit.md`
  > Expected: grep 無輸出（exit code 1），整個指令 exit 0
- [x] T4: CLAUDE.md dedup 生效（合併段落存在、舊段落與 no-op 半句消失、領域知識語義保留）
  > Command: `grep -c "### 精準與最小變更" claude/CLAUDE.md && ! grep -qE "### 精準產出|### 最小變更|讀取正在修改的檔案|保持客觀理性|## 文件規範|## Git 規範" claude/CLAUDE.md && [ $(grep -c "CONTEXT.md" claude/CLAUDE.md) -ge 3 ] && echo PASS`
  > Expected: `1` 換行後 `PASS`
- [x] T5: symlink 部署指向 repo
  > Command: `readlink -f ~/.claude/CLAUDE.md | grep -q "personal/dotfiles/claude/CLAUDE.md" && echo LINKED`
  > Expected: `LINKED`
