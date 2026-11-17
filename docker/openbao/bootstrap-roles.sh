#!/bin/bash
# One-shot OpenBao bootstrap for the agent double-key model.
# Add one entry per agent to AGENTS and re-run: policies/roles are updated in place,
# only the printed read credentials are regenerated.
# Run as admin (root token must already be logged in the container's token helper):
#   docker exec -i openbao sh < bootstrap-roles.sh
set -eu

KV="kv-v2"
LAN_CIDRS="10.0.10.0/24,127.0.0.1/32"
AGENTS="opencode hermes" # one word per agent -> <agent>-read / <agent>-mutate

enable_approle() {
  bao auth enable approle || echo "(approle already enabled)"
}

write_policies() {
  for agent in $AGENTS; do
    bao policy write "${agent}-read" - <<EOF
path "$KV/data/$agent/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/metadata/$agent/read/*" {
  capabilities = ["read", "list"]
}
# without self endpoints the token cannot renew itself and dies at TTL
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF

    bao policy write "${agent}-mutate" - <<EOF
path "$KV/data/$agent/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/metadata/$agent/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/data/$agent/mutate/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "$KV/metadata/$agent/mutate/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF
  done
}

create_roles() {
  for agent in $AGENTS; do
    # default agent identity: reusable secret_id, long TTL, LAN-bound
    bao write "auth/approle/role/${agent}-read" \
      token_policies="${agent}-read" \
      token_ttl="1h" token_max_ttl="24h" \
      secret_id_ttl="720h" \
      bound_cidr="$LAN_CIDRS"

    # the second key: single-use secret_id, 1h TTL — admin mints it per mutation
    bao write "auth/approle/role/${agent}-mutate" \
      token_policies="${agent}-mutate" \
      token_ttl="1h" token_max_ttl="1h" \
      secret_id_ttl="1h" secret_id_num_uses="1" \
      bound_cidr="$LAN_CIDRS"
  done
}

seed_kv_tree() {
  for agent in $AGENTS; do
    bao kv put "$KV/$agent/read/_placeholder" value="initialized" >/dev/null
    bao kv put "$KV/$agent/mutate/_placeholder" value="initialized" >/dev/null
    bao kv delete "$KV/$agent/read/_placeholder" >/dev/null
    bao kv delete "$KV/$agent/mutate/_placeholder" >/dev/null
  done
}

print_boot_credentials() {
  for agent in $AGENTS; do
    role_id=$(bao read -field=role_id "auth/approle/role/${agent}-read/role-id")
    secret_id=$(bao write -field=secret_id -f "auth/approle/role/${agent}-read/secret-id")
    # output only — store in the password manager, never commit
    echo "=== $agent (read-only boot credentials) ==="
    echo "OPENBAO_ROLE_ID=$role_id"
    echo "OPENBAO_SECRET_ID=$secret_id    # expires in 30 days"
  done
}

enable_approle
write_policies
create_roles
seed_kv_tree
print_boot_credentials
