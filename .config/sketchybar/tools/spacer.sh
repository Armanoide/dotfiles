#!/bin/sh

add_spacer() {
  local NAME="$1"       # item name (spacer.xxx)
  local POSITION="$2"   # left / right
  local WIDTH="${3:-10}"  # default width: 10px

  sketchybar --add item "$NAME" "$POSITION" \
    --set "$NAME" \
    drawing=on \
    width=$WIDTH \
    icon.drawing=off \
    label.drawing=off \
    background.drawing=off
}
