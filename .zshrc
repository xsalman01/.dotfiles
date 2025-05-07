# zshrc

#COLORS
eval "$(dircolors -b ~/.config/.dircolors)"

# HISTORY
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=100
setopt autocd
bindkey -e

zstyle :compinstall filename '$HOME/.zshrc'

# ZSH-COMPLETIONS
autoload -Uz compinit
compinit

# enable completion script
fpath=(/usr/share/zsh/site-functions $fpath)

#AUTOSUGGESTIONS PLUGIN
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#ZSH-SYNTAX-HIGHLIGHTING PLUGIN
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#NVM
source /usr/share/nvm/init-nvm.sh

# ALIASES
alias sysup='sudo pacman -Syu'
alias yayup='yay -Syu'
alias venup='sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"'
alias spiceup='spicetify restore backup apply'
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

runc() {
  local filename="${1%.c}"
  shift
  [[ -f "$filename.c" ]] || { echo "$filename.c not found"; return 1; }
  gcc "$filename.c" -o "$filename.out" && ./"$filename.out" "$@"
}

compdef '_files -g "*.c"' runc

# ENV VARIABLES
export EDITOR=/usr/bin/nvim
export RANGER_LOAD_DEFAULT_RC=false

# Created by `pipx` on 2025-01-29 11:21:41
export PATH="$PATH:$HOME/.local/bin"
