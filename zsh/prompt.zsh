# Prompt customization

# Enable prompt substitution
setopt PROMPT_SUBST


ZVM_CURSOR_STYLE_ENABLED=false

# Git branch info
autoload -Uz vcs_info
precmd() { 
    vcs_info
    print ""
}
zstyle ':vcs_info:git:*' formats 'on %B%b'

# Get directory display component
function get_dir_display() {
    if [[ "$PWD" == "/" ]]; then
        echo "%B${FOLDER_ICON}%b"
    else
        echo "%B${FOLDER_ICON}${${PWD/#$HOME//}//\//${PATH_SEPARATOR}}%b"
    fi
}

PROMPT='${VI_PROMPT_MODE}${FG_LOVE}${BACKWARD_SEPARATOR}${BG_LOVE}${FG_SURFACE}'\
'${VIRTUAL_ENV:+ %B(${ENV_ICON} ${${VIRTUAL_ENV##*/}})}%b $(get_dir_display) '\
'${RESET}${FG_LOVE}${FORWARD_SEPARATOR}${RESET}'\
'${vcs_info_msg_0_:+${FG_PINE}${BACKWARD_SEPARATOR}${BG_PINE}${FG_GOLD} '\
'${BRANCH_ICON} ${vcs_info_msg_0_} ${RESET}${FG_PINE}${FORWARD_SEPARATOR}${RESET}}

${FG_GOLD}${PROMPT_SYMBOL} '
