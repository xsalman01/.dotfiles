#!/usr/bin/bash
set -euo pipefail

PLAYER="spotify"

cleanup() {
    # Kill any zscroll and follow-status processes
    pkill -f zscroll 2>/dev/null || true
    pkill -f "playerctl --player=$PLAYER --follow status" 2>/dev/null || true
}
trap cleanup EXIT

while true; do
    # Wait for Spotify to start
    while ! pgrep -x "$PLAYER" >/dev/null; do
        sleep 1
    done

    # Wait until MPRIS responds
    while ! playerctl --player="$PLAYER" status &>/dev/null; do
        # Spotify may have exited while waiting
        if ! pgrep -x "$PLAYER" >/dev/null; then
            continue 2
        fi
        sleep 0.2
    done

    # Kill any old zscroll
    pkill -f zscroll 2>/dev/null || true

    # Start zscroll in background
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

    # Follow spotify status
    playerctl --player="$PLAYER" --follow status >/dev/null 2>&1 &
    PC_PID=$!

    # Wait for follow-status to exit (Spotify closed)
    wait "$PC_PID" 2>/dev/null || true

    # Kill zscroll when Spotify exits
    kill "$ZPID" 2>/dev/null || true
    pkill -f zscroll 2>/dev/null || true

    # Backoff before checking for Spotify again
    sleep 0.5
done

