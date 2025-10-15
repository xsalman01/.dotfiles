#!/bin/sh

export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3

systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk || true

picom --config ~/.config/picom.conf &
exec i3
