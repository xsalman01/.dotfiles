#!/bin/sh

export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3

systemctl --user import-environment DISPLAY XAUTHORITY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS
systemctl --user restart xdg-desktop-portal xdg-desktop-portal-gtk || true

userresources="$HOME/.Xresources"
xinitdir="/etc/X11/xinit"
sysresources="$xinitdir/.Xresources"
xrdb="xrdb"

# merge in defaults and keymaps
if [ -f "$sysresources" ]; then
    if [ -x /usr/bin/cpp ] ; then
        "$xrdb" -merge "$sysresources"
    else
        "$xrdb" -nocpp -merge "$sysresources"
    fi
fi

if [ -f "$userresources" ]; then
    if [ -x /usr/bin/cpp ] ; then
        "$xrdb" -merge "$userresources"
    else
        "$xrdb" -nocpp -merge "$userresources"
    fi
fi

# start some nice programs
if [ -d "$xinitdir"/xinitrc.d ] ; then
	for f in "$xinitdir/xinitrc.d"/?*.sh ; do
		[ -x "$f" ] && . "$f"
	done
	unset f
fi

picom --config ~/.config/picom.conf &
exec i3
