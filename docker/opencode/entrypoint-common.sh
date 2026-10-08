#!/bin/bash
set -e
# --- CONFIGURATION ---
DATA_DIR="/home/opencode/.local/share/opencode"
CONFIG_DIR="/home/opencode/.config/opencode"
LOG_DIR="$DATA_DIR/log"
# Supported permissions list
PERMS_LIST=("edit" "write" "read" "grep" "glob" "list" "lsp" "patch" "skill" "todowrite" "todoread" "webfetch" "websearch")

# --- SHARED FUNCTIONS ---
fix_docker_socket() {
    echo "Fixing Docker socket permissions..."
    if [ -S /var/run/docker.sock ]; then
        sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
        echo "Docker socket ready"
    else
        echo "No Docker socket detected"
    fi
}

fix_permissions() {
    echo "Fixing directory ownership..."
    local uid
    uid=$(id -u)
    local gid
    gid=$(id -g)
    echo chown -R "$uid:$gid" "$DATA_DIR" "$CONFIG_DIR"
    sudo chown -R "$uid:$gid" "$DATA_DIR" "$CONFIG_DIR"
    echo "Ownership fixed"
}

create_ssh_wrapper() {
    local name="$1"
    local target_host="$2"
    local ssh_user="$3"
    local shell_type="$4"
    local wrapper_path="/usr/local/bin/ssh-${name}"

    echo "Creating 'ssh-${name}' wrapper -> ${ssh_user}@${target_host}..."

    # Append SSH config entry
    echo -e "Host ${target_host}\n\tStrictHostKeyChecking no\n\tIdentityFile /home/opencode/.ssh/id_opencode\n\tUser ${ssh_user}\n" >> /home/opencode/.ssh/config
    chmod 600 /home/opencode/.ssh/config

    # Generate wrapper script
    # base64 roundtrip: la commande voyage encodee en base64, decodee et executee
    # par le shell distant. Preserve quotes/globs/=== a travers les 3 couches de
    # quoting (bash local -> string du wrapper -> shell distant). Fix 2026-09-30 :
    # l'ancien pattern (string imbriquee) avalait les double-quotes internes.
    sudo tee "$wrapper_path" > /dev/null <<EOF
#!/bin/bash
if [ \$# -eq 0 ]; then
    exec ssh ${target_host} -t "${shell_type} -l"
fi
B64=\$(printf '%s' "\$*" | base64 -w0)
exec ssh ${target_host} -T "${shell_type} -lc 'echo \$B64 | base64 -d | sh'"
EOF
    sudo chmod +x "$wrapper_path"
}

setup_ssh_key() {
    echo "Checking injected SSH key..."
    if [ -z "$OPENCODE_SSH_KEY" ]; then
        echo "No OPENCODE_SSH_KEY found in environment"
        return
    fi

    # 1. Write SSH key and create initial config
    mkdir -p /home/opencode/.ssh
    echo -e "$OPENCODE_SSH_KEY" > /home/opencode/.ssh/id_opencode
    chmod 700 /home/opencode/.ssh
    chmod 600 /home/opencode/.ssh/id_opencode
    : > /home/opencode/.ssh/config
    chmod 600 /home/opencode/.ssh/config

    # 2. Handle 'host' target (host.docker.internal)
    if [ -n "$HOST_SSH_USER" ]; then
        create_ssh_wrapper "host" "host.docker.internal" "$HOST_SSH_USER" "${HOST_SSH_SHELL:-zsh}"
    fi

    # 3. Discover dynamic targets from *_SSH_HOST env vars
    for env_var in $(env | grep '_SSH_HOST=' | cut -d= -f1); do
        local name="${env_var%_SSH_HOST}"
        [[ "$name" == "HOST" ]] && continue
        local target_host="${!env_var}"
        local ssh_user_var="${name}_SSH_USER"
        local ssh_shell_var="${name}_SSH_SHELL"
        local ssh_user="${!ssh_user_var:-opencode}"
        local ssh_shell="${!ssh_shell_var:-zsh}"
        local name_lower
        name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        create_ssh_wrapper "$name_lower" "$target_host" "$ssh_user" "$ssh_shell"
    done

    # chown -R opencode:opencode /home/opencode/.ssh
}


setup_directories() {
    echo "Setting up directories..."
    mkdir -p "$LOG_DIR" "$CONFIG_DIR"
    touch "$LOG_DIR/opencode.log"
}

rotate_logs() {
    echo "Rotating logs..."
    for logfile in "$LOG_DIR"/*.log; do
        if [ -f "$logfile" ]; then
            local size
            size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile" 2>/dev/null || echo "0")
            if [ "$size" -gt 10485760 ]; then
                local rotated="${logfile}.$(date +%Y%m%d%H%M%S)"
                tail -c 5M "$logfile" > "$rotated"
                mv "$rotated" "$logfile"
                echo "Rotated: $logfile"
            fi
        fi
    done
    ls -t "$LOG_DIR"/*.log.* 2>/dev/null | tail -n +6 | xargs -r rm -f 2>/dev/null || true
}

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
    # GENERATION DESACTIVEE (2026-09-30) - opencode.json est un template statique
    # alimente par {env:VAR} resolus nativement par opencode depuis le .env.
    # L'entrypoint ne doit plus JAMAIS ecrire ce fichier (regression: bloc mcp perdu).
    # Garde-fou non bloquant: un warn si absent, sans exit (ne tue pas le demarrage).
    if [[ ! -s "$CONFIG_DIR/opencode.json" ]]; then
        echo "WARN: $CONFIG_DIR/opencode.json manquant ou vide - restaurer depuis /backups, ne pas regenerer ici." >&2
    else
        echo "opencode.json: template statique verifie, non regenere"
    fi
}

# Common setup for all modes
common_setup() {
    fix_permissions
    fix_docker_socket
    setup_directories
    generate_auth_config
    generate_opencode_config
    rotate_logs
    echo "Config OK: auth.json genere, opencode.json preserve (template)"
}
