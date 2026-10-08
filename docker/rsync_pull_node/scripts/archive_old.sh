#!/bin/sh
# archive_old.sh — archive .old des nodes vers NAS (rsync sudo), puis mv remote en .trash_old
# CRON_TASK_2 du conteneur rsync_pull_node (dimanche 04:00).
# Ordre critique : PREPARER destination (suffixe si collision) AVANT transfert.

set -u
NODES="${NODES:-norbert@10.0.10.5 norbert@10.0.10.6}"
SRC_DIR="${SRC_DIR:-/home/norbert/docker/.old}"
DEST_DIR="${DEST_DIR:-/source/docker/.old}"   # = /volume2/Users/norbert/docker/.old
TRASH="${TRASH:-/home/norbert/.trash_old}"

LOG_DIR="/var/log/rsync_pull"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/archive_old_$(date +%Y-%m-%d).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# notification ntfy (partagee)
[ -f /scripts/notify.sh ] && . /scripts/notify.sh

# compteurs pour la notification
ARCH_OK=0
ARCH_FAIL=0

# suffixe node court
node_short() {
    case "$1" in
        10.0.10.5) echo "node1";;
        10.0.10.6) echo "node2";;
        *) echo "$1";;
    esac
}

purge_trash() {
    NODE=$1
    log "PURGE ${NODE}: .trash_old > 24h"
    ssh -T -o StrictHostKeyChecking=no "$NODE" \
        "sudo mkdir -p ${TRASH} && sudo find ${TRASH} -mindepth 1 -maxdepth 1 -mtime +1 -exec rm -rf {} \; 2>/dev/null; echo purged"
}

archive_node() {
    NODE=$1
    NODE_IP=$(echo "$NODE" | cut -d'@' -f2)
    SHORT=$(node_short "$NODE_IP")
    log "=== ARCHIVE ${NODE_IP} (${SHORT}) ==="

    ITEMS=$(ssh -T -o StrictHostKeyChecking=no "$NODE" \
        "sudo find ${SRC_DIR} -mindepth 1 -maxdepth 1 -type d 2>/dev/null")

    if [ -z "$ITEMS" ]; then
        log "  rien a archiver pour ${NODE_IP}"
        return
    fi

    # ecrire la liste dans un fichier temporaire (evite que ssh/rsync vole le stdin du while)
    LIST_FILE="/tmp/archive_list_${SHORT}.txt"
    printf '%s\n' "$ITEMS" > "$LIST_FILE"

    while IFS= read -r SRC; do
        [ -z "$SRC" ] && continue
        NAME=$(basename "$SRC")

        # --- PREPARER DESTINATION AVANT TRANSFERT (suffixe si collision) ---
        DEST_NAME="${NAME}_${SHORT}"
        # si le nom suffixe existe deja (run precedent), ajouter un timestamp pour ne jamais ecraser
        if [ -e "${DEST_DIR}/${DEST_NAME}" ]; then
            DEST_NAME="${NAME}_${SHORT}_$(date +%Y%m%d%H%M)"
        fi
        DEST="${DEST_DIR}/${DEST_NAME}"

        log "  ARCHIVE: ${SRC} -> ${DEST_NAME}"
        mkdir -p "$DEST"

        # transfert rsync via sudo sur le node (lit les fichiers root-owned)
        if ! rsync -az --bwlimit=50M --rsync-path="sudo rsync" -e "ssh -T -o StrictHostKeyChecking=no" \
            "${NODE}:${SRC}/" "${DEST}/" </dev/null; then
            log "  ERROR rsync ${SRC} -> echec, on NE deplace PAS le remote"
            continue
        fi

        # verification: nb fichiers + somme des sha256 TRIEE (contenu, pas de chemin)
        LOCAL_COUNT=$(find "$DEST" -type f 2>/dev/null | wc -l)
        LOCAL_SUM=$(cd "$DEST" && find . -type f 2>/dev/null | xargs -r sha256sum 2>/dev/null | awk '{print $1}' | sort | sha256sum | awk '{print $1}')
        REMOTE_COUNT=$(ssh -T -o StrictHostKeyChecking=no "$NODE" "sudo find ${SRC} -type f 2>/dev/null | wc -l")
        REMOTE_SUM=$(ssh -T -o StrictHostKeyChecking=no "$NODE" "cd ${SRC} && sudo find . -type f 2>/dev/null | xargs -r sudo sha256sum 2>/dev/null | awk '{print \$1}' | sort | sha256sum | awk '{print \$1}'")

        if [ "$REMOTE_COUNT" = "$LOCAL_COUNT" ] && [ "$REMOTE_SUM" = "$LOCAL_SUM" ]; then
            log "  OK verif ${NAME} (fichiers=${LOCAL_COUNT})"
            ssh -T -o StrictHostKeyChecking=no "$NODE" \
                "sudo mkdir -p ${TRASH} && sudo mv ${SRC} ${TRASH}/${NAME}_$(date +%Y%m%d) 2>/dev/null && echo moved" \
                && log "  MOVED remote ${SRC} -> ${TRASH}/${NAME}_$(date +%Y%m%d)" \
                || { log "  WARN mv remote echec (donnee conservee sur node)"; ARCH_FAIL=$((ARCH_FAIL + 1)); }
            ARCH_OK=$((ARCH_OK + 1))
        else
            log "  MISMATCH ${NAME} remote=${REMOTE_COUNT}f local=${LOCAL_COUNT}f -> on NE deplace PAS"
            ARCH_FAIL=$((ARCH_FAIL + 1))
        fi
    done < "$LIST_FILE"
    rm -f "$LIST_FILE"

    log "  ✓ ${NODE_IP} archive done"
}

log "=== archive_old START ==="
for NODE in $NODES; do
    archive_node "$NODE"
    purge_trash "$NODE"
done
log "=== archive_old DONE ==="

# notification resume
if command -v notify >/dev/null 2>&1; then
    if [ "$ARCH_FAIL" -gt 0 ]; then
        notify failed "Archive .old ÉCHEC" "${ARCH_FAIL} projet(s) non archive(s), ${ARCH_OK} OK — mismatch ou erreur" "x,warning"
    elif [ "$ARCH_OK" -gt 0 ]; then
        notify success "Archive .old OK" "${ARCH_OK} projet(s) archive(s) vers NAS + mv en .trash_old (purge 24h)" "package,white_check_mark"
    fi
fi
