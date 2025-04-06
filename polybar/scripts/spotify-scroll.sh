#!/bin/bash

zscroll -l 30 \
        --delay 0.15 \
        --scroll-padding " | " \
        --match-command "`dirname $0`/spotify-status.sh --status" \
        --match-text "Playing" "--scroll 1 --after-text ' %{T6 F#f6c177}%{T- F-}'" \
        --match-text "Paused" "--scroll 0 --after-text ' %{T6 F#f6c177}%{T- F-}'" \
        --update-check true "`dirname $0`/spotify-status.sh" &
wait
