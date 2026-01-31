#!/bin/bash

# 1. Load variables (Strictly)
if [ -f .env ]; then
    # Use grep and cut to avoid issues with comments or spaces
    CF_API_TOKEN=$(grep -E "^CF_API_TOKEN=" .env | cut -d'=' -f2)
    CROWDSEC_LAPI_KEY=$(grep -E "^CROWDSEC_LAPI_KEY=" .env | cut -d'=' -f2)
    echo "✅ Loaded keys from .env"
else
    echo "❌ .env not found"
    exit 1
fi

BOUNCER_PATH="$HOME/.config/crowd-sec/bouncer"
CONFIG_FILE="$BOUNCER_PATH/crowdsec-cloudflare-bouncer.yaml"
mkdir -p "$BOUNCER_PATH"

echo "🛠 Step 1: Generating Cloudflare configuration..."
docker run --rm crowdsecurity/cloudflare-bouncer -g ${CF_API_TOKEN} > "$CONFIG_FILE"

if [ ! -s "$CONFIG_FILE" ]; then
    echo "❌ Error: Generation failed. Is your CF_API_TOKEN correct?"
    exit 1
fi

echo "💉 Step 2: Injecting CrowdSec LAPI credentials..."
# We use | as a separator instead of / to avoid 'bad flag' errors
sed -i '' "s|crowdsec_lapi_key:.*|crowdsec_lapi_key: ${CROWDSEC_LAPI_KEY}|" "$CONFIG_FILE"
sed -i '' "s|crowdsec_lapi_url:.*|crowdsec_lapi_url: http://crowdsec:8080/|" "$CONFIG_FILE"

echo "🚀 Step 3: Running Cloudflare setup..."
docker run --rm \
  -v "$CONFIG_FILE:/etc/crowdsec/bouncers/crowdsec-cloudflare-bouncer.yaml" \
  crowdsecurity/cloudflare-bouncer -s

echo "✨ Done! Run: docker-compose up -d cloudflare-bouncer"
