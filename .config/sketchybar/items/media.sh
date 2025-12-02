#!/bin/bash

sketchybar --add item media right \
           --set media script="$PLUGIN_DIR/media.sh" \
                         click_script="media-control toggle-play-pause" \
                         update_freq=1

