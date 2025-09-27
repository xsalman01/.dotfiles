if ! pgrep -x xremap > /dev/null; then
    xremap ~/.config/xremap/config.yml &
fi

if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  exec startx
fi
