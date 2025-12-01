#!/bin/sh

sketchybar --add item keyboard right \
           --set keyboard script="$PLUGIN_DIR/keyboard.sh" \
           update_freq=2
