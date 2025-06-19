#!/bin/bash

# Get current branch
TARGET_BRANCH=$(git branch --show-current)
[ -z "$TARGET_BRANCH" ] && exit 0  # Skip if detached HEAD

# Determine comment character
case "$1" in
    *audio.conf|*workspaces.conf|*tray.ini|*volume.ini)
        COMMENT_CHAR="#" ;;
    */.Xresources)
        COMMENT_CHAR="!" ;;
    */config.rasi)
        COMMENT_CHAR="//" ;;
    *)
        COMMENT_CHAR="#" ;;  # Default
esac

# Process file
awk -v target="$TARGET_BRANCH" -v comment="$COMMENT_CHAR" '
    /### DESKTOP START ###/ { in_desktop=1; print; next }
    /### DESKTOP END ###/   { in_desktop=0; print; next }
    /### LAPTOP START ###/  { in_laptop=1; print; next }
    /### LAPTOP END ###/    { in_laptop=0; print; next }
    
    {
        if (in_desktop) {
            if (target == "main") gsub("^" comment "[ ]?", "")
            else if (target == "laptop") $0 = ($0 !~ "^" comment ? comment " " : "") $0
        }
        else if (in_laptop) {
            if (target == "laptop") gsub("^" comment "[ ]?", "")
            else if (target == "main") $0 = ($0 !~ "^" comment ? comment " " : "") $0
        }
        print
    }
' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
