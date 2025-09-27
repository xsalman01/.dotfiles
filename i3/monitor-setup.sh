#!/bin/sh

if xrandr | grep -q "HDMI-1 connected"; then
    xrandr --output HDMI-1 --primary --mode 2560x1440 --left-of eDP-1 --output eDP-1 --mode 1920x1080
else
    xrandr --output eDP-1 --primary --mode 1920x1080
fi

