#!/usr/bin/env bash
# Set @claude_state to "waiting" and send bell to notify user input required
# Skip if user is already on this window (no need to notify)
if [ -n "$TMUX" ]; then
    read -r window_active pane_tty <<< "$(tmux display-message -p -t "$TMUX_PANE" '#{window_active} #{pane_tty}' 2>/dev/null)"
    [ "$window_active" = "1" ] && exit 0
    tmux set-window-option -t "$TMUX_PANE" @claude_state "waiting" 2>/dev/null
    [ -n "$pane_tty" ] && printf '\a' > "$pane_tty"
fi
