if ! pgrep -x xremap > /dev/null; then
    xremap ~/.config/xremap/config.yml &
fi

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 2 ]; then
    if uwsm check may-start && uwsm select; then
        exec uwsm start default
    fi
fi
