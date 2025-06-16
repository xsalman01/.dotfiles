# Prompt customization

# Enable prompt substitution
setopt PROMPT_SUBST



ZVM_CURSOR_STYLE_ENABLED=false

# Git branch info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats 'on %b'

# Left prompt: breadcrumb pat
PROMPT='${BG_FOAM} ${FG_TEXT}${VI_PROMPT_MODE}'\
' ${FOLDER_ICON} %~ ${RESET}${FG_PINE}${SEGMENT_SEPARATOR}${RESET}'\
'${vcs_info_msg_0_:+${FG_ROSE}${BRANCH_ICON} ${vcs_info_msg_0_}${RESET}}
 ${FG_GOLD}${PROMPT_SYMBOL} '
