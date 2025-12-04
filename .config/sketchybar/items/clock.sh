#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item clock right \
           --set clock update_freq=20 script="$PLUGIN_DIR/clock.sh"


set_padding clock
