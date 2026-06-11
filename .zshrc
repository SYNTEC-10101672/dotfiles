# ex: ts=2 sw=2 et filetype=zsh

# Enable Powerlevel10k instant prompt. Must stay at the very top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# PATH
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.omnisharp:$PATH"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$PATH"

# Locale and terminal
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export TERM='xterm-256color'

# Linux input method (fcitx)
if [[ "$OSTYPE" == linux* ]]; then
  export GTK_IM_MODULE=fcitx
  export QT_IM_MODULE=fcitx
  export XMODIFIERS=@im=fcitx
fi

# Aliases and optional env
source ~/.aliases
[[ -f ~/.env ]] && source ~/.env

# nvm
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# atuin
[[ -f "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# zsh completion
autoload -Uz compinit && compinit
setopt MENU_COMPLETE
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Plugins
[[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
  source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestions color (Gruvbox comment grey)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#928374'

# Powerlevel10k theme. Must stay at the bottom.
[[ -f ~/powerlevel10k/powerlevel10k.zsh-theme ]] && \
  source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
