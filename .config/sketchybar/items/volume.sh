#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
           --subscribe volume volume_change

set_padding volume
