#!/bin/bash

PRIMARY="eDP-1"
EXTERNAL="HDMI-1"

if xrandr | grep "$EXTERNAL connected"; then
    # HDMI connected → pin odd workspaces to it
    i3-msg "workspace 3; move workspace to output $EXTERNAL"
    i3-msg "workspace 5; move workspace to output $EXTERNAL"
    i3-msg "workspace 7; move workspace to output $EXTERNAL"
    i3-msg "workspace 9; move workspace to output $EXTERNAL"
    for wks in 10 4 6 8 2; do
        i3-msg "workspace $wks; move workspace to output $PRIMARY"
    done
    i3-msg "workspace 1; move workspace to output $EXTERNAL"
else
    # HDMI disconnected → move all to laptop screen
    for wks in 9 3 5 7 1; do
        i3-msg "workspace $wks; move workspace to output $PRIMARY"
    done
fi
