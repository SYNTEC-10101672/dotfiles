#!/usr/bin/env bash
# Clear @claude_state when Claude starts processing, except for AskUserQuestion
if [ -n "$TMUX" ]; then
    tool_name=$(jq -r '.tool_name // empty' 2>/dev/null)
    [ "$tool_name" = "AskUserQuestion" ] && exit 0
    tmux set-window-option -t "$TMUX_PANE" @claude_state "" 2>/dev/null
fi
