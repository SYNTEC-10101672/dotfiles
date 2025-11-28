#!/bin/bash
# Interactive file selector for git difftool
# Usage: tig-diff-selector.sh <commit1> <commit2>

# 設定 fzf 路徑
FZF_BIN="${HOME}/.fzf/bin/fzf"

# 如果 fzf 不在預設位置，嘗試從 PATH 找
if [ ! -f "$FZF_BIN" ]; then
    FZF_BIN=$(which fzf 2>/dev/null)
fi

# 檢查 fzf 是否可用
if [ -z "$FZF_BIN" ] || [ ! -x "$FZF_BIN" ]; then
    echo "Error: fzf not found. Please install fzf first."
    exit 1
fi

COMMIT1="$1"
COMMIT2="$2"

if [ -z "$COMMIT1" ] || [ -z "$COMMIT2" ]; then
    echo "Error: Two commits required"
    echo "Usage: $0 <commit1> <commit2>"
    exit 1
fi

# 記錄已查看的檔案和上次查看的檔案
VIEWED_FILES=()
LAST_VIEWED=""

# 主循環：持續顯示選單直到使用者按 ESC 退出
while true; do
    # 1. 收集檔案資訊並建立格式化列表
    TEMP_FILES=$(mktemp)
    TEMP_LIST=$(mktemp)
    TEMP_SORTED=$(mktemp)

    # 取得變更統計（added/deleted 行數）
    git diff --numstat "$COMMIT1" "$COMMIT2" > "$TEMP_FILES"

    # 取得變更狀態（M/A/D）並建立顯示列表
    git diff --name-status "$COMMIT1" "$COMMIT2" | while IFS=$'\t' read -r status old_filename new_filename; do
        # 處理 Rename/Copy 狀態（有兩個檔名）
        if [[ "$status" =~ ^[RC] ]]; then
            # Rename/Copy: old_filename 和 new_filename 都有值
            display_filename="$old_filename -> $new_filename"
            actual_filename="$new_filename"
        else
            # 其他狀態：只有一個檔名（在 old_filename 變數中）
            display_filename="$old_filename"
            actual_filename="$old_filename"
        fi

        # 從 numstat 找到對應的行數統計（使用實際檔名）
        stats=$(grep -F "$actual_filename" "$TEMP_FILES" | awk '{print $1 " " $2}')
        added=$(echo "$stats" | awk '{print $1}')
        deleted=$(echo "$stats" | awk '{print $2}')

        # 處理 binary 檔案（numstat 顯示為 "-"）
        if [ "$added" = "-" ]; then
            stat_display="[Binary]   "
        else
            stat_display=$(printf "+%-4s/%-4s" "$added" "$deleted")
        fi

        # 狀態符號轉換
        case "$status" in
            M) status_display="[M]" ;;
            A) status_display="[A]" ;;
            D) status_display="[D]" ;;
            R*) status_display="[R]" ;;
            C*) status_display="[C]" ;;
            *) status_display="[?]" ;;
        esac

        # 檢查是否已查看過此檔案
        viewed_mark="  "
        for viewed in "${VIEWED_FILES[@]}"; do
            if [ "$viewed" = "$actual_filename" ]; then
                viewed_mark="✓ "
                break
            fi
        done

        # 格式化顯示：標記 狀態 統計 | 顯示檔名 TAB 實際檔名
        # 使用 tab 作為分隔符，實際檔名隱藏不顯示
        printf "%s%s %s | %s\t%s\n" "$viewed_mark" "$status_display" "$stat_display" "$display_filename" "$actual_filename"
    done > "$TEMP_LIST"

    rm -f "$TEMP_FILES" "$TEMP_SORTED"

    # 檢查是否有檔案
    if [ ! -s "$TEMP_LIST" ]; then
        echo "No files changed between the two commits."
        rm -f "$TEMP_LIST"
        exit 0
    fi

    # 2. 使用 fzf 顯示選單
    # fzf 選項說明：
    #   --disabled: 禁用預設搜尋模式，j/k 可直接移動
    #   --bind: 按 / 進入搜尋模式，Ctrl-u 清除搜尋，q 退出
    #   --reverse: 反轉顯示（提示在上方）
    #   --cycle: 循環捲動
    #   --no-mouse: 禁用滑鼠以避免控制字符問題
    #   --with-nth=1: 只顯示第 1 欄（狀態、統計、顯示檔名），第 2 欄（實際檔名）隱藏
    #   全螢幕模式（移除 --height 參數）
    SELECTED=$(cat "$TEMP_LIST" | \
        "$FZF_BIN" \
            --disabled \
            --bind 'change:first,/:enable-search+clear-query,ctrl-u:clear-query' \
            --bind 'j:down,k:up,q:abort' \
            --prompt=">" \
            --header="j/k:move /:search Enter:select q/ESC:quit" \
            --reverse \
            --cycle \
            --no-mouse \
            --delimiter='\t' \
            --with-nth=1 \
            --color="fg:white,bg:black,hl:cyan,fg+:black,bg+:white,hl+:blue,info:green,prompt:cyan,pointer:cyan,marker:cyan,spinner:cyan,header:white")

    EXIT_CODE=$?
    rm -f "$TEMP_LIST"

    # 3. 處理使用者選擇
    if [ $EXIT_CODE -ne 0 ] || [ -z "$SELECTED" ]; then
        # 使用者按 ESC 或 Ctrl-C
        exit 0
    fi

    # 從選中的行中提取檔案路徑（用 tab 分隔符）
    # 格式：✓ [M] +2/-0 | display_filename TAB actual_filename
    # 提取第 2 個欄位（實際檔名）
    SELECTED_FILE=$(echo "$SELECTED" | cut -f2)

    # 記錄已查看的檔案
    # 檢查是否已在列表中
    already_viewed=false
    for viewed in "${VIEWED_FILES[@]}"; do
        if [ "$viewed" = "$SELECTED_FILE" ]; then
            already_viewed=true
            break
        fi
    done

    # 如果是新檔案，加入已查看列表
    if [ "$already_viewed" = false ]; then
        VIEWED_FILES+=("$SELECTED_FILE")
    fi

    # 記錄為上次查看的檔案
    LAST_VIEWED="$SELECTED_FILE"

    # 4. 執行 difftool 針對選定的檔案
    echo ""
    echo "Opening difftool for: $SELECTED_FILE"
    echo ""
    git difftool "$COMMIT1" "$COMMIT2" -- "$SELECTED_FILE"

    # 5. 看完後直接回到選單（不再詢問）
    # 繼續下一輪迴圈，再次顯示檔案列表
done
