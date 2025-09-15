#!/bin/bash

PRIMARY="eDP-1"
EXTERNAL="HDMI-1"

if xrandr | grep "$EXTERNAL connected"; then
    # HDMI connected → pin odd workspaces to it
    i3-msg "workspace 1; move workspace to output $EXTERNAL"
    i3-msg "workspace 3; move workspace to output $EXTERNAL"
    i3-msg "workspace 5; move workspace to output $EXTERNAL"
    i3-msg "workspace 7; move workspace to output $EXTERNAL"
    i3-msg "workspace 9; move workspace to output $EXTERNAL"
else
    # HDMI disconnected → move all to laptop screen
    for ws in 1 3 5 7 9; do
        i3-msg "workspace $ws; move workspace to output $PRIMARY"
    done
fi
