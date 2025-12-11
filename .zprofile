# Start xremap if not running
if ! pgrep -x xremap > /dev/null; then
    xremap --watch ~/.config/xremap/config.yml &
fi

# Session handling
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    case "$XDG_VTNR" in
        1) exec startx ;;
        ### LAPTOP START ###
       2) exec niri-session ;;
        ### LAPTOP END ###
        
        ### DESKTOP START ###
#         2) exec niri-session ;;
        ### DESKTOP END ###
    esac
fi
