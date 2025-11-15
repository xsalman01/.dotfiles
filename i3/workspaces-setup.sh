#!/bin/bash
set -euo pipefail

WORKSPACES_FILE="$HOME/.config/i3/workspaces.i3config"

if [ ! -f "$WORKSPACES_FILE" ]; then
  echo "workspaces.conf not found at $WORKSPACES_FILE. Exiting." >&2
  exit 1
fi

# -------------------------
# Helper: return the highest-resolution mode (by area) for a monitor
# -------------------------
# Usage: get_monitor_max_resolution MONITOR_NAME
# prints: "<width> <height>"
get_monitor_max_resolution() {
  local mon="$1"
  xrandr | awk -v mon="$mon" '
    $1 == mon { inside = 1; next }
    inside {
      # if a non-indented line appears, it means the next monitor section started
      if ($0 !~ /^[[:space:]]/) { if (maxw) { print maxw, maxh }; exit }
      # mode lines typically start with "   1920x1080"
      if ($1 ~ /^[0-9]+x[0-9]+/) {
        split($1, res, "x")
        w = res[1] + 0
        h = res[2] + 0
        area = w * h
        if (area > maxarea) {
          maxarea = area
          maxw = w
          maxh = h
        }
      }
    }
    END { if (inside && maxw) print maxw, maxh }
  '
}

# -------------------------
# Detect monitors + build assignments
# -------------------------
detect_monitors_and_generate_assignments() {
  local tmp_assign
  tmp_assign=$(mktemp)

  # get connected monitors in the order xrandr lists them
  mapfile -t CONNECTED_MONITORS < <(xrandr | awk '/ connected/ {print $1}')

  if [ ${#CONNECTED_MONITORS[@]} -eq 0 ]; then
    echo "No connected monitors found." >&2
    rm -f "$tmp_assign"
    return 1
  fi

  if [ ${#CONNECTED_MONITORS[@]} -eq 1 ]; then
    local MONITOR=${CONNECTED_MONITORS[0]}
    # choose the highest resolution mode for the single monitor
    read WIDTH HEIGHT < <(get_monitor_max_resolution "$MONITOR")

    # fallback: if we failed to parse modes, extract current from the header line (e.g., "1024x768+...")
    if [ -z "${WIDTH:-}" ] || [ -z "${HEIGHT:-}" ]; then
      read WIDTH HEIGHT < <(xrandr | awk -v mon="$MONITOR" '$1==mon { if (match($0, /([0-9]+)x([0-9]+)\+/, a)) {print a[1], a[2]; exit}}')
    fi

    # ensure integers
    WIDTH=${WIDTH%%.*}
    HEIGHT=${HEIGHT%%.*}
    xrandr --output "$MONITOR" --primary --pos 0x0

    for ws in {1..10}; do
      printf 'workspace "%s" output %s\n' "$ws" "$MONITOR" >> "$tmp_assign"
    done

  else
    # assume first is laptop/internal, last is external/primary (keeps your original intent)
    local LAPTOP_MONITOR=${CONNECTED_MONITORS[0]}
    local PRIMARY_MONITOR=${CONNECTED_MONITORS[-1]}

    # get highest modes (by area) for each monitor
    read WIDTH HEIGHT < <(get_monitor_max_resolution "$PRIMARY_MONITOR")
    if [ -z "${WIDTH:-}" ] || [ -z "${HEIGHT:-}" ]; then
      read WIDTH HEIGHT < <(xrandr | awk -v mon="$PRIMARY_MONITOR" '$1==mon { if (match($0, /([0-9]+)x([0-9]+)\+/, a)) {print a[1], a[2]; exit}}')
    fi

    read LAPTOP_WIDTH LAPTOP_HEIGHT < <(get_monitor_max_resolution "$LAPTOP_MONITOR")
    if [ -z "${LAPTOP_WIDTH:-}" ] || [ -z "${LAPTOP_HEIGHT:-}" ]; then
      read LAPTOP_WIDTH LAPTOP_HEIGHT < <(xrandr | awk -v mon="$LAPTOP_MONITOR" '$1==mon { if (match($0, /([0-9]+)x([0-9]+)\+/, a)) {print a[1], a[2]; exit}}')
    fi

    # sanitize to integers (strip possible stray characters)
    WIDTH=${WIDTH%%.*}
    HEIGHT=${HEIGHT%%.*}
    LAPTOP_WIDTH=${LAPTOP_WIDTH%%.*}
    LAPTOP_HEIGHT=${LAPTOP_HEIGHT%%.*}

    # if for any reason we couldn't determine widths, fall back to 0 to avoid broken xrandr syntax
    WIDTH=${WIDTH:-0}
    LAPTOP_WIDTH=${LAPTOP_WIDTH:-0}
    HEIGHT=${HEIGHT:-0}
    LAPTOP_HEIGHT=${LAPTOP_HEIGHT:-0}

    OFFSET_Y=$(( (HEIGHT - LAPTOP_HEIGHT) / 2 ))
    [ $OFFSET_Y -lt 0 ] && OFFSET_Y=0

    xrandr --output "$PRIMARY_MONITOR" --primary --pos 0x0
    xrandr --output "$LAPTOP_MONITOR" --pos ${WIDTH}x${OFFSET_Y}

    # workspace assignments (keeps your original mapping)
    for ws in 7 8 9 10; do
      printf 'workspace "%s" output %s\n' "$ws" "$LAPTOP_MONITOR" >> "$tmp_assign"
    done
    for ws in 2 3 4 5 6 1; do
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

  # Each line is: workspace "N" output MONITOR
  # read the fields explicitly
  while read -r field1 field2 field3 field4; do
    [ -z "${field1:-}" ] && continue
    ws_num=${field2//\"/}   # remove quotes from "N"
    out=$field4
    # sanity check
    if [ -n "$ws_num" ] && [ -n "$out" ]; then
      i3-msg "workspace $ws_num; move workspace to output $out" >/dev/null || true
    fi
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
    move_workspaces "$tmp_assign"

    current_ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
    i3-msg restart >/dev/null || true

    [[ -n "$current_ws" ]] && i3-msg "workspace $current_ws"

    rm -f "$tmp_assign"
  ) &
  TIMER_PID=$!
done
