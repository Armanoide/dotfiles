#!/bin/sh

source "$TOOL_DIR/padding.sh"

sketchybar --add item network_ping right \
  --set network_ping script="$PLUGIN_DIR/network_ping.sh" \
  update_freq=4

set_padding network_ping
