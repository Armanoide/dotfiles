#!/bin/bash
# One-shot OpenBao bootstrap for the agent double-key model:
# read-only AppRole by default, mutate AppRole minted on demand by an admin.
# Run as admin (root token must already be logged in the container's token helper):
#   docker exec -i openbao sh < bootstrap-roles.sh
set -eu

KV="kv-v2"
LAN_CIDRS="10.0.10.0/24,127.0.0.1/32"

enable_approle() {
  bao auth enable approle || echo "(approle already enabled)"
}

write_policies() {
  bao policy write opencode-read - <<EOF
path "$KV/data/opencode/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/metadata/opencode/read/*" {
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

  bao policy write opencode-mutate - <<EOF
path "$KV/data/opencode/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/metadata/opencode/read/*" {
  capabilities = ["read", "list"]
}
path "$KV/data/opencode/mutate/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "$KV/metadata/opencode/mutate/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}
EOF
}

create_roles() {
  # container default identity: reusable secret_id, long TTL, LAN-bound
  bao write auth/approle/role/opencode-read \
    token_policies="opencode-read" \
    token_ttl="1h" token_max_ttl="24h" \
    secret_id_ttl="720h" \
    bound_cidr="$LAN_CIDRS"

  # the second key: single-use secret_id, 1h TTL — admin mints it per mutation
  bao write auth/approle/role/opencode-mutate \
    token_policies="opencode-mutate" \
    token_ttl="1h" token_max_ttl="1h" \
    secret_id_ttl="1h" secret_id_num_uses="1" \
    bound_cidr="$LAN_CIDRS"
}

seed_kv_tree() {
  bao kv put "$KV/opencode/read/_placeholder" value="initialized" >/dev/null
  bao kv put "$KV/opencode/mutate/_placeholder" value="initialized" >/dev/null
  bao kv delete "$KV/opencode/read/_placeholder" >/dev/null
  bao kv delete "$KV/opencode/mutate/_placeholder" >/dev/null
}

print_boot_credentials() {
  role_id=$(bao read -field=role_id auth/approle/role/opencode-read/role-id)
  secret_id=$(bao write -field=secret_id -f auth/approle/role/opencode-read/secret-id)
  # output only — store in the password manager, never commit
  echo "Store these in the password manager (container boot credentials, read-only):"
  echo "OPENBAO_ROLE_ID=$role_id"
  echo "OPENBAO_SECRET_ID=$secret_id    # expires in 30 days"
}

enable_approle
write_policies
create_roles
seed_kv_tree
print_boot_credentials
