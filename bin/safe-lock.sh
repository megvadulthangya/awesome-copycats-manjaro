#!/usr/bin/env bash
# safe-lock.sh - xss-lock által hívva

LOCK_CMD="i3lock-fancy"

is_video_playing() {
  players=$(playerctl -l 2>/dev/null)
  [ -z "$players" ] && return 1

  for p in $players; do
    status=$(playerctl -p "$p" status 2>/dev/null || echo "")
    [ "$status" != "Playing" ] && continue

    media_type=$(playerctl -p "$p" metadata mpris:media-type 2>/dev/null || echo "")

    if [ "$media_type" = "Video" ]; then
      return 0
    fi

    case "$p" in
      mpv|chromium*|brave*|chrome*|grayjay*)
        return 0
        ;;
    esac
  done

  return 1
}

if is_video_playing; then
  exit 0
fi

exec $LOCK_CMD
