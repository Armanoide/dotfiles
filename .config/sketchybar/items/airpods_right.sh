#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item airpods_right right \
  --set airpods_right update_freq=10 \
script="$PLUGIN_DIR/airpods_right.sh"

set_padding airpods_right icon_padding_off
