#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="network"

WIFI_ICON=""
ETH_ICON=""
DISCONNECTED_ICON=""

# Get Wi-Fi SSID and Signal Strength
WIFI_SSID=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
WIFI_SIGNAL=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/agrCtlRSSI/ {print $2}')

# Check Ethernet status
ETH_STATUS=$(ifconfig en0 | grep "status: active")

if [ -n "$WIFI_SSID" ]; then
  sketchybar --set "$ITEM_NAME" icon="$WIFI_ICON" label="$WIFI_SSID ($WIFI_SIGNAL dBm)" \
    icon.color=$YELLOW label.color=$YELLOW \
    icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
    background.color=$YELLOW

elif [ -n "$ETH_STATUS" ]; then
  sketchybar --set "$ITEM_NAME" icon="$ETH_ICON" label="Ethernet Connected" \
    icon.color=$YELLOW label.color=$YELLOW \
    icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
    background.color=$YELLOW
else
  sketchybar --set "$ITEM_NAME" icon="$DISCONNECTED_ICON" label="Disconnected" \
    icon.color=$OVERLAY0 label.color=$OVERLAY0 \
    icon.font="MesloLGS Nerd Font Mono:Bold:22.0" \
    background.color=$YELLOW
fi
