#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
REPO_URL="https://github.com/xsalman01/.dotfiles.git"
DOTFILES_TARGET="$HOME/.dotfiles"
SUBMODULES=(rosepine_gtk/gtk)

SHARED_OFFICIAL=(
    zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting
    tmux neovim btop fd ripgrep fzf jq tree trash-cli fastfetch
    yazi zoxide tree-sitter-cli mpv cava
    pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber playerctl
    kitty
    ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
    noto-fonts-cjk noto-fonts-emoji otf-font-awesome woff2-font-awesome
    vimix-cursors nwg-look nvm ffmpeg imagemagick resvg 7zip rsync
    inotify-tools python-libtmux python-dbus python-gobject python-xlib
    python-requests python-pipx unclutter wget unzip poppler loupe
)

SHARED_AUR=(zsh-vi-mode xremap-x11-bin pwvucontrol)

I3_OFFICIAL=(
    i3-wm xss-lock xbindkeys xdotool feh picom polybar dex flameshot
    rofi rofimoji network-manager-applet lxappearance xclip
    xorg-server xorg-xinit xorg-xrandr xorg-xrdb xorg-xinput xorg-xev
    xorg-xmodmap xorg-xkill xorg-xcursorgen
)

I3_AUR=(i3lock-color zscroll-git rofi-bluetooth-git xborder-git rofi-greenclip)

HYPR_OFFICIAL=(
    hyprland hypridle hyprpicker hyprshot uwsm
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    qt5-wayland qt6-wayland qt5-svg qt5-multimedia qt5-imageformats
    qt6-5compat qt6-imageformats qt6-multimedia qt6-shadertools
    wtype wlr-randr wlsunset wl-clipboard satty cliphist xorg-xwayland
)

HYPR_AUR=(noctalia-shell)

HOME_SHARED=(.zshrc .zprofile .tmux.conf .dircolors)
HOME_I3=(.xinitrc .Xresources)

CFG_SHARED=(btop cava kitty lazydocker mpv nvim yazi tmux-sessionizer gtk-3.0 gtk-4.0 xremap)
CFG_I3=(i3 polybar rofi flameshot xborders)
CFG_HYPR=(hypr noctalia satty cliphist)

INSTALL_I3=0
INSTALL_HYPR=0

print_banner() {
    cat <<'BANNER'
   ____  ____  ____  __  ____  ____
  (  _ \(  __)(_  _)/  \(  _ \(_  _)
   )   / ) _)   )( ( () ))   /  )(
  (_)\_)(____) (__) \__//(_)\_) (__)
  dotfiles installer - i3 / Hyprland
BANNER
}

preflight() {
    echo ":: Pre-flight checks"
    if ! command -v pacman >/dev/null 2>&1; then
        echo "   ERROR: pacman not found - this script targets Arch Linux only." >&2
        exit 1
    fi
    if ! command -v git >/dev/null 2>&1; then
        echo "   ERROR: git not found - install git before running this script." >&2
        exit 1
    fi
    if ! command -v yay >/dev/null 2>&1; then
        echo "   ERROR: yay not found - required for AUR package installation." >&2
        echo "          Install it first:" >&2
        echo "            git clone https://aur.archlinux.org/yay.git /tmp/yay" >&2
        echo "            cd /tmp/yay && makepkg -si" >&2
        exit 1
    fi
    echo "   pacman, git, yay - all present."
}

setup_repo() {
    echo
    echo ":: Dotfiles repository"
    if git -C "$DOTFILES_TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "   [skip] repo already cloned at $DOTFILES_TARGET"
        DOTFILES="$DOTFILES_TARGET"
        git -C "$DOTFILES" pull --ff-only 2>/dev/null \
            && echo "   [done] pulled latest changes." \
            || echo "   [warn] could not pull (local changes or no upstream) - continuing."
    else
        echo "   [clone] $REPO_URL -> $DOTFILES_TARGET"
        git clone "$REPO_URL" "$DOTFILES_TARGET"
        DOTFILES="$DOTFILES_TARGET"
        echo "   [done] repo cloned."
        if [[ "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")" != "$DOTFILES" ]]; then
            echo "   [info] re-executing script from cloned repo..."
            exec bash "$DOTFILES/install.sh" "$@"
        fi
    fi
}

select_route() {
    echo
    echo ":: Select installation route"
    echo "   1) i3 (X11) only"
    echo "   2) Hyprland (Wayland) only"
    echo "   3) Both"
    echo "   4) Exit"
    read -rp "   Choice [1-4]: " choice
    case "$choice" in
        1) INSTALL_I3=1; INSTALL_HYPR=0 ;;
        2) INSTALL_I3=0; INSTALL_HYPR=1 ;;
        3) INSTALL_I3=1; INSTALL_HYPR=1 ;;
        4) echo "   Exiting."; exit 0 ;;
        *) echo "   Invalid choice - exiting."; exit 1 ;;
    esac
    echo "   i3=$INSTALL_I3  hypr=$INSTALL_HYPR"
}

install_packages() {
    echo
    echo ":: Installing packages (official repositories)"

    local -a official=("${SHARED_OFFICIAL[@]}")
    [[ "$INSTALL_I3" -eq 1 ]] && official+=("${I3_OFFICIAL[@]}")
    [[ "$INSTALL_HYPR" -eq 1 ]] && official+=("${HYPR_OFFICIAL[@]}")

    sudo pacman -S --needed -- "${official[@]}"

    echo
    echo ":: Installing packages (AUR via yay)"

    local -a aur=("${SHARED_AUR[@]}")
    [[ "$INSTALL_I3" -eq 1 ]] && aur+=("${I3_AUR[@]}")
    [[ "$INSTALL_HYPR" -eq 1 ]] && aur+=("${HYPR_AUR[@]}")

    yay -S --needed -- "${aur[@]}"
}

setup_submodules() {
    echo
    echo ":: Git submodules"
    local sub
    for sub in "${SUBMODULES[@]}"; do
        if [[ -e "$DOTFILES/$sub/.git" ]]; then
            echo "   [pull] $sub (already initialised - pulling latest)"
            git -C "$DOTFILES/$sub" pull --ff-only 2>/dev/null \
                && echo "   [done] $sub updated." \
                || echo "   [warn] could not pull $sub (maybe detached HEAD) - continuing."
        else
            echo "   [init] $sub (not yet initialised)"
            git -C "$DOTFILES" submodule update --init "$sub" \
                && echo "   [done] $sub initialised." \
                || echo "   [warn] failed to init $sub - continuing."
        fi
    done
}

setup_tpm() {
    echo
    echo ":: Tmux Plugin Manager (TPM)"
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ -d "$tpm_dir" ]]; then
        echo "   [skip] TPM already present at $tpm_dir"
    else
        mkdir -p "$HOME/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
        echo "   [done] TPM cloned to $tpm_dir"
    fi
}

link() {
    local src="$1" dst="$2"
    local current=""
    current="$(readlink "$dst" 2>/dev/null || true)"
    if [[ -L "$dst" && "$current" == "$src" ]]; then
        echo "   [skip] $dst (already -> $src)"
        return 0
    fi
    if [[ -e "$dst" || -L "$dst" ]]; then
        local bak="${dst}.bak.${TIMESTAMP}"
        echo "   [bak]  $dst -> $bak"
        mv "$dst" "$bak"
    fi
    ln -s "$src" "$dst"
    echo "   [link] $dst -> $src"
}

setup_symlinks() {
    echo
    echo ":: Creating symlinks"
    mkdir -p "$HOME/.config"

    echo "   -- home dotfiles (shared) --"
    local f
    for f in "${HOME_SHARED[@]}"; do
        link "$DOTFILES/$f" "$HOME/$f"
    done

    if [[ "$INSTALL_I3" -eq 1 ]]; then
        echo "   -- home dotfiles (i3) --"
        for f in "${HOME_I3[@]}"; do
            link "$DOTFILES/$f" "$HOME/$f"
        done
    fi

    echo "   -- ~/.config dirs (shared) --"
    for f in "${CFG_SHARED[@]}"; do
        link "$DOTFILES/$f" "$HOME/.config/$f"
    done

    if [[ "$INSTALL_I3" -eq 1 ]]; then
        echo "   -- ~/.config dirs (i3) --"
        for f in "${CFG_I3[@]}"; do
            link "$DOTFILES/$f" "$HOME/.config/$f"
        done
    fi

    if [[ "$INSTALL_HYPR" -eq 1 ]]; then
        echo "   -- ~/.config dirs (hypr) --"
        for f in "${CFG_HYPR[@]}"; do
            link "$DOTFILES/$f" "$HOME/.config/$f"
        done
    fi

    echo "   -- ~/.config files (shared) --"
    link "$DOTFILES/.dircolors" "$HOME/.config/.dircolors"

    if [[ "$INSTALL_I3" -eq 1 ]]; then
        echo "   -- ~/.config files (i3) --"
        link "$DOTFILES/picom/picom.conf" "$HOME/.config/picom.conf"
    fi

    echo "   -- special --"
    link "$DOTFILES/rosepine_gtk/gtk/gtk3" "$HOME/.themes"
}

setup_uwsm() {
    [[ "$INSTALL_HYPR" -eq 1 ]] || return 0
    echo
    echo ":: uwsm (Hyprland session env)"

    local uwsm_src="$DOTFILES/uwsm"
    local uwsm_dst="$HOME/.config/uwsm"

    if lspci -k 2>/dev/null | grep -qi 'nvidia'; then
        echo "   NVIDIA GPU detected - symlinking uwsm (keeping nvidia env lines)."
        link "$uwsm_src" "$uwsm_dst"
    else
        echo "   No NVIDIA GPU detected - copying uwsm with nvidia env lines stripped."
        local current=""
        current="$(readlink "$uwsm_dst" 2>/dev/null || true)"
        if [[ -L "$uwsm_dst" && "$current" == "$uwsm_src" ]]; then
            rm "$uwsm_dst"
        elif [[ -e "$uwsm_dst" || -L "$uwsm_dst" ]]; then
            mv "$uwsm_dst" "${uwsm_dst}.bak.${TIMESTAMP}"
        fi
        mkdir -p "$uwsm_dst"
        cp "$uwsm_src/default-id" "$uwsm_dst/default-id"
        grep -vxF \
            -e 'export GBM_BACKEND=nvidia-drm' \
            -e 'export LIBVA_DRIVER_NAME=nvidia' \
            -e 'export __GLX_VENDOR_LIBRARY_NAME=nvidia' \
            "$uwsm_src/env" > "$uwsm_dst/env"
        echo "   [copy] $uwsm_dst (env stripped of 3 nvidia lines)."
    fi
}

setup_hook() {
    echo
    echo ":: post-merge git hook"
    local hook="$DOTFILES/.git/hooks/post-merge"
    local current=""
    current="$(readlink "$hook" 2>/dev/null || true)"
    if [[ -L "$hook" && "$current" == "$DOTFILES/post-merge" ]]; then
        echo "   [skip] post-merge hook already installed."
    else
        if [[ -e "$hook" || -L "$hook" ]]; then
            mv "$hook" "${hook}.bak.${TIMESTAMP}"
        fi
        ln -s "$DOTFILES/post-merge" "$hook"
        chmod +x "$DOTFILES/post-merge"
        echo "   [done] post-merge hook linked."
    fi
}

run_postmerge() {
    echo
    echo ":: Applying branch profile (main=desktop / laptop)"
    ( cd "$DOTFILES" && bash post-merge ) \
        && echo "   profile applied." \
        || echo "   [warn] post-merge exited non-zero (no-op on non main/laptop branches)."
}

print_next_steps() {
    echo
    echo ":: Done."
    echo "   Next steps:"
    echo "     1. Reload shell:  exec zsh"
    echo "     2. Start tmux and install plugins:  prefix + I  (C-a then Shift-I)"
    if [[ "$INSTALL_HYPR" -eq 1 ]]; then
        echo "     3. Log out and select 'Hyprland (uwsm)' from the display manager."
    fi
    if [[ "$INSTALL_I3" -eq 1 ]]; then
        echo "     3. Start i3:  startx  (from TTY, .zprofile auto-starts on VT 2)"
    fi
}

main() {
    print_banner
    preflight
    setup_repo "$@"
    select_route
    install_packages
    setup_submodules
    setup_tpm
    setup_symlinks
    setup_uwsm
    setup_hook
    run_postmerge
    print_next_steps
}

main "$@"
