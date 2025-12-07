#!/bin/sh


source "$TOOL/padding.sh"

ITEM_NAME="network"


sketchybar --add item "$ITEM_NAME" right \
  --set network script="$PLUGIN_DIR/network.sh" \
  update_freq=10

sketchybar --add item "${ITEM_NAME}_internet" right \
  update_freq=10

sketchybar --add item "${ITEM_NAME}_tailscale" right \
  update_freq=10


set_padding "${ITEM_NAME}_internet" icon_padding_off
set_padding "${ITEM_NAME}_tailscale" icon_padding_off

