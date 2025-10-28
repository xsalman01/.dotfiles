#!/bin/bash

FIFO="/tmp/spotify-fifo"
[ -p "$FIFO" ] || mkfifo "$FIFO"

PLAYER="spotify"

# Launch Spotify if not already running
pgrep -x "$PLAYER" >/dev/null || "$PLAYER" --disable-gpu &

# Wait for playerctl to detect Spotify
while ! playerctl --player="$PLAYER" status &>/dev/null; do
  sleep 0.2
done

# Show module immediately
echo "" > "$FIFO"

# Kill any existing zscroll instance
pkill -f "zscroll.*$PLAYER"

# Start zscroll and write metadata into FIFO
zscroll -l 30 \
  --delay 0.25 \
  --scroll-padding "  •  " \
  --match-command "playerctl --player=$PLAYER status" \
  --match-text "Playing" "--scroll 1 --after-text ' '" \
  --match-text "Paused"  "--scroll 0 --after-text ' '" \
  --update-interval 1 \
  --update-check true \
  "playerctl --player=$PLAYER metadata --format '{{ artist }} - {{ title }}'" \
> "$FIFO" &
ZPID=$!

# Monitor Spotify status; clean up when it exits
playerctl --player=$PLAYER --follow status | while read -r _; do
  if ! pgrep -x "$PLAYER" >/dev/null; then
    kill "$ZPID" 2>/dev/null
    rm -f "$FIFO"
    exit 0
  fi
done

