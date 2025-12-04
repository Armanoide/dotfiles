#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item front_app left \
  --set front_app \
  icon.drawing=on \
  label.drawing=on \
  icon.font="sketchybar-app-font:Regular:10.0" \
  label.font="MesloLGS Nerd Font Mono:Bold:12.0" \
  script="$CONFIG_DIR/plugins/front_app.sh" \
  --subscribe front_app front_app_switched

set_padding front_app
