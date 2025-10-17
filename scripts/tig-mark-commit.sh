#!/bin/bash
# Tig commit marking helper script
# Usage: tig-mark-commit.sh <action> <commit>
#   action: mark | diff
#   commit: commit hash

MARK_FILE="/tmp/tig-marked-commit-${USER}"

case "$1" in
    mark)
        if [ -z "$2" ]; then
            echo "Error: No commit specified"
            exit 1
        fi
        echo "$2" > "$MARK_FILE"
        echo "Marked commit: $2"
        read -p "Press Enter to continue..."
        ;;

    diff)
        if [ -z "$2" ]; then
            echo "Error: No commit specified"
            exit 1
        fi

        CURRENT_COMMIT="$2"

        # Check if a commit is marked
        if [ ! -f "$MARK_FILE" ]; then
            # No commit marked - show single commit diff (original D key behavior)
            git difftool "${CURRENT_COMMIT}^!"
        else
            # Commit is marked - compare marked commit with current commit
            MARKED_COMMIT=$(cat "$MARK_FILE")

            echo "Comparing commits:"
            echo "  Marked:  $MARKED_COMMIT"
            echo "  Current: $CURRENT_COMMIT"
            echo ""

            # Launch vimdiff for all changed files between the two commits
            git difftool "$MARKED_COMMIT" "$CURRENT_COMMIT"
        fi
        ;;

    status)
        if [ -f "$MARK_FILE" ]; then
            MARKED_COMMIT=$(cat "$MARK_FILE")
            echo "Currently marked commit: $MARKED_COMMIT"
        else
            echo "No commit marked"
        fi
        read -p "Press Enter to continue..."
        ;;

    clear)
        rm -f "$MARK_FILE"
        echo "Cleared marked commit"
        read -p "Press Enter to continue..."
        ;;

    *)
        echo "Usage: $0 {mark|diff|status|clear} <commit>"
        exit 1
        ;;
esac
