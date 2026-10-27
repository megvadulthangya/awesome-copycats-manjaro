#!/usr/bin/env bash
# /usr/local/bin/volume-osd.sh
#
# Volume control with dunst OSD notification.
# Usage:
#   volume-osd.sh up       increment by STEP percent
#   volume-osd.sh down     decrement by STEP percent
#   volume-osd.sh mute     toggle mute
#   volume-osd.sh 0..100   set to absolute percentage
#
# Uses `pactl` (PipeWire/PulseAudio compatible).
# Volume is capped at 100% to avoid clipping and to keep the progress bar sane.
# Remove the cap block below if you want to allow >100% amplification.

set -e

STEP=5           # percent per up/down keypress
OSD_ID=5555      # dunst replace-id; rapid presses update the same notification

ACTION="${1:-}"

case "$ACTION" in
    up)     pactl set-sink-volume @DEFAULT_SINK@ "+${STEP}%" ;;
    down)   pactl set-sink-volume @DEFAULT_SINK@ "-${STEP}%" ;;
    mute)   pactl set-sink-mute   @DEFAULT_SINK@ toggle       ;;
    [0-9]*) pactl set-sink-volume @DEFAULT_SINK@ "${ACTION}%" ;;
    *)
        echo "Usage: $0 up|down|mute|0-100" >&2
        exit 1
        ;;
esac

# Cap volume at 100% (remove this block if you want >100% amplification)
VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -1 | tr -d '%')
if [ -n "$VOL" ] && [ "$VOL" -gt 100 ]; then
    pactl set-sink-volume @DEFAULT_SINK@ 100%
    VOL=100
fi

# Read mute state
MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

if [ "$MUTED" = "yes" ]; then
    ICON="audio-volume-muted"
    TEXT="Muted"
    BAR=0
else
    if [ "${VOL:-0}" -ge 70 ]; then
        ICON="audio-volume-high"
    elif [ "${VOL:-0}" -ge 30 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-low"
    fi
    TEXT="${VOL}%"
    BAR="${VOL}"
fi

# Send OSD (prefer dunstify: supports replace-id; fallback to notify-send)
if command -v dunstify >/dev/null 2>&1; then
    dunstify -r "$OSD_ID" -a "Volume" -i "$ICON" -u low -t 1500 \
        -h "int:value:${BAR}" "Volume" "$TEXT" >/dev/null 2>&1 || true
else
    notify-send -a "Volume" -i "$ICON" -u low -t 1500 \
        -h "int:value:${BAR}" "Volume" "$TEXT" >/dev/null 2>&1 || true
fi