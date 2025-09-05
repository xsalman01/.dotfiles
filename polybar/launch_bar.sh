#!/bin/bash

killall -q polybar

while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Launch the appropriate bar based on the number of monitors
if ls /sys/class/power_supply/ | grep -q "^BAT"; then
  polybar LaptopBar &    # if battery is present then it's a laptop
else
  polybar myBar &
fi

exit 0
