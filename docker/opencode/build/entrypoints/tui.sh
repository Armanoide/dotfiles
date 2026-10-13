#!/bin/bash
# TUI entrypoint — root setup (sshd) then drop privileges to opencode.
set -e

source /usr/local/bin/entrypoints/common/setup.sh   # core + logs + config-gen + common_setup
source /usr/local/bin/entrypoints/common/ssh.sh
source /usr/local/bin/entrypoints/common/toolchains.sh

# --- root setup via sudo (USER=opencode, sshd needs root) ---
sudo usermod -p "" opencode  # unlock account (pubkey-only, no password)
sudo install -d -m 0755 /run/sshd
# ssh-keygen -A is broken here: it concatenates the prefix into the path (.../hostkeys/etc/ssh/...).
# Generate each key explicitly instead. Fails loudly (set -e) if it cannot.
if [ ! -f /etc/ssh/hostkeys/ssh_host_ed25519_key ]; then
  for k in rsa ecdsa ed25519; do
    sudo ssh-keygen -t $k -f /etc/ssh/hostkeys/ssh_host_${k}_key -N '' -q
  done
fi
sudo /usr/sbin/sshd -f /etc/ssh/sshd_config.tui

# tmux inherits its environment at server start; export before the first new-session
# so every pane (and opencode) gets truecolor. update-environment alone is not enough
# because the server starts detached from any client TTY here.
export COLORTERM=truecolor

# --- keep alive as opencode ---
common_setup
setup_runtime_toolchains
setup_ssh_key
# Create the session MacBook SSH clients attach to (RemoteCommand: tmux new-session -As opencode).
# Boot-time creation under the opencode user => stable socket UID 1000, no root-owned keys.
sudo -u opencode -E tmux new-session -d -s opencode 2>/dev/null || true
echo "TUI mode — container stays alive for interactive sessions (sshd + tmux)"

# agentix server — LAN events pipe (Phase 1, SERV-04)
# tini PID 1 reparents the orphan; no supervisor (Phase 1 lock).
# ponytail: if the server dies it does not restart — upgrade path v2: while-loop
( "${AGENTIX_BIN:-/home/opencode/app/dev/tmux-agentix/target/release/agentix-server}" >/dev/null 2>&1 & ) || echo "WARN: agentix-server absent" >&2

exec tail -qF "$LOG_DIR/opencode.log" 2>/dev/null
