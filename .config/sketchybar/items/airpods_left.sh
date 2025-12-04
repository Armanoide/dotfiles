#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item airpods_left right \
  --set airpods_left update_freq=10 \
  script="$PLUGIN_DIR/airpods_left.sh"

set_padding airpods_left icon_padding_off
