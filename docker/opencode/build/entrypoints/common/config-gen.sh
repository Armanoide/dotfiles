#!/bin/bash
# Config-gen module — auth.json + opencode.json guard (static template).

generate_auth_config() {
    echo "Generating auth.json..."
    local prov_id="${OPENCODE_PROVIDER_ID}"
    local api_key="${OPENCODE_API_KEY}"
    # Normalize API key (prepend sk- prefix if missing)
    if [[ -n "$api_key" && ! $api_key == sk-* ]]; then
        api_key="sk-$api_key"
    fi
    jq -n --arg id "$prov_id" --arg key "$api_key" \
      '{ ($id): { "type": "api", "key": $key } }' > "$DATA_DIR/auth.json"
}

generate_opencode_config() {
    # GENERATION DISABLED (2026-09-30) - opencode.json is a static template
    # fed by {env:VAR} resolved natively by opencode from the .env.
    # The entrypoint must NEVER write this file again (regression: mcp block lost).
    # Non-blocking guard: warn if missing, no exit (does not kill startup).
    if [[ ! -s "$CONFIG_DIR/opencode.json" ]]; then
        echo "WARN: $CONFIG_DIR/opencode.json missing or empty - restore from /backups, do not regenerate here." >&2
    else
        echo "opencode.json: static template verified, not regenerated"
    fi
}
