#!/bin/bash

pkill xborders

xborders --border-radius 10 --border-width 3 --border-mode center \
    --border-rgba \#928374DF --disable-version-warning &
exit 0
