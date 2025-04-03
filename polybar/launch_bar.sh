#!/bin/bash

killall -q polybar

# Check the number of connected monitors
connected_monitors=$(xrandr --listmonitors | grep -o '[0-9]*' | head -n 1)

while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Launch the appropriate bar based on the number of monitors
if [ "$connected_monitors" -gt 1 ]; then
  polybar myBar &    # Assuming internal laptop screen is eDP-1
else
  polybar LaptopBar &
fi

exit 0
