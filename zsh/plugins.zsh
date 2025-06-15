# ZSH-COMPLETIONS
autoload -Uz compinit
compinit

# enable completion script
fpath=(/usr/share/zsh/site-functions $fpath)

#AUTOSUGGESTIONS PLUGIN
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#ZSH-SYNTAX-HIGHLIGHTING PLUGIN
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#ZIM
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

typeset -g VI_PROMPT_MODE="%F{blue}[INSERT]%f"
function zvm_after_select_vi_mode() {
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)
      VI_PROMPT_MODE="%F{blue}[NORMAL]%f"
    ;;
    $ZVM_MODE_INSERT)
      VI_PROMPT_MODE="%F{blue}[INSERT]%f"
    ;;
    $ZVM_MODE_VISUAL)
      VI_PROMPT_MODE="%F{magenta}[VISUAL]%f"
    ;;
    $ZVM_MODE_VISUAL_LINE)
      VI_PROMPT_MODE="%F{magenta}[V-LINE]%f"
    ;;
    $ZVM_MODE_REPLACE)
      VI_PROMPT_MODE="%F{red}[REPLACE]%f"
    ;;
  esac

  zle reset-prompt  # refresh prompt
}

#NVM
source /usr/share/nvm/init-nvm.sh

runc() {
  local filename="${1%.c}"
  shift
  [[ -f "$filename.c" ]] || { echo "$filename.c not found"; return 1; }
  gcc "$filename.c" -o "$filename.out" && ./"$filename.out" "$@"
}

compdef '_files -g "*.c"' runc
