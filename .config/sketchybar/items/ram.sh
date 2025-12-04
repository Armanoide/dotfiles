#!/bin/sh

source "$TOOL_DIR/padding.sh"

sketchybar --add item ram right \
  --set ram script="$PLUGIN_DIR/ram.sh" \
  update_freq=10

set_padding ram
