FROM node:20-bookworm-slim

# Install system dependencies and Docker CLI
RUN apt-get update && apt-get install -y \
  git curl gh rsync python3 python3-pip python3-venv build-essential jq procps sudo \
  cifs-utils iputils-ping ca-certificates gnupg libssl-dev pkg-config tini \
  ripgrep unzip socat openssh-server \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg \
     | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) \
     signed-by=/etc/apt/keyrings/docker.gpg] \
     https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
     | tee /etc/apt/sources.list.d/docker.list > /dev/null \
  && apt-get update \
  && apt-get install -y docker-ce docker-ce-cli containerd.io \
     docker-buildx-plugin docker-compose-plugin \
  && rm -rf /var/lib/apt/lists/* \
  && pip3 install --break-system-packages graphifyy

# Remove default 'node' user (conflicts with UID 1000)
RUN if getent passwd node; then userdel -r node; fi

# Create 'opencode' user with UID 1000
RUN useradd -m -u 1000 -s /bin/bash opencode && \
  echo "opencode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Go toolchain (1.22 from go.dev — apt bookworm only ships 1.19, too old for some plugins)
ENV GO_VERSION=1.22.5 \
  GOROOT=/usr/local/go \
  GOPATH=/home/opencode/go
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" -o /tmp/go.tgz \
  && tar -C /usr/local -xzf /tmp/go.tgz \
  && rm /tmp/go.tgz \
  && ln -sf /usr/local/go/bin/go /usr/local/bin/go \
  && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt \
  && mkdir -p /home/opencode/go && chown -R opencode:opencode /home/opencode/go

# Install Rust toolchain
ENV RUSTUP_HOME=/home/opencode/.rustup \
  CARGO_HOME=/home/opencode/.cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# Pre-create required directories
RUN mkdir -p /home/opencode/.local/share/opencode/log \
  /home/opencode/.config/opencode \
  /home/opencode/app && \
  chown -R opencode:opencode /home/opencode

WORKDIR /home/opencode/app

# Install opencode as the opencode user
USER opencode
RUN curl -fsSL https://opencode.ai/install | bash

# Configure npm for global user installs
RUN mkdir -p ~/.npm-global && \
  npm config set prefix '~/.npm-global'

ENV PATH="/home/opencode/.cargo/bin:/home/opencode/.npm-global/bin:/home/opencode/.local/bin:/home/opencode/.opencode/bin:${PATH}"

# Install CLI tools for skills (uipro, GSD SDK)
RUN npm install -g uipro-cli get-shit-done-cc@latest defuddle-cli || true

# Install CBM (codebase-memory-mcp) — binaire amont officiel v0.11.0 (SHA-256 tar.gz épinglé)
# Le fork Armanoide v0.11.0-host est abandonné (403 assets sur LAN) ; UI exposée via conteneur cbm_ui dédié.
RUN curl -fsSL --retry 3 -o /tmp/cbm.tgz https://github.com/DeusData/codebase-memory-mcp/releases/download/v0.11.0/codebase-memory-mcp-linux-arm64-portable.tar.gz \
  && echo "d62eeb224d5ee3eba3070938ec62cf1033f10b041ec1c4b2fb67f7aef390cc7b  /tmp/cbm.tgz" | sha256sum -c - \
  && mkdir -p /home/opencode/.local/bin \
  && tar -xzf /tmp/cbm.tgz -C /home/opencode/.local/bin codebase-memory-mcp \
  && mv /home/opencode/.local/bin/codebase-memory-mcp /home/opencode/.local/bin/codebase-memory-mcp.tmp \
  && install -m 0755 /home/opencode/.local/bin/codebase-memory-mcp.tmp /home/opencode/.local/bin/codebase-memory-mcp \
  && rm -f /home/opencode/.local/bin/codebase-memory-mcp.tmp /tmp/cbm.tgz

# Install skills via CLI (overrides/complements manual files)
RUN graphify install --platform opencode || true && \
  uipro init --ai opencode --global || true && \
  npx get-shit-done-cc@latest --opencode --global --yes || true

# Install Bun via npm (required by opencode npm plugin auto-install).
# Uses existing ~/.npm-global prefix (USER=opencode) — no permission issues.
RUN npm install -g bun

# Copy entrypoint scripts
USER root
# Shared functions (sourced by tui.sh and web.sh)
COPY entrypoint-common.sh /usr/local/bin/entrypoint-common.sh
# Entrypoint TUI: setup + keep alive (no web server) — used by opencode-tui service
COPY entrypoint-tui.sh /usr/local/bin/entrypoint-tui.sh
# Entrypoint Web: setup + opencode web — used by opencode-web service (managed by Sablier)
COPY entrypoint-web.sh /usr/local/bin/entrypoint-web.sh
RUN chmod +x /usr/local/bin/entrypoint-*.sh && \
  chown opencode:opencode /usr/local/bin/entrypoint-*.sh

USER opencode
ENV PATH="/backups/bin:/home/opencode/.npm-global/bin:/home/opencode/.local/bin:/home/opencode/.opencode/bin:${PATH}"
# Persist /backups/bin in login-shell PATH too (profile.d drop-in, survives rebuild)
USER root
RUN echo 'export PATH="/backups/bin:/home/opencode/.npm-global/bin:$PATH"' > /etc/profile.d/backups-bin.sh && chmod 0644 /etc/profile.d/backups-bin.sh
USER opencode
SHELL ["/bin/bash", "-c"]

# --- tmux (terminal multiplexer) ---
USER root
RUN apt-get update && apt-get install -y --no-install-recommends tmux && rm -rf /var/lib/apt/lists/*

COPY sshd_config.tui /etc/ssh/sshd_config.tui

# mount points owned by opencode (Docker Desktop sinon monte root-owned)
RUN install -d -m 0755 /run/sshd \
    && install -d -m 0700 -o opencode -g opencode /home/opencode/.ssh \
    && install -d -m 0755 -o opencode -g opencode /etc/ssh/hostkeys

# --- tmux plugins: opentmux + tmux-agent-sidebar ---
USER opencode
RUN npm install -g opentmux && \
    git clone --depth 1 https://github.com/hiroppy/tmux-agent-sidebar.git /tmp/tab-src && \
    cd /tmp/tab-src && cargo build --release && \
    install -m 0755 target/release/tmux-agent-sidebar /home/opencode/.npm-global/bin/tmux-agent-sidebar && \
    rm -rf /tmp/tab-src ~/.cargo/registry/cache

# Defaut user = opencode (entrypoint fait le setup root puis drop via setpriv)
USER opencode

# Default entrypoint (override per service in docker-compose)
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint-tui.sh"]
