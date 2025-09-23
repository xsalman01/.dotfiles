#!/bin/sh

picom --config ~/.config/picom.conf &
exec i3
