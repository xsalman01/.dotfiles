#!/bin/bash

PARENT_BAR="myBar"
PARENT_BAR_PID=$(pgrep -a "polybar" | grep "$PARENT_BAR" | cut -d" " -f1)

PLAYER="spotify"
FORMAT="{{ artist }} - {{ title }}"

PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    STATUS=$PLAYERCTL_STATUS
else
    STATUS="No player is running"
    polybar-msg action "#spotify.module_hide"
fi

if [ "$1" == "--status" ]; then
    echo "$STATUS"
else
    if [ "$STATUS" = "Stopped" ]; then
        echo "No music is playing"
        polybar-msg action "#spotify.module_show"
    elif [ "$STATUS" = "Paused"  ]; then
        playerctl --player=$PLAYER metadata --format "$FORMAT"
        polybar-msg action "#spotify.module_show"
    elif [ "$STATUS" = "No player is running"  ]; then
        echo " "
    else
        playerctl --player=$PLAYER metadata --format "$FORMAT"
    fi
fi

