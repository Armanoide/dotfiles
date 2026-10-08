#!/bin/bash
# Entrypoint TUI — setup root (sshd) puis drop privileges sur opencode
source /usr/local/bin/entrypoint-common.sh

# --- setup root via sudo (USER=opencode, sshd a besoin de root) ---
sudo usermod -p "" opencode  # unlock account (pubkey-only, pas de mot de passe)
sudo install -d -m 0755 /run/sshd
[ -f /etc/ssh/hostkeys/ssh_host_ed25519_key ] || sudo ssh-keygen -A -f /etc/ssh/hostkeys 2>/dev/null || true
sudo /usr/sbin/sshd -f /etc/ssh/sshd_config.tui

# --- keep alive en opencode ---
common_setup
setup_ssh_key
echo "TUI mode — container stays alive for interactive sessions (sshd + tmux)"
exec tail -qF "$LOG_DIR/opencode.log" 2>/dev/null