# Start xremap if not running
if ! pgrep -x xremap > /dev/null; then
    xremap --watch ~/.config/xremap/config.yml &
fi

# Session handling
if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
    case "$XDG_VTNR" in
        2) 
            exec uwsm start default
            ;;
        1) 
            exec startx 
            ;;
    esac
fi
