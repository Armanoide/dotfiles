#!/bin/bash

# Load colors (Assuming $CONFIG_DIR is correctly set)
source "$CONFIG_DIR/colors.sh"

ITEM_NAME="network"

WIDTH=85

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
IP_ADDRESS_INTERNET=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '$1=="inet" {print $2}')


# sketchybar --set "$ITEM_NAME" \
#   height=0 \
#   padding_right=0 \
#   padding_left=0 \
#   label.padding_right=0 \
#   label.padding_left=0 \
#   icon.padding_right=0 \
#   icon.padding_left=10 \
#   background.color=""


sketchybar --set "${ITEM_NAME}_internet" \
    width=$WIDTH \
    height=20 \
    label.y_offset=0 \
    label="$IP_ADDRESS_INTERNET" \
    label.font="MesloLGS Nerd Font Mono:Regular:12" \
    padding_right=0 \
    padding_left=0

