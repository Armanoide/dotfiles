#!/bin/bash
# Alert when OpenBao is sealed: manual unseal means a human must know (cron */5).
# Nags every 5 min while sealed — intentional until unsealed.

DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/.env.ntfy"

STATUS_URL="http://127.0.0.1:3020/v1/sys/seal-status"
NTFY_URL="http://127.0.0.1:3012/openbao" # local ntfy on purpose: survives a Traefik outage

if curl -sf --max-time 5 "$STATUS_URL" | grep -q '"sealed":true'; then
  curl -sf --max-time 10 -u "openbao:$NTFY_PASS" \
    -H "Title: OpenBao SEALED on node2" \
    -H "Priority: high" \
    "$NTFY_URL" \
    -d "Vault sealed — unseal requires 3 keys. $(date '+%F %H:%M')"
fi
