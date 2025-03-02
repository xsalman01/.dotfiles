#!/bin/bash

pkill xborders

xborders --border-radius 2 \
    --border-width 1 \
    --border-mode center \
    --border-rgba \#928374 \
    --disable-version-warning &
exit 0
