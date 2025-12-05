#!/bin/sh

source "$TOOL_DIR/padding.sh"

sketchybar --add item rsync_status right \
  --set rsync_status script="$PLUGIN_DIR/rsync_status.sh" \
  update_freq=5

set_padding rsync_status
