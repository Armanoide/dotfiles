#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="internet"
REPORT_FILE="/tmp/speedtest_report.txt"
SCRIPT_BIN="$HOME/.local/rbin/my_speed_test.sh"

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
IP_ADDRESS_INTERNET=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '$1=="inet" {print $2}')

LEVEL=0
LEVEL_COLOR="red"

REPORT_STALE_TIMEOUT=600

if [ -f "$REPORT_FILE" ]; then
  DOWNLOAD_MBPS_INT=$(rg Mbps "$REPORT_FILE" | rg -o "\d+\.\d+" | tail -n 1)
  if [ -n "$DOWNLOAD_MBPS_INT" ]; then
    MAX_SPEED=300

    INT_VALUE=$(printf "%.0f" "$DOWNLOAD_MBPS_INT")

    LEVEL=$(( ($INT_VALUE * 100) / $MAX_SPEED ))

    if [ "$LEVEL" -gt 100 ]; then
      LEVEL=100
    elif [ "$LEVEL" -lt 0 ]; then
      LEVEL=0
    fi

    if [ "$LEVEL" -ge 80 ]; then
      LEVEL_COLOR="green"
    elif [ "$LEVEL" -ge 40 ]; then
      LEVEL_COLOR="yellow"
    else
      LEVEL_COLOR="red"
    fi

  fi
fi


LAST_MODIFIED=$(stat -f "%m" "$REPORT_FILE")
CURRENT_TIME=$(date +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED))

if [ "$TIME_DIFF" -gt "$REPORT_STALE_TIMEOUT" ]; then
  $SCRIPT_BIN &
fi

if [ -n "$IP_ADDRESS_INTERNET" ]; then
  ICON_COLOR="$TEXT"
else
  ICON_COLOR="$OVERLAY0"
fi

sketchybar --set "$ITEM_NAME" \
  icon="" \
  icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
  icon.color="$ICON_COLOR" \
  background.image="$CONFIG_DIR/assets/${LEVEL_COLOR}/${LEVEL}.png"
