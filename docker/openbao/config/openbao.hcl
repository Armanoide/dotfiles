ui            = false
disable_mlock = true

storage "raft" {
  path    = "/openbao/data"
  node_id = "node2"
}

# TLS terminated at Traefik (vault.ia.armanoide.net) — LAN is a segmented safe net
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr     = "https://vault.ia.armanoide.net"
cluster_addr = "http://127.0.0.1:8201" # single-node raft, required with tls_disable

# OpenBao 2.x: audit is declarative only (API blocked since CVE-2025-6000).
# Syntax is audit "<type>" "<name>" + options{} — audit_device {} is silently ignored.
audit "file" "openbao-audit" {
  description = "Vault access audit"

  options {
    file_path = "/openbao/data/audit.log"
    mode      = "0600"
    format    = "json"
    log_raw   = "false"
  }
}
