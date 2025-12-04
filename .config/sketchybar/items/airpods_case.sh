#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item airpods_case right \
  --set airpods_case update_freq=10 \
  script="$PLUGIN_DIR/airpods_case.sh"

set_padding airpods_case icon_padding_off
