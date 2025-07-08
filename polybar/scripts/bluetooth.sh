#!/bin/bash

# Get Bluetooth state efficiently
get_state() {
    # Check if Bluetooth service is active
    if ! systemctl is-active bluetooth >/dev/null 2>&1; then
        echo "off"
        return
    fi

    # Get controller power state
    powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print $2}')
    [[ "$powered" != "yes" ]] && echo "off" && return

    # Check for connected devices
    connected=$(bluetoothctl devices 2>/dev/null | awk '{print $2}' | \
        xargs -r -I{} bluetoothctl info {} 2>/dev/null | grep -q "Connected: yes")

    [[ $? -eq 0 ]] && echo "connected" || echo "on"
}

# Print formatted icon based on state
print_state() {
    case "$(get_state)" in
        off) echo "%{F#6e6a86}%{F-}" ;;
        on) echo "%{F#ffffff}%{F-}" ;;
        connected) echo "%{F#f6c177}%{F-}" ;;
    esac
}

# Toggle Bluetooth power silently
toggle_power() {
    if systemctl is-active bluetooth >/dev/null 2>&1; then
        sudo systemctl stop bluetooth >/dev/null 2>&1
    else
        sudo systemctl start bluetooth >/dev/null 2>&1
    fi
}

# Main
case $1 in
    --toggle)
        toggle_power
        ;;
    --listen)
        print_state
        bluetoothctl --monitor 2>/dev/null | while read -r event; do
            if [[ "$event" =~ (Controller|Device|Powered|Connected) ]]; then
                print_state
            fi
        done
        ;;
esac

