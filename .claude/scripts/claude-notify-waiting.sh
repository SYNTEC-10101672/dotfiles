#!/usr/bin/env bash
# Set @claude_state to "waiting" and send bell to notify user input required
if [ -n "$TMUX" ]; then
    tmux set-window-option -t "$TMUX_PANE" @claude_state "waiting" 2>/dev/null
    pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
    [ -n "$pane_tty" ] && printf '\a' > "$pane_tty"
fi
