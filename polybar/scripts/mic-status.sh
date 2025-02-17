#!/bin/bash

mic_status=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

if [ "$mic_status" == "yes" ]; then
    echo "%{F#C0FF1515}%{F-}"  # Mic muted (crossed-out icon)
else
    echo ""  # Mic active
fi
