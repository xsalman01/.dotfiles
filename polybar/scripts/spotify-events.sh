#!/bin/bash

# Keep track of visibility state
VISIBLE=0

# Helper: show module
show_module() {
    if [[ $VISIBLE -eq 0 ]]; then
        polybar-msg action "#spotify.module_show" >/dev/null
        VISIBLE=1
    fi
}

# Helper: hide module
hide_module() {
    if [[ $VISIBLE -eq 1 ]]; then
        polybar-msg action "#spotify.module_hide" >/dev/null
        VISIBLE=0
    fi
}

# Start watching playerctl metadata events
playerctl --player=spotify --follow metadata | while read -r line; do
    if pgrep -x spotify >/dev/null; then
        show_module
    else
        hide_module
    fi
done

