#!/bin/bash

pkill xborders

xborders --border-radius 2 \
    --border-width 2 \
    --border-mode outside \
    --border-rgba \#4C4870ff \
    --disable-version-warning &
exit 0
