#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="network"

WIFI_ICON=":wifi:"
ETH_ICON=":wifi:"
DISCONNECTED_ICON=":wifi_off:"

# Get Wi-Fi SSID and Signal Strength
WIFI_SSID=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
WIFI_SIGNAL=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/agrCtlRSSI/ {print $2}')

# Check Ethernet status
ETH_STATUS=$(ifconfig en0 | grep "status: active")

if [ -n "$WIFI_SSID" ]; then
  sketchybar --set "$ITEM_NAME" icon="$WIFI_ICON" label="$WIFI_SSID ($WIFI_SIGNAL dBm)" \
    icon.color=$YELLOW label.color=$YELLOW \
    icon.font="sketchybar-app-font:Regular:20.0" \
    background.color=$YELLOW

elif [ -n "$ETH_STATUS" ]; then
  sketchybar --set "$ITEM_NAME" icon="$ETH_ICON" label="Ethernet Connected" \
    icon.color=$YELLOW label.color=$YELLOW \
    icon.font="sketchybar-app-font:Regular:20.0" \
    background.color=$YELLOW
else
  sketchybar --set "$ITEM_NAME" icon="$DISCONNECTED_ICON" label="Disconnected" \
    icon.color=$OVERLAY0 label.color=$OVERLAY0 \
    icon.font="sketchybar-app-font:Regular:20.0" \
    background.color=$YELLOW
fi
