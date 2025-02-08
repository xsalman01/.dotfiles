#!/bin/bash

song=$(playerctl --player=spotify metadata --format "{{ artist }} - {{ title }}" 2>/dev/null)

if [ -z "$song" ]; then
    echo "No Song Playing"
else
    echo "🎵 $song"
fi
