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
        CURRENT_COMMIT="$2"

        # Detect uncommitted changes (empty or invalid commit)
        if [ -z "$CURRENT_COMMIT" ] || [ "$CURRENT_COMMIT" = "0000000000000000000000000000000000000000" ]; then
            # Handle uncommitted changes
            if [ ! -f "$MARK_FILE" ]; then
                # No commit marked - compare working directory with HEAD
                echo "Comparing uncommitted changes with HEAD"
                echo ""
                git difftool HEAD
            else
                # Commit is marked - compare working directory with marked commit
                MARKED_COMMIT=$(cat "$MARK_FILE")
                echo "Comparing uncommitted changes with marked commit:"
                echo "  Marked: $MARKED_COMMIT"
                echo ""
                git difftool "$MARKED_COMMIT"
            fi
        else
            # Handle normal commit
            if [ ! -f "$MARK_FILE" ]; then
                # No commit marked - show single commit diff with file selector
                tig-diff-selector "${CURRENT_COMMIT}^" "$CURRENT_COMMIT"
            else
                # Commit is marked - compare marked commit with current commit
                MARKED_COMMIT=$(cat "$MARK_FILE")

                echo "Comparing commits:"
                echo "  Marked:  $MARKED_COMMIT"
                echo "  Current: $CURRENT_COMMIT"
                echo ""

                # Launch interactive file selector
                tig-diff-selector "$MARKED_COMMIT" "$CURRENT_COMMIT"
            fi
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
