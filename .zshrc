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

# Zoxide
eval "$(zoxide init zsh)"

# Created by `pipx` on 2025-01-29 11:21:41
export PATH="$PATH:$HOME/.local/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

unsetopt CHASE_LINKS
