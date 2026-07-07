#!/bin/sh

# ==============================================================================
# Environment Variables
# ==============================================================================

if [ -z "$NODES" ]; then
    echo "CRITICAL ERROR: NODES not defined" >&2
    exit 1
fi
if [ -z "$DOCKER_DIR" ]; then
    echo "CRITICAL ERROR: DOCKER_DIR not defined" >&2
    exit 1
fi

BLACKLIST="${BLACKLIST:-${DOCKER_DIR}/.blacklist}"

# ==============================================================================
# Logging
# ==============================================================================
LOG_DIR="/var/log/rsync_pull"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/$(date +%Y-%m-%d).log"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $*"
    echo "$msg" >> "$LOG_FILE"
    echo "$msg" >&2
}

# ==============================================================================
# Discover compose project directories via Docker labels
# ==============================================================================

discover_paths() {
    NODE=$1

    NODE_LIST=$(ssh -T -o StrictHostKeyChecking=no "$NODE" \
        "sudo docker ps -a --format '{{.Names}}|{{.Label \"com.docker.compose.project.working_dir\"}}'" 2>/dev/null)

    echo "$NODE_LIST" | while IFS='|' read -r SERVICE SERVICE_DIR; do
        if grep -qx "$SERVICE" "$BLACKLIST" 2>/dev/null; then
            log "  SKIP: ${SERVICE} (blacklisted)"
            continue
        fi

        if [ -z "$SERVICE_DIR" ]; then
            log "  WARN: ${SERVICE} (not managed by docker-compose)"
            continue
        fi

        log "  ${SERVICE} → ${SERVICE_DIR}"
        echo "$SERVICE_DIR"
    done | sort -u | grep -v '^$'
}

# ==============================================================================
# Sync a single node
# ==============================================================================

sync_node() {
    NODE=$1
    NODE_IP=$(echo "$NODE" | cut -d'@' -f2)
    log "=== Syncing ${NODE_IP} ==="

    COMPOSE_PATHS=$(discover_paths "$NODE")

    if [ -z "${COMPOSE_PATHS}" ]; then
        log "  No paths to sync for ${NODE_IP}"
        return
    fi

    echo "${COMPOSE_PATHS}" | while IFS= read -r SERVICE_DIR; do
        [ -z "${SERVICE_DIR}" ] && continue

        PROJECT_NAME=$(basename "${SERVICE_DIR}")

        log "  SYNC: ${SERVICE_DIR} → ${PROJECT_NAME}"
        mkdir -p "${DOCKER_DIR}/${PROJECT_NAME}"
        rsync -avz --delete --rsync-path="sudo rsync" \
            -e "ssh -T -o StrictHostKeyChecking=no" \
            "${NODE}:${SERVICE_DIR}/" \
            "${DOCKER_DIR}/${PROJECT_NAME}/"
    done

    log "  ✓ ${NODE_IP} done"
}

# ==============================================================================
# Main
# ==============================================================================

log "=== Rsync Pull Node - Starting ==="
for NODE in $NODES; do
    sync_node "$NODE"
done
log "=== Rsync Pull Node - Done ==="
