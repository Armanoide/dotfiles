#!/bin/bash

# Load colors (Assuming $CONFIG_DIR is correctly set)
source "$CONFIG_DIR/colors.sh"

ITEM_NAME="internet"
REPORT_FILE="/tmp/speedtest_report.txt"
SCRIPT_BIN="$HOME/.local/rbin/my_speed_test.sh"

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
IP_ADDRESS_INTERNET=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '$1=="inet" {print $2}')

LEVEL=0
LEVEL_COLOR="red"
# Configuration for Test Trigger
# Only run a new test if the last report is older than this (in seconds)
REPORT_STALE_TIMEOUT=600

if [ -f "$REPORT_FILE" ]; then
  DOWNLOAD_MBPS_INT=$(rg Mbps "$REPORT_FILE" | rg -o "\d+\.\d+" | tail -n 1)
  if [ -n "$DOWNLOAD_MBPS_INT" ]; then
    MAX_SPEED=500

    # 🚨 NEW STEP: Force DOWNLOAD_MBPS_INT to an integer
    # Using 'printf' or 'cut' to remove the decimal and everything after it.
    # The '%.0f' format specifier (floating point with 0 decimal places) works well.
    INT_VALUE=$(printf "%.0f" "$DOWNLOAD_MBPS_INT") 

    LEVEL=$(( ($INT_VALUE * 100) / $MAX_SPEED ))

    # Clamp LEVEL between 0 and 100
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

    # --- 4. Check for Stale Report and Trigger New Test ---
    LAST_MODIFIED=$(stat -f "%m" "$REPORT_FILE")
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - LAST_MODIFIED))

    if [ "$TIME_DIFF" -gt "$REPORT_STALE_TIMEOUT" ]; then
    # Execute the test script in the background
    $SCRIPT_BIN &
    fi
  fi
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
