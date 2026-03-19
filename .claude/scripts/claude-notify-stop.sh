#!/usr/bin/env bash
# Set @claude_state to "done" and send bell to notify task completion
# Skip if user is already on this window (no need to notify)
if [ -n "$TMUX" ]; then
    read -r window_active pane_tty <<< "$(tmux display-message -p -t "$TMUX_PANE" '#{window_active} #{pane_tty}' 2>/dev/null)"
    [ "$window_active" = "1" ] && exit 0
    tmux set-window-option -t "$TMUX_PANE" @claude_state "done" 2>/dev/null
    [ -n "$pane_tty" ] && printf '\a' > "$pane_tty"
fi
