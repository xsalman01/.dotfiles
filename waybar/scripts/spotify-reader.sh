#!/bin/bash

FIFO="/tmp/spotify-fifo"

# Create FIFO if it doesn't exist
[ -p "$FIFO" ] || mkfifo "$FIFO"

# Stream it forever to Polybar
cat "$FIFO"

