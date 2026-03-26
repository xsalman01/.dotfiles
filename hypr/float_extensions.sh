#!/bin/bash

if [ "$(hyprctl activeworkspace -j | jq -r '.tiledLayout')" = "master" ]; then
    hyprctl dispatch layoutmsg "setlayout scroller"
else
    hyprctl dispatch layoutmsg "setlayout master"
fi
