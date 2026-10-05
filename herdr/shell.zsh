# herdr tab auto-naming: preexec renames the tab to the command's first
# word ("nvim config.toml" -> "nvim"); precmd renames it back to "shell"
# at the prompt; zsh/bash/sh always show "shell". A live label that
# differs from this shell's bookkeeping means a manual rename (e.g.
# prefix+shift+t), which locks auto-naming out until the tab closes.
# Sourced from .zshrc; self-guards on HERDR_TAB_ID so non-herdr shells
# sourcing this file return immediately with zero side effects.

[[ -n "$HERDR_TAB_ID" ]] || return 0

autoload -Uz add-zsh-hook

typeset -g _herdr_autoname_last=
typeset -g _herdr_autoname_locked=

_herdr_autoname_set() {
  emulate -L zsh
  local label=$1
  [[ -n "$label" ]] || return 0
  [[ -z "$_herdr_autoname_locked" ]] || return 0

  if [[ -n "$_herdr_autoname_last" ]]; then
    local current
    current=$(herdr tab get "$HERDR_TAB_ID" 2>/dev/null | jq -r '.result.tab.label // empty')
    # A non-numeric mismatch = manual rename (herdr's default labels for
    # new tabs are numeric, so those never trigger the lock).
    if [[ -n "$current" && "$current" != "$_herdr_autoname_last" && "$current" != <-> ]]; then
      _herdr_autoname_locked=1
      return 0
    fi
  fi

  herdr tab rename "$HERDR_TAB_ID" "$label" >/dev/null 2>&1
  _herdr_autoname_last=$label
}

_herdr_autoname_preexec() {
  emulate -L zsh
  local -a words
  words=(${(z)1})
  local word=$words[1]
  case $word in
    zsh|bash|sh) word=shell ;;
  esac
  _herdr_autoname_set "$word"
}

_herdr_autoname_precmd() {
  emulate -L zsh
  _herdr_autoname_set shell
}

add-zsh-hook preexec _herdr_autoname_preexec
add-zsh-hook precmd _herdr_autoname_precmd
