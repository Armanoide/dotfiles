#!/bin/bash


source "$TOOL/padding.sh"

sketchybar --add item internet right \
  --set internet script="$PLUGIN_DIR/internet.sh" \
  update_freq=5 \

set_padding internet
