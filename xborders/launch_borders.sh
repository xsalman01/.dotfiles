#!/bin/bash

pkill xborders

xborders --border-radius 2 \
    --border-width 1 \
    --border-mode center \
    --border-rgba \#c4a7e7 \
    --disable-version-warning &
exit 0
