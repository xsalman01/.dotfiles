#!/bin/bash

# Get current branch (target branch)
TARGET_BRANCH=$(git branch --show-current)

# Determine action based on target branch
if [[ "$TARGET_BRANCH" == "main" ]]; then
    ACTION="enable_desktop"
elif [[ "$TARGET_BRANCH" == "laptop" ]]; then
    ACTION="enable_laptop"
else
    exit 0  # Skip processing if not on main/laptop
fi

# Determine comment character based on file
case "$1" in
    *.rasi)        COMMENT="//" ;;
    *.Xresources)  COMMENT="!"  ;;
    *)             COMMENT="#"  ;;
esac

# Process the file
awk -v action="$ACTION" -v comment="$COMMENT" '
    /### DESKTOP START ###/ { in_desktop = 1; print; next }
    /### DESKTOP END ###/   { in_desktop = 0; print; next }
    /### LAPTOP START ###/  { in_laptop  = 1; print; next }
    /### LAPTOP END ###/    { in_laptop  = 0; print; next }

    {
        if (in_desktop) {
            if (action == "enable_desktop") {
                # Uncomment desktop lines
                sub("^" comment "[ ]?", "", $0)
            } else {
                # Comment desktop lines
                if ($0 !~ "^" comment) $0 = comment " " $0
            }
        }
        else if (in_laptop) {
            if (action == "enable_laptop") {
                # Uncomment laptop lines
                sub("^" comment "[ ]?", "", $0)
            } else {
                # Comment laptop lines
                if ($0 !~ "^" comment) $0 = comment " " $0
            }
        }
        print
    }
' "$1" > "$1.tmp" && mv "$1.tmp" "$1"
