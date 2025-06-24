#!/bin/bash

toggle() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
}

status() {
    if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "Mute: yes"; then
        echo "%{F#eb6f92}%{F-}"
    else
        echo ""
    fi
}

case "$1" in
    --toggle) toggle ;;
    --status) status ;;
    --listen)
        status  # Initial status
        
        # Start event monitoring with better matching
        pactl subscribe | while read -r event; do
            # Match broader range of relevant events
            if [[ "$event" =~ "Event 'change' on source" ]] || \
               [[ "$event" =~ "Event 'change' on server" ]]; then
                status
            fi
        done
        ;;
    --debug)
        pactl get-source-mute @DEFAULT_SOURCE@
        pactl subscribe
        ;;
esac
