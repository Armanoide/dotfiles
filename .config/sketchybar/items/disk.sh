#!/bin/sh

source "$TOOL_DIR/padding.sh"

sketchybar --add item disk right \
           --set disk script="$PLUGIN_DIR/disk.sh" \
           update_freq=30

set_padding disk icon_padding_off
