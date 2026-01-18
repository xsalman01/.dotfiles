#!/bin/bash

sleep 3

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

# ---------- set default sink only if needed ----------

CURRENT_DEFAULT="$(pactl get-default-sink)"

if [ "$CURRENT_DEFAULT" != "game_sink" ]; then
  pactl set-default-sink game_sink
fi

# ---------- create loopbacks (once) ----------

pactl list short modules | grep -q "module-loopback.*game_sink.monitor" || \
  pactl load-module module-loopback \
    source=game_sink.monitor \
    sink=$REAL_SINK

pactl list short modules | grep -q "module-loopback.*chat_sink.monitor" || \
  pactl load-module module-loopback \
    source=chat_sink.monitor \
    sink="$REAL_SINK"

