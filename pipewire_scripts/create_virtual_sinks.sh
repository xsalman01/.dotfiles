#!/bin/bash

sleep 2

REAL_SINK="$(pactl get-default-sink)"

# ---------- create null sinks (once) ----------

pactl list short sinks | grep -q "game_sink" || \
  pactl load-module module-null-sink \
    sink_name=game_sink \
    sink_properties=device.description=Game

pactl list short sinks | grep -q "chat_sink" || \
  pactl load-module module-null-sink \
    sink_name=chat_sink \
    sink_properties=device.description=Chat

# ---------- create loopbacks (once) ----------

pactl list short modules | grep -q "module-loopback.*game_sink.monitor" || \
  pactl load-module module-loopback \
    source=game_sink.monitor \
    sink="$REAL_SINK"

pactl list short modules | grep -q "module-loopback.*chat_sink.monitor" || \
  pactl load-module module-loopback \
    source=chat_sink.monitor \
    sink="$REAL_SINK"

# ---------- set default sink only if needed ----------

CURRENT_DEFAULT="$(pactl get-default-sink)"

if [ "$CURRENT_DEFAULT" != "game_sink" ]; then
  pactl set-default-sink game_sink

  # give PA/PW time to auto-move streams
  sleep 0.2

  # ---------- move loopbacks back to real sink ----------
  pactl list short sink-inputs | awk '
    /game_sink\.monitor|chat_sink\.monitor/ {print $1}
  ' | while read -r id; do
    pactl move-sink-input "$id" "$REAL_SINK"
  done
fi

