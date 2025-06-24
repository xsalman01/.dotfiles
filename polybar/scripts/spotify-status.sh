#!/bin/bash

PLAYER="spotify"
FORMAT="{{ artist }} - {{ title }}"
STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
EXIT_CODE=$?

if [ "$EXIT_CODE" -eq 0 ]; then
    polybar-msg action "#spotify.module_show" >/dev/null
else
    polybar-msg action "#spotify.module_hide" >/dev/null
    exit 0
fi

if [ "$1" == "--status" ]; then
    echo "$STATUS"
else
    case "$STATUS" in
        "Playing"|"Paused")
            playerctl --player=$PLAYER metadata --format "$FORMAT"
            ;;
        *)
            echo ""
            ;;
    esac
fi

