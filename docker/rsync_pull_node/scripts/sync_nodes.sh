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

# notification ntfy (partagee)
[ -f /scripts/notify.sh ] && . /scripts/notify.sh

# compteurs globaux pour la notification
SYNC_TOTAL=0
SYNC_ERRORS=0

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

        # Capture rsync stdout/stderr to parse the transfer summary
        RSYNC_OUT=$(rsync -avz --delete --stats --human-readable \
            --bwlimit=50M --rsync-path="sudo rsync" \
            -e "ssh -T -o StrictHostKeyChecking=no" \
            "${NODE}:${SERVICE_DIR}/" \
            "${DOCKER_DIR}/${PROJECT_NAME}/" 2>&1)
        RSYNC_RC=$?

        # Machine-readable summary line consumed by rsync_dashboard.py
        FILES=$(echo "$RSYNC_OUT" | awk -F': ' '/Number of regular files transferred/ {print $2}' | tr -d ',')
        TOTAL_SIZE=$(echo "$RSYNC_OUT" | awk -F': ' '/Total file size/ {print $2}' | head -1)
        SPEEDUP=$(echo "$RSYNC_OUT" | awk -F': ' '/Speedup/ {print $2}' | head -1)
        log "  STATS: ${NODE_IP}|${PROJECT_NAME}|rc=${RSYNC_RC}|files=${FILES:-0}|size=${TOTAL_SIZE:-0B}|speedup=${SPEEDUP:-n/a}"

        if [ "$RSYNC_RC" -ne 0 ]; then
            log "  ERROR: ${NODE_IP}/${PROJECT_NAME} rsync rc=${RSYNC_RC}"
            SYNC_ERRORS=$((SYNC_ERRORS + 1))
        fi
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

# notification resume
if command -v notify >/dev/null 2>&1; then
    if [ "$SYNC_ERRORS" -gt 0 ]; then
        notify failed "Rsync Pull ÉCHEC" "${SYNC_ERRORS} projet(s) en erreur sur node1/node2 — voir logs NAS" "x,rotating_light"
    else
        notify success "Rsync Pull OK" "Synchronisation node1/node2 terminée sans erreur ($(date '+%H:%M'))" "white_check_mark"
    fi
fi
