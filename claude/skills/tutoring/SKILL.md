---
name: tutoring
description: Use when explaining complex code, architectural concepts, or technical context that may be difficult to understand - provides detailed explanations, flow diagrams, and terminology clarification
---

# Tutoring Skill

當遇到複雜的程式碼、架構概念、或技術上下文時，使用這個 skill 提供清楚的教學式解釋。

## Overview

Tutoring skill 的核心原則：

1. **分層解釋**：從 high-level 概念開始，逐步深入到技術細節
2. **視覺化優先**：使用 ASCII diagrams 和結構化文字幫助理解
3. **術語明確**：遇到專有名詞立即解釋，建立 glossary
4. **實例驅動**：提供具體範例而非抽象描述
5. **終端友好**：所有內容都能在終端直接閱讀，不依賴外部工具

## When to Use

在以下情況自動啟用這個 skill：

- **複雜程式碼**：
  - 多層巢狀邏輯、callback hell、複雜的 data transformation
  - 使用進階語言特性（closure, decorator, metaclass 等）
  - 抽象度高的框架或 library 程式碼

- **架構與設計模式**：
  - 系統架構（microservices, event-driven, layered architecture）
  - 設計模式（factory, observer, strategy 等）
  - 協議與流程（OAuth flow, TCP handshake, consensus algorithm）

- **專業術語密集**：
  - 包含大量領域專有名詞（如 compiler 理論、network protocol、cryptography）
  - 需要背景知識才能理解的概念

- **多組件互動**：
  - 跨多個 service/module 的資料流
  - 複雜的狀態機或生命週期
  - 分散式系統的協調機制

- **用戶明確請求**：
  - 「這段程式碼在做什麼？」
  - 「可以解釋一下這個架構嗎？」
  - 「Flow 是怎麼運作的？」
  - 「這些術語是什麼意思？」

## Teaching Techniques

### 1. ASCII Diagrams（主要視覺化方式）

使用 box-drawing characters 創建清楚的圖表：

**可用字符**：
- 線條：`─ ═ │ ║`
- 角落：`┌ ┐ └ ┘ ╔ ╗ ╚ ╝`
- 交叉：`├ ┤ ┬ ┴ ┼ ╠ ╣ ╦ ╩ ╬`
- 箭頭：`▶ ◀ ▼ ▲ → ← ↓ ↑`

**適用情境**：

**A. 系統架構圖**
```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Frontend   │────▶│   Backend    │────▶│   Database   │
│   (React)    │◀────│  (Node.js)   │◀────│  (Postgres)  │
└──────────────┘     └──────────────┘     └──────────────┘
```

**B. 協議流程**
```
Client          Server          Database
  │               │                 │
  │─────GET /────▶│                 │
  │               │─────Query──────▶│
  │               │◀────Result──────│
  │◀────200 OK────│                 │
  │               │                 │
```

**C. 資料結構**
```
Linked List:
┌────┬────┐    ┌────┬────┐    ┌────┬────┐
│ 1  │ ───┼───▶│ 2  │ ───┼───▶│ 3  │ NULL│
└────┴────┘    └────┴────┘    └────┴────┘

Binary Tree:
       ┌─────┐
       │  5  │
       └─┬─┬─┘
    ┌────┘ └────┐
  ┌─┴─┐       ┌─┴─┐
  │ 3 │       │ 8 │
  └─┬─┘       └─┬─┘
  ┌─┘           └─┐
┌─┴─┐           ┌─┴─┐
│ 1 │           │ 9 │
└───┘           └───┘
```

**D. 狀態機**
```
     ┌──────┐
 ┌───│ IDLE │◀──┐
 │   └──────┘   │
 │ start()      │ reset()
 ▼              │
┌─────────┐     │
│ RUNNING │─────┘
└─────────┘
 │ stop()
 ▼
┌─────────┐
│ STOPPED │
└─────────┘
```

**E. 資料流**
```
Input → Parse → Validate → Transform → Output
         │         │           │
         ▼         ▼           ▼
       Error    Error       Error
         │         │           │
         └─────────┴───────────┘
                   │
                   ▼
              Error Handler
```

### 2. Structured Text Visualization

使用縮排和符號展示層級關係：

**A. Tree Structure**
```
project/
├── src/
│   ├── components/
│   │   ├── Header.tsx
│   │   └── Footer.tsx
│   ├── utils/
│   │   └── helpers.ts
│   └── App.tsx
├── tests/
│   └── App.test.ts
└── package.json
```

**B. Call Chain**
```
main()
  └─▶ init()
       ├─▶ loadConfig()
       │    └─▶ parseJSON()
       └─▶ setupDatabase()
            ├─▶ connect()
            └─▶ migrate()
```

**C. Data Hierarchy**
```
User
├─ id: string
├─ profile: Profile
│  ├─ name: string
│  ├─ email: string
│  └─ avatar: string
└─ settings: Settings
   ├─ theme: "light" | "dark"
   └─ notifications: boolean
```

**D. Numbered Steps**
```
Authentication Flow:
  1. User submits credentials
     → Frontend validates format
  2. Send to backend API
     → POST /api/login
  3. Backend queries database
     → SELECT * FROM users WHERE email = ?
  4. Verify password hash
     → bcrypt.compare(input, stored)
  5. Generate JWT token
     → jwt.sign({userId, role}, secret)
  6. Return token to client
     → {token, expiresIn}
```

### 3. Layered Explanation

從三個層次解釋概念：

**High-level（給非技術人員）**：
- 這個功能在做什麼？
- 為什麼需要它？
- 用日常生活類比

**Detail（給開發者）**：
- 主要組件和它們的職責
- 資料如何流動
- 關鍵的決策點

**Technical（給專家）**：
- 實作細節
- 演算法複雜度
- Edge cases 處理
- Trade-offs 分析

### 4. Terminology Glossary

遇到專有名詞時立即建立 glossary：

```
## Key Terminology

- **JWT (JSON Web Token)**: 一種用於驗證的 token 格式，包含 header、payload、signature
  Example: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

- **OAuth 2.0**: 授權框架，讓第三方應用能存取用戶資源，但不需要用戶密碼
  Flow: User → Auth Server → Client ← Resource Server

- **Middleware**: 在 request 和 response 之間執行的函數，常用於 logging、auth、validation
  Pattern: (req, res, next) => { ... next(); }
```

### 5. Code Walkthrough

逐段解釋程式碼，搭配 flow diagram：

```javascript
// 1. User input validation
function authenticate(email, password) {
  // 2. Check format
  if (!isValidEmail(email)) {
    throw new ValidationError("Invalid email");
  }

  // 3. Query database
  const user = await db.users.findOne({ email });

  // 4. Verify password
  if (!user || !await bcrypt.compare(password, user.passwordHash)) {
    throw new AuthError("Invalid credentials");
  }

  // 5. Generate token
  const token = jwt.sign(
    { userId: user.id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "1h" }
  );

  // 6. Return result
  return { token, userId: user.id };
}
```

**Flow Diagram**:
```
      Input
        │
        ▼
   ┌─────────┐
   │Validate │──Error─▶ Return 400
   └────┬────┘
        │ OK
        ▼
   ┌─────────┐
   │Query DB │
   └────┬────┘
        │
        ▼
  ┌──────────┐
  │Verify PW │──Error─▶ Return 401
  └────┬─────┘
       │ OK
       ▼
 ┌───────────┐
 │Generate   │
 │JWT Token  │
 └────┬──────┘
      │
      ▼
  Return 200
```

### 6. Before/After Comparisons

展示優化或重構的差異：

```
# Before (Callback Hell)
getData(function(a) {
  getMoreData(a, function(b) {
    getMoreData(b, function(c) {
      console.log(c);
    });
  });
});

# After (Async/Await)
const a = await getData();
const b = await getMoreData(a);
const c = await getMoreData(b);
console.log(c);
```

### 7. Table-based Comparison

使用表格對比選項：

```
┌────────────┬──────────────┬─────────────┬──────────────┐
│ Method     │ Performance  │ Complexity  │ Use Case     │
├────────────┼──────────────┼─────────────┼──────────────┤
│ Array.map  │ O(n)         │ Low         │ Transform    │
│ Array.for  │ O(n)         │ Low         │ Iteration    │
│ reduce     │ O(n)         │ Medium      │ Aggregate    │
│ recursion  │ O(n) + stack │ High        │ Tree/Graph   │
└────────────┴──────────────┴─────────────┴──────────────┘
```

### 不使用的格式（終端不友好）

❌ **Mermaid diagrams** - 終端無法渲染，需要外部工具
❌ **HTML slides** - 需要瀏覽器
❌ **圖片連結** - 無法在終端顯示
❌ **複雜的 Unicode art** - 可能在某些終端顯示異常

## Response Structure

按照以下結構組織回答：

### 1. Quick Summary（30 秒理解）
- 一句話總結這個概念/程式碼在做什麼
- 為什麼它存在/為什麼這樣設計

### 2. Detailed Explanation（分層解釋）
- **High-level**：整體架構和目的
- **Detail**：主要組件和流程
- **Technical**：實作細節和 trade-offs

### 3. Visual Aid（視覺化）
- **優先使用 ASCII diagram**（架構、流程、資料結構）
- 補充 structured text（tree, steps, hierarchy）
- 根據內容類型選擇最合適的表達方式

### 4. Key Terminology（關鍵術語）
- 列出所有專有名詞
- 提供簡潔定義和範例
- 必要時搭配小型 ASCII diagram

### 5. Examples（實例）
- 提供完整的 code example
- 展示典型使用情境
- 指出常見錯誤和最佳實踐

### 6. Further Reading（延伸閱讀，可選）
- 相關概念或進階主題
- 官方文檔連結
- 建議學習路徑

## Integration with User Settings

遵循 CLAUDE.md 的全局設定：

1. **語言規則**：
   - 使用繁體中文解釋概念
   - 技術術語保持英文（API, JWT, OAuth, middleware 等）
   - 程式碼註解使用英文

2. **溝通方式**：
   - 用平輩方式對話
   - 保持客觀理性
   - 不要揣測答案，如實解釋

3. **程式碼規範**：
   - 範例程式碼遵循觀察到的 coding style
   - 註解使用英文
   - 保持簡潔清楚

## Example: Full Tutoring Response

假設用戶問：「OAuth 2.0 flow 是怎麼運作的？」

---

### Quick Summary

OAuth 2.0 是一種授權框架，讓用戶可以授權第三方應用存取他們在其他服務（如 Google、GitHub）的資源，而不需要分享密碼。

### Detailed Explanation

**High-level**:
當你點擊「使用 Google 登入」時，OAuth 2.0 讓應用能向 Google 證明「用戶同意我存取他的資料」，而不需要知道用戶的 Google 密碼。

**Detail**:
主要涉及四個角色：
1. **Resource Owner** (用戶) - 擁有資料的人
2. **Client** (第三方應用) - 想要存取資料的應用
3. **Authorization Server** (授權伺服器) - 發放 token 的服務 (如 Google)
4. **Resource Server** (資源伺服器) - 存放資料的服務 (可能與授權伺服器相同)

**Technical**:
最常用的是 Authorization Code Flow，提供最佳安全性。流程包含 authorization code 和 access token 兩階段，避免 token 在瀏覽器暴露。

### Visual Aid

```
┌──────────┐                                      ┌──────────────┐
│          │  1. Authorization Request            │              │
│          │─────────────────────────────────────▶│              │
│          │                                       │              │
│  Client  │  2. User Login & Grant Permission    │ Authorization│
│  (App)   │     (Happens in browser)             │    Server    │
│          │                                       │   (Google)   │
│          │◀─────────────────────────────────────│              │
│          │  3. Authorization Code                │              │
└────┬─────┘                                      └──────┬───────┘
     │                                                   │
     │  4. Exchange Code for Token                      │
     │  (with client_secret)                            │
     │──────────────────────────────────────────────────▶│
     │                                                   │
     │◀──────────────────────────────────────────────────│
     │  5. Access Token                                  │
     │                                                   │
     │                                      ┌────────────┴────────┐
     │  6. Request Resource                 │   Resource Server   │
     │─────────────────────────────────────▶│   (Google Drive)    │
     │     (with access token)              │                     │
     │◀─────────────────────────────────────│                     │
     │  7. Protected Resource                └─────────────────────┘
     │
```

**Detailed Flow**:
```
Step 1: Authorization Request
  Client redirects user to:
  https://google.com/oauth/authorize?
    client_id=YOUR_CLIENT_ID&
    redirect_uri=https://yourapp.com/callback&
    response_type=code&
    scope=email%20profile

Step 2: User Login & Grant
  User logs in to Google
  User sees: "YourApp wants to access your email and profile"
  User clicks "Allow"

Step 3: Authorization Code
  Google redirects back to:
  https://yourapp.com/callback?code=AUTH_CODE_HERE

Step 4: Exchange Code for Token
  Client makes POST request to:
  https://google.com/oauth/token
  Body: {
    code: AUTH_CODE,
    client_id: YOUR_CLIENT_ID,
    client_secret: YOUR_SECRET,
    redirect_uri: https://yourapp.com/callback,
    grant_type: authorization_code
  }

Step 5: Access Token Response
  {
    access_token: "ya29.a0AfH6SMB...",
    token_type: "Bearer",
    expires_in: 3600,
    refresh_token: "1//0gLq..."
  }

Step 6: Access Protected Resource
  GET https://www.googleapis.com/drive/v3/files
  Header: Authorization: Bearer ya29.a0AfH6SMB...

Step 7: Resource Response
  {
    "files": [...]
  }
```

### Key Terminology

- **Authorization Code**: 短期有效的代碼，用於換取 access token。只能用一次，通常 10 分鐘過期。

- **Access Token**: 用於存取受保護資源的 token，通常 1 小時過期。

- **Refresh Token**: 長期有效的 token，用於在 access token 過期後取得新的 access token，避免用戶重新登入。

- **Scope**: 定義 client 可以存取的權限範圍，如 `email`, `profile`, `drive.readonly`。

- **Client ID / Client Secret**: 識別 client 應用的憑證。Client ID 是公開的，Client Secret 必須保密（只在後端使用）。

- **Redirect URI**: OAuth 完成後，Authorization Server 將用戶導回的 URL。必須事先在 OAuth provider 註冊。

### Examples

**Python Flask Example**:
```python
from flask import Flask, redirect, request, session
import requests

app = Flask(__name__)

# Configuration
CLIENT_ID = "your_client_id"
CLIENT_SECRET = "your_client_secret"
REDIRECT_URI = "http://localhost:5000/callback"
AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
TOKEN_URL = "https://oauth2.googleapis.com/token"

@app.route("/login")
def login():
    # Step 1: Redirect to authorization server
    params = {
        "client_id": CLIENT_ID,
        "redirect_uri": REDIRECT_URI,
        "response_type": "code",
        "scope": "email profile",
    }
    auth_url = f"{AUTH_URL}?{urlencode(params)}"
    return redirect(auth_url)

@app.route("/callback")
def callback():
    # Step 3: Receive authorization code
    code = request.args.get("code")

    # Step 4: Exchange code for token
    token_data = {
        "code": code,
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "redirect_uri": REDIRECT_URI,
        "grant_type": "authorization_code",
    }
    response = requests.post(TOKEN_URL, data=token_data)
    tokens = response.json()

    # Step 5: Store access token
    session["access_token"] = tokens["access_token"]

    return redirect("/profile")

@app.route("/profile")
def profile():
    # Step 6: Use access token to get user info
    access_token = session.get("access_token")
    headers = {"Authorization": f"Bearer {access_token}"}
    response = requests.get(
        "https://www.googleapis.com/oauth2/v1/userinfo",
        headers=headers
    )
    user_info = response.json()
    return f"Hello, {user_info['name']}!"
```

**Common Pitfalls**:
- ❌ 在前端存放 `client_secret`（會暴露給所有用戶）
- ❌ 不驗證 `state` parameter（容易受 CSRF 攻擊）
- ❌ 不設定 token 過期時間
- ❌ 使用 Implicit Flow（已不建議，改用 Authorization Code with PKCE）

### Further Reading

- **相關概念**: OpenID Connect (在 OAuth 2.0 上增加身份驗證)
- **進階主題**: PKCE (Proof Key for Code Exchange) - 提升 mobile/SPA 安全性
- **官方文檔**: [RFC 6749 - The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)

---

## Summary

這個 tutoring skill 幫助你在遇到複雜概念時：

1. **自動啟用**：當內容涉及架構、流程、專業術語時
2. **視覺化優先**：使用終端友好的 ASCII diagrams
3. **分層解釋**：從概念到實作，逐步深入
4. **術語明確**：建立 glossary，確保理解
5. **實例驅動**：提供完整範例和常見錯誤

**記住**：目標是讓用戶真正理解，而不只是提供資訊。選擇最合適的視覺化方式，搭配清楚的解釋和實例。
