#!/bin/bash
set -euo pipefail

PLAYER="spotify"

cleanup() {
    echo ""

    # Kill zscroll and follow-status processes
    [[ -n "${ZPID-}" ]] && kill "$ZPID" 2>/dev/null || true
    [[ -n "${PC_PID-}" ]] && kill "$PC_PID" 2>/dev/null || true
}

trap cleanup EXIT

while true; do
    # Wait for Spotify to start
    while ! pgrep -x "$PLAYER" >/dev/null; do
        sleep 1
    done

    # Wait until playerctl responds
    while ! playerctl --player="$PLAYER" status &>/dev/null; do
        [[ ! $(pgrep -x "$PLAYER") ]] && continue 2
        sleep 0.2
    done

    # Kill any previous zscroll/follow-status
    cleanup

    # Start zscroll
    zscroll -l 30 \
      --delay 0.25 \
      --scroll-padding "  •  " \
      --match-command "playerctl --player=$PLAYER status" \
      --match-text "Playing" "--scroll 1 --after-text ' '" \
      --match-text "Paused" "--scroll 0 --after-text ' '" \
      --update-interval 1 \
      --update-check true \
      "playerctl --player=$PLAYER metadata --format '{{ artist }} - {{ title }}'" &
    ZPID=$!

    # Start playerctl follow-status for event-driven updates
    playerctl --player="$PLAYER" --follow status >/dev/null 2>&1 &
    PC_PID=$!

    # Monitor Spotify: wait until it exits
    while pgrep -x "$PLAYER" >/dev/null; do
        sleep 0.5
    done

    # Spotify exited → cleanup zscroll and follow-status
    cleanup

    # Short pause before looping to wait for Spotify again
    sleep 0.5
done

