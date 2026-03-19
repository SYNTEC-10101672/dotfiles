#!/usr/bin/env bash
# Send tmux bell to notify task completion via window-status-format conditional ✓
if [ -n "$TMUX" ]; then
    pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
    [ -n "$pane_tty" ] && printf '\a' > "$pane_tty"
fi
