
#!/bin/sh

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="tailscale"

TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

if ! command -v "$TAILSCALE_BIN" >/dev/null 2>&1; then
  sketchybar --set "$NAME" label="Tailscale missing" icon="⚠️"
  exit 0
fi

STATUS=$("$TAILSCALE_BIN" status --json 2>/dev/null)

if [[ $? -ne 0 ]]; then
  sketchybar --set "$NAME" label="Off" icon="󰤭" icon.color=0xffd65c5c
  exit 0
fi

ONLINE=$(echo "$STATUS" | jq -r '.BackendState')
IP=$(echo "$STATUS" | jq -r '.Self.TailscaleIPs[0]')

if [[ "$ONLINE" == "Running" ]]; then
  sketchybar --set "$NAME" \
    icon=":tailscale:" \
    icon.font="sketchybar-app-font:Regular:20.0" \
    icon.color=$TEXT \
    label.font="MesloLGS Nerd Font Mono:Bold:12.0" \
    label="$IP"
else
  sketchybar --set "$NAME" \
    icon=":tailscale:" \
    icon.font="sketchybar-app-font:Regular:20.0" \
    icon.padding_left=5 \
    icon.color=$OVERLAY0 \
    label=""
fi
