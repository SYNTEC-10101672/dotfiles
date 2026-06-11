# Powerlevel10k configuration - lean style, Gruvbox dark colors, two-line layout.
# Run `p10k configure` to regenerate.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  autoload -Uz is-at-least && is-at-least 5.1 || return

  # Prompt mode: lean (no background color blocks)
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=none

  # Two-line prompt
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false

  # Left prompt segments (line 1)
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context        # SSH hostname
    dir            # current directory
    vcs            # git status
    newline        # separator between line 1 and line 2
    prompt_char    # ❯ on line 2
  )

  # Right prompt segments (line 1)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    command_execution_time   # duration > threshold
    time                     # current time
  )

  # --- dir ---
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#458588'           # Gruvbox blue
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#458588'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#458588'
  typeset -g POWERLEVEL9K_DIR_BACKGROUND=none
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80

  # --- vcs ---
  typeset -g POWERLEVEL9K_VCS_BACKGROUND=none
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#98971a'     # Gruvbox green
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#d79921'  # Gruvbox yellow
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#d65d0e' # Gruvbox orange
  typeset -g POWERLEVEL9K_VCS_CONFLICTED_FOREGROUND='#cc241d'
  typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#928374'
  # Show untracked files marker
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
  typeset -g POWERLEVEL9K_VCS_DIRTY_ICON='*'

  # --- prompt_char ---
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#98971a'  # green
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#cc241d' # red
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # --- command_execution_time ---
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#d65d0e'  # Gruvbox orange
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=none
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='duration'

  # --- time ---
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#928374'  # Gruvbox grey
  typeset -g POWERLEVEL9K_TIME_BACKGROUND=none
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # --- context (SSH) ---
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_CONTEXT_SSH_FOREGROUND='#d79921'   # Gruvbox yellow, visible when remote
  typeset -g POWERLEVEL9K_CONTEXT_SSH_BACKGROUND=none
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#cc241d'
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND=none
  # Only show context when SSH or root
  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

  # Separators (lean style: no powerline glyphs between segments)
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

  # Instant prompt: suppress warnings from tools that write to stdout on startup
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  # Hot reload: apply changes without restarting zsh
  (( ! $+functions[p10k] )) || p10k reload
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
