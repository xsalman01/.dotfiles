# zshrc

# Source config files
for file in ~/.dotfiles/zsh/*.zsh; do
    source "$file"
done

#COLORS
eval "$(dircolors -b ~/.config/.dircolors)"

# HISTORY
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100
setopt autocd

zstyle :compinstall filename '$HOME/.zshrc'

# TMUX symlink fix
autoload -U add-zsh-hook

function set_tmux_pwd() {
    [[ -n "$TMUX" ]] || return 0
    local pane_id=$(tmux display -p "#D" 2>/dev/null)
    [[ -n "$pane_id" ]] || return 0
    pane_id=${pane_id//\%/}
    tmux setenv "TMUXPWD_${pane_id}" "$PWD" &>/dev/null
}

add-zsh-hook chpwd set_tmux_pwd
set_tmux_pwd

# ZOXIDE
eval "$(zoxide init zsh)"

# Created by `pipx` on 2025-01-29 11:21:41
export PATH="$PATH:$HOME/.local/bin"

unsetopt CHASE_LINKS
