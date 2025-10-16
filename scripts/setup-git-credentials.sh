#!/bin/bash
# Git Credentials 自動設定腳本
#
# 功能：
#   1. 從 ~/.env 載入 GITLAB_TOKEN
#   2. 自動設定 ~/.git-credentials 供 Git credential helper 使用
#
# 使用方式：
#   ./scripts/setup-git-credentials.sh

set -e

echo "==================================="
echo "Git Credentials 設定工具"
echo "==================================="

# 載入環境變數
if [ -f ~/.env ]; then
    echo "✓ 載入 ~/.env"
    source ~/.env
else
    echo "✗ 錯誤: 找不到 ~/.env 檔案"
    echo "  請先執行: cp ~/dotfiles/env.example ~/.env"
    exit 1
fi

# 檢查必要的環境變數
if [ -z "$GITLAB_TOKEN" ]; then
    echo "✗ 錯誤: GITLAB_TOKEN 未設定"
    echo "  請在 ~/.env 中設定 GITLAB_TOKEN"
    exit 1
fi

if [ -z "$GIT_USER_NAME" ]; then
    echo "✗ 錯誤: GIT_USER_NAME 未設定"
    echo "  請在 ~/.env 中設定 GIT_USER_NAME"
    exit 1
fi

if [ -z "$GIT_USER_EMAIL" ]; then
    echo "✗ 錯誤: GIT_USER_EMAIL 未設定"
    echo "  請在 ~/.env 中設定 GIT_USER_EMAIL"
    exit 1
fi

echo "✓ 環境變數檢查完成"
echo ""

# 設定 Git 使用者資訊
echo "設定 Git 使用者資訊..."
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
echo "✓ Git 使用者: $GIT_USER_NAME <$GIT_USER_EMAIL>"
echo ""

# 設定 GitLab credentials
GITLAB_URL="https://gitlab.syntecclub.com"
CREDENTIALS_FILE=~/.git-credentials

echo "設定 GitLab credentials..."

# 建立或更新 credentials 檔案
# 格式: https://oauth2:TOKEN@gitlab.syntecclub.com
GITLAB_CREDENTIAL="https://oauth2:${GITLAB_TOKEN}@gitlab.syntecclub.com"

# 如果檔案存在，先備份
if [ -f "$CREDENTIALS_FILE" ]; then
    cp "$CREDENTIALS_FILE" "${CREDENTIALS_FILE}.backup"
    echo "✓ 已備份現有 credentials 到 ${CREDENTIALS_FILE}.backup"

    # 移除舊的 GitLab credential（如果有的話）
    grep -v "gitlab.syntecclub.com" "$CREDENTIALS_FILE" > "${CREDENTIALS_FILE}.tmp" || true
    mv "${CREDENTIALS_FILE}.tmp" "$CREDENTIALS_FILE"
fi

# 寫入新的 GitLab credential
echo "$GITLAB_CREDENTIAL" >> "$CREDENTIALS_FILE"

# 設定檔案權限（只有自己能讀寫）
chmod 600 "$CREDENTIALS_FILE"

echo "✓ GitLab credentials 已設定"
echo ""

# 驗證設定
echo "==================================="
echo "設定完成！"
echo "==================================="
echo ""
echo "Git 設定："
echo "  使用者: $(git config --global user.name)"
echo "  Email: $(git config --global user.email)"
echo ""
echo "GitLab 認證："
echo "  URL: $GITLAB_URL"
echo "  認證方式: OAuth2 Token"
echo ""
echo "你現在可以使用 HTTPS 方式 clone/push GitLab 專案了！"
echo ""
echo "範例："
echo "  git clone https://gitlab.syntecclub.com/your-group/your-repo.git"
