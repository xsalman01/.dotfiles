#!/bin/bash

killall -q xborders

xborders --border-radius 8 \
    --border-width 2 \
    --border-mode outside \
    --border-rgba \#4C4870ff \
    --disable-version-warning &
exit 0
