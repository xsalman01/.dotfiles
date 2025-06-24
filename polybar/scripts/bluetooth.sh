#!/bin/bash

# Get Bluetooth state efficiently
get_state() {
    # Check if Bluetooth service is active
    if ! systemctl is-active bluetooth >/dev/null; then
        echo "off"
        return
    fi

    # Get controller power state
    powered=$(bluetoothctl show | awk -F': ' '/Powered:/ {print $2}')
    [[ "$powered" != "yes" ]] && echo "off" && return

    # Check for connected devices
    connected_device=$(bluetoothctl devices | awk '{print $2}' | \
        xargs -I{} bluetoothctl info {} | grep -l "Connected: yes" | head -1)

    [[ -n "$connected_device" ]] && echo "connected" || echo "on"
}

# Print formatted state
print_state() {
    case "$(get_state)" in
        off) echo "%{F#6e6a86}%{F-}" ;;
        on) echo "%{F#ffffff}%{F-}" ;;
        connected) echo "%{F#f6c177}%{F-}" ;;
    esac
}

# Toggle Bluetooth power
toggle_power() {
    if systemctl is-active bluetooth >/dev/null; then
        sudo systemctl stop bluetooth
    else
        sudo systemctl start bluetooth
    fi
}

# Main execution
case $1 in
    --toggle)
        toggle_power
        ;;
    --listen)
        # Initial state
        print_state
        
        # Efficient event monitoring using bluetoothctl's built-in monitor
        bluetoothctl --monitor | while read -r event; do
            # Trigger update on relevant events
            if [[ "$event" =~ "Controller" ]] || \
               [[ "$event" =~ "Device" ]] || \
               [[ "$event" =~ "Powered" ]] || \
               [[ "$event" =~ "Connected" ]]; then
                print_state
            fi
        done
        ;;
esac
