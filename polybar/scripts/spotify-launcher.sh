#!/bin/bash

FIFO="/tmp/spotify-fifo"
[ -p "$FIFO" ] || mkfifo "$FIFO"

PLAYER="spotify"
FORMAT="{{ artist }} - {{ title }}"

# Launch Spotify if not already running
pgrep -x "spotify" >/dev/null || spotify-launcher &

# Wait for player to become available
while ! playerctl --player="$PLAYER" status &>/dev/null; do sleep 0.2; done

# Show Polybar module
polybar-msg action "#spotify.module_show"

# Kill any existing zscroll instance for Spotify
pkill -f "zscroll.*$PLAYER"

# Start zscroll to write metadata to FIFO
zscroll -l 30 \
      --delay 0.25 \
      --scroll-padding "  •  " \
      --match-command "playerctl --player=spotify status" \
      --match-text "Playing" "--scroll 1 --after-text ' '" \
      --match-text "Paused" "--scroll 0 --after-text ' '" \
      --update-interval 1 \
      --update-check true "playerctl --player=spotify metadata --format '{{ artist }} - {{ title }}'" \
> "$FIFO"
ZPID=$!

# Monitor Spotify and auto-clean when closed
playerctl --player=$PLAYER --follow metadata | while read -r _; do
  if ! pgrep -x "$PLAYER" >/dev/null; then
    kill "$ZPID" 2>/dev/null
    polybar-msg action "#spotify.module_hide" || sleep 0.5 && polybar-msg action "#spotify.module_hide"
    rm -f "$FIFO"
    exit 0
  fi
done
