#!/bin/sh

# Check if Bluetooth is powered on
if [ "$(bluetoothctl show | grep 'Powered: yes' | wc -c)" -eq 0 ]; then
  # Bluetooth is off
  echo "%{F#6e6a86}"
else
  # Bluetooth is on; check if a device is connected
  if [ "$(echo info | bluetoothctl | grep 'Connected: yes' | wc -l)" -eq 0 ]; then
    # No device connected
    echo "%{F#ffffff}"
  else
    # Device connected
    echo "%{F#f6c177}"
  fi
fi

