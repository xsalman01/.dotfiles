#!/bin/bash

sleep 2

DEFAULT_SINK="$(pactl get-default-sink)"

pactl list short modules | grep -q "game_sink" || \
  pactl load-module module-null-sink \
    sink_name=game_sink \
    sink_properties=device.description=Game

pactl list short modules | grep -q "chat_sink" || \
  pactl load-module module-null-sink \
    sink_name=chat_sink \
    sink_properties=device.description=Chat

pactl list short modules | grep -q "game_sink.monitor" || \
  pactl load-module module-loopback \
    source=game_sink.monitor \
    sink="$DEFAULT_SINK" \
    sink_dont_move=true

pactl list short modules | grep -q "chat_sink.monitor" || \
  pactl load-module module-loopback \
    source=chat_sink.monitor \
    sink="$DEFAULT_SINK" \
    sink_dont_move=true

pactl set-default-sink game_sink
