#!/bin/bash

# Load colors (Assuming $CONFIG_DIR is correctly set)
source "$CONFIG_DIR/colors.sh"

ITEM_NAME="network"

WIDTH=85

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
IP_ADDRESS_INTERNET=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '$1=="inet" {print $2}')

TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
if [ -x "$TAILSCALE_BIN" ]; then
    STATUS=$("$TAILSCALE_BIN" status --json 2>/dev/null)
    IP_ADDRESS_TAILSCALE=$(echo "$STATUS" | jq -r '.Self.TailscaleIPs[0]' 2>/dev/null)
else
    IP_ADDRESS_TAILSCALE="-"
fi


sketchybar --set "$ITEM_NAME" \
  height=0 \
  padding_right=0 \
  padding_left=0 \
  label.padding_right=0 \
  label.padding_left=0 \
  icon.padding_right=0 \
  icon.padding_left=10 \
  background.color=""


sketchybar --set "${ITEM_NAME}_internet" \
    width=$WIDTH \
    height=20 \
    label.y_offset=9 \
    label="$IP_ADDRESS_INTERNET" \
    label.font="MesloLGS Nerd Font Mono:Regular:10.0" \
    padding_right=0 \
    padding_left=0

sketchybar --set "${ITEM_NAME}_tailscale" \
    width=0 \
    height=20 \
    label.y_offset=-9 \
    label="$IP_ADDRESS_TAILSCALE" \
    label.font="MesloLGS Nerd Font Mono:Regular:10.0" \
    padding_right="-$WIDTH" \
    padding_left=10
