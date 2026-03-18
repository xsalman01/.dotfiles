#!/bin/bash
acpi_listen | while read -r event; do
    case "$event" in
        *lid*close*)
            hyprctl keyword monitor "eDP-1, disable"
            ;;
        *lid*open*)
            hyprctl keyword monitor "eDP-1, preferred, auto, 1"
            ;;
    esac
done
