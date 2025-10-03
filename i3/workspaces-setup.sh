#!/bin/bash
set -euo pipefail

WORKSPACES_FILE="$HOME/.config/i3/workspaces.conf"

if [ ! -f "$WORKSPACES_FILE" ]; then
  echo "workspaces.conf not found at $WORKSPACES_FILE. Exiting." >&2
  exit 1
fi

# -------------------------
# Detect monitors + build assignments
# -------------------------
detect_monitors_and_generate_assignments() {
  local tmp_assign
  tmp_assign=$(mktemp)

  CONNECTED_MONITORS=($(xrandr | awk '/ connected/ {print $1}'))

  if [ ${#CONNECTED_MONITORS[@]} -eq 1 ]; then
    local MONITOR=${CONNECTED_MONITORS[0]}
    xrandr --output "$MONITOR" --primary --pos 0x0

    for ws in {1..10}; do
      printf 'workspace "%s" output %s\n' "$ws" "$MONITOR" >> "$tmp_assign"
    done

  else
    local PRIMARY_MONITOR=${CONNECTED_MONITORS[-1]}
    local LAPTOP_MONITOR=${CONNECTED_MONITORS[0]}

    # Get resolutions
    read WIDTH HEIGHT < <(xrandr | awk -v mon="$PRIMARY_MONITOR" '
      $1 == mon {getline; if ($2 ~ /\*/) {split($1,res,"x"); print res[1],res[2]; exit}}
    ')
    read LAPTOP_WIDTH LAPTOP_HEIGHT < <(xrandr | awk -v mon="$LAPTOP_MONITOR" '
      $1 == mon {getline; if ($2 ~ /\*/) {split($1,res,"x"); print res[1],res[2]; exit}}
    ')

    OFFSET_Y=$(( (HEIGHT - LAPTOP_HEIGHT) / 2 ))
    [ $OFFSET_Y -lt 0 ] && OFFSET_Y=0

    xrandr --output "$PRIMARY_MONITOR" --primary --pos 0x0
    xrandr --output "$LAPTOP_MONITOR" --pos ${WIDTH}x${OFFSET_Y}

    for ws in 10 4 6 8 2; do
      printf 'workspace "%s" output %s\n' "$ws" "$LAPTOP_MONITOR" >> "$tmp_assign"
    done
    for ws in 9 3 5 7 1; do
      printf 'workspace "%s" output %s\n' "$ws" "$PRIMARY_MONITOR" >> "$tmp_assign"
    done
  fi

  echo "$tmp_assign"
}

# -------------------------
# Update config file between markers
# -------------------------
update_config_file() {
  local assignments_file="$1"
  local tmp_out="${WORKSPACES_FILE}.tmp.$$"

  awk -v tfile="$assignments_file" '
    BEGIN {
      n=0
      while ((getline line < tfile) > 0) { arr[++n]=line }
      close(tfile)
    }
    /### AUTO-ASSIGN START ###/ {
      print
      for (i=1;i<=n;i++) print arr[i]
      inside=1
      next
    }
    /### AUTO-ASSIGN END ###/ {
      print
      inside=0
      next
    }
    { if (!inside) print }
  ' "$WORKSPACES_FILE" > "$tmp_out"

  mv "$tmp_out" "$WORKSPACES_FILE"
}

# -------------------------
# Move workspaces immediately with i3-msg
# -------------------------
move_workspaces() {
  local assignments_file="$1"

  while read -r ws _ out; do
    # Format is: workspace "N" output MONITOR
    ws_num=$(echo "$ws" | tr -d '"')
    i3-msg "workspace $ws_num; move workspace to output $out" >/dev/null
  done < "$assignments_file"
}

# -------------------------
# Full layout cycle
# -------------------------
apply_layout() {
  local tmp_assign
  tmp_assign=$(detect_monitors_and_generate_assignments)

  update_config_file "$tmp_assign"

  echo "$tmp_assign"
}

# -------------------------
# Startup
# -------------------------
tmp_assign=$(apply_layout)
i3-msg restart >/dev/null || true
rm -f "$tmp_assign"

# -------------------------
# RandR hotplug event loop
# -------------------------
xev -root -event randr | while read -r _; do
  echo "RandR event detected" >&2
  kill ${TIMER_PID:-} 2>/dev/null || true
  (
    sleep 1
    tmp_assign=$(apply_layout)
    apply_workspace_moves "$tmp_assign"

    current_ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
    i3-msg restart >/dev/null || true

    [[ -n "$current_ws" ]] && i3-msg "workspace $current_ws"

    rm -f "$tmp_assign"
  ) &
  TIMER_PID=$!
done

