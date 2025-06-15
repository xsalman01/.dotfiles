# Prompt customization

# Enable prompt substitution
setopt PROMPT_SUBST

# Symbols
PROMPT_SYMBOL="❯"
SEGMENT_SEPARATOR=""
FOLDER_ICON=""
BRANCH_ICON=""

# Colors using Rose Pine palette
RESET="%f%k"
FG_TEXT="%F{#e0def4}"
FG_ROSE="%F{#eb6f92}"
FG_PINE="%F{#31748f}"
BG_PINE="%K{#31748f}"
FG_FOAM="%F{#9ccfd8}"

ZVM_CURSOR_STYLE_ENABLED=false

# Git branch info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '%b'

# Left prompt: breadcrumb pat
PROMPT='${BG_PINE}${FG_TEXT} ${VI_PROMPT_MODE} ${FOLDER_ICON} %~ ${RESET}${FG_PINE}${SEGMENT_SEPARATOR}${RESET} '

# Right prompt: Git branch
RPROMPT='${vcs_info_msg_0_:+${FG_ROSE}${BRANCH_ICON} ${vcs_info_msg_0_}${RESET}}'

