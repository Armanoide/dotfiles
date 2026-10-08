#!/bin/sh
# notify.sh — fonction de notification ntfy, sourcee par sync_nodes.sh et archive_old.sh
# Variables requises (via .env) : NTFY_URL, NTFY_TOPIC, NTFY_USER, NTFY_PASS
# Toggles : NOTIFY_ON_SUCCESS, NOTIFY_ON_FAILED (true/false)

notify() {
    # notify <success|failed> "titre" "message" [tags]
    _kind="$1"; _title="$2"; _msg="$3"; _tags="${4:-}"

    # respecter les toggles
    if [ "$_kind" = "success" ] && [ "${NOTIFY_ON_SUCCESS:-true}" != "true" ]; then return 0; fi
    if [ "$_kind" = "failed" ] && [ "${NOTIFY_ON_FAILED:-true}" != "true" ]; then return 0; fi

    # silance si NOTIFY_ON est defini et ne couvre pas le kind
    if [ -n "${NOTIFY_ON:-}" ]; then
        case ",${NOTIFY_ON}," in
            *",${_kind},"*) : ;;
            *) return 0 ;;
        esac
    fi

    # ntfy: success=3(default), failed=4(high)
    if [ "$_kind" = "failed" ]; then _prio=4; else _prio=3; fi

    # tags par defaut selon le kind
    if [ -z "$_tags" ]; then
        if [ "$_kind" = "failed" ]; then _tags="x"; else _tags="white_check_mark"; fi
    fi

    curl -s -m 10 -X POST \
        -u "${NTFY_USER}:${NTFY_PASS}" \
        -H "Title: ${_title}" \
        -H "Priority: ${_prio}" \
        -H "Tags: ${_tags}" \
        -d "${_msg}" \
        "${NTFY_URL}/${NTFY_TOPIC}" >/dev/null 2>&1 \
        && echo "[notify] sent (${_kind}) ${_title}" >&2 \
        || echo "[notify] FAIL send" >&2
}
