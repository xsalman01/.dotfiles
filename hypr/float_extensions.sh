#!/bin/bash
while read -r event_data; do
  event="${event_data%%>>*}"
  edata="${event_data#"$event">>}"

  if [[ "$event" == "windowtitlev2" ]]; then
    IFS=',' read -r -a fields <<<"$edata"
    if [[ "${fields[1]}" =~ ^Extension:\ \( ]]; then
     hyprctl dispatch setfloating address:"0x${fields[0]}" && hyprctl dispatch resizewindowpixel "exact 350 580",address:"0x${fields[0]}" && hyprctl dispatch movewindowpixel "14 20",address:"0x${fields[0]}"
     # hyprctl dispatch setfloating address:"0x${fields[0]}" && hyprctl dispatch resizewindowpixel "exact 350 580",address:"0x${fields[0]}"
    fi
  fi
done
