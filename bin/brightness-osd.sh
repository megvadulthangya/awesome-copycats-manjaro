#!/usr/bin/env bash
# /usr/local/bin/brightness-osd.sh
#
# Brightness control with dunst OSD notification.
# Usage:
#   brightness-osd.sh up     increment by STEP percent
#   brightness-osd.sh down   decrement by STEP percent
#
# Uses `xbacklight` (already required by the current config).

set -e

STEP=10          # percent per keypress
OSD_ID=5556      # dunst replace-id

ACTION="${1:-}"

case "$ACTION" in
    up)   xbacklight -inc "$STEP" ;;
    down) xbacklight -dec "$STEP" ;;
    *)
        echo "Usage: $0 up|down" >&2
        exit 1
        ;;
esac

# Get current brightness, rounded to integer
BRIGHT=$(printf "%.0f" "$(xbacklight -get 2>/dev/null || echo 0)")
[ -z "$BRIGHT" ] && BRIGHT=0
[ "$BRIGHT" -gt 100 ] && BRIGHT=100
[ "$BRIGHT" -lt 0 ]   && BRIGHT=0

# Icon based on level (freedesktop icon naming)
if [ "$BRIGHT" -ge 70 ]; then
    ICON="display-brightness-high"
elif [ "$BRIGHT" -ge 30 ]; then
    ICON="display-brightness-medium"
else
    ICON="display-brightness-low"
fi

# Send OSD
if command -v dunstify >/dev/null 2>&1; then
    dunstify -r "$OSD_ID" -a "Brightness" -i "$ICON" -u low -t 1500 \
        -h "int:value:${BRIGHT}" "Brightness" "${BRIGHT}%" >/dev/null 2>&1 || true
else
    notify-send -a "Brightness" -i "$ICON" -u low -t 1500 \
        -h "int:value:${BRIGHT}" "Brightness" "${BRIGHT}%" >/dev/null 2>&1 || true
fi