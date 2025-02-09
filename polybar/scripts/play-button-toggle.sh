#!/bin/bash

if pgrep -x "spotify" > /dev/null; then
    status=$(playerctl --player=spotify status 2>/dev/null)

    if [[ "$status" == "Playing" ]]; then
        echo ""
    else
        echo ""
    fi
else
    echo " "
fi
