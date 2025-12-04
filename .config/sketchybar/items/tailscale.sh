#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item tailscale right \
  --set tailscale script="$PLUGIN_DIR/tailscale.sh" \
  click_script="$CONFIG_DIR/click_scripts/tailscale.sh" \
  update_freq=4

set_padding tailscale
