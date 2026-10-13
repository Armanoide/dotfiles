#!/bin/bash
# SSH module — ssh-* wrappers + injected SSH key. Self-contained domain.

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
    # base64 roundtrip: the command travels base64-encoded, decoded and executed
    # by the remote shell. Preserves quotes/globs/=== across the 3 quoting layers
    # (local bash -> wrapper string -> remote shell). Fix 2026-09-30: the old
    # pattern (nested string) swallowed inner double quotes.
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
}
