#!/bin/bash

PLAYER="spotify"

# Exit if Spotify is not running
if ! pgrep -x "$PLAYER" >/dev/null; then
    exit 0
fi

# Wait for Spotify MPRIS to be available
while ! playerctl --player="$PLAYER" status &>/dev/null; do
    sleep 0.2
    if ! pgrep -x "$PLAYER" >/dev/null; then
        exit 0
    fi
done

# Kill any existing Spotify zscroll
pkill -f "zscroll.*$PLAYER"

# Start zscroll directly to stdout
zscroll -l 30 \
  --delay 0.25 \
  --scroll-padding "  •  " \
  --match-command "playerctl --player=$PLAYER status" \
  --match-text "Playing" "--scroll 1 --after-text ' '" \
  --match-text "Paused"  "--scroll 0 --after-text ' '" \
  --update-interval 1 \
  --update-check true \
  "playerctl --player=$PLAYER metadata --format '{{ artist }} - {{ title }}'" &
ZPID=$!

###############################
# FIX: No subshell
###############################
exec 3< <(playerctl --player="$PLAYER" --follow status)

while read -r status <&3; do
    if ! pgrep -x "$PLAYER" >/dev/null; then
        echo ""
        kill "$ZPID" 3>/dev/null
        exit 0
    fi
done

