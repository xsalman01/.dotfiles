#!/bin/bash
# Usage: change_sink_volume.sh "<Sink Name>" <up|down|mute>

SINK="$1"
ACTION="$2"
STEP="2%"

# Exit if sink doesn't exist
pactl list short sinks | awk '{print $2}' | grep -Fxq "$SINK" || exit 1

case "$ACTION" in
  up)
    pactl set-sink-volume "$SINK" "+$STEP"
    ;;
  down)
    pactl set-sink-volume "$SINK" "-$STEP"
    ;;
  mute)
    pactl set-sink-mute "$SINK" toggle
    ;;
esac
