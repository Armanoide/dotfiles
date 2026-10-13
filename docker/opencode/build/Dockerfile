FROM node:20-bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
  git curl gh rsync python3 python3-pip python3-venv build-essential jq procps sudo \
  cifs-utils iputils-ping ca-certificates gnupg libssl-dev pkg-config tini \
  ripgrep unzip socat openssh-server \
  && rm -rf /var/lib/apt/lists/* \
  && pip3 install --break-system-packages graphifyy

# Remove default 'node' user (conflicts with UID 1000)
RUN if getent passwd node; then userdel -r node; fi

# Create 'opencode' user with UID 1000
RUN useradd -m -u 1000 -s /bin/bash opencode && \
  echo "opencode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Go toolchain: INSTALLED AT RUNTIME into named volume /usr/local/go (entrypoints/common/toolchains.sh)
ENV GO_VERSION=1.22.5 \
  GOPATH=/home/opencode/go

# Rust toolchain: INSTALLED AT RUNTIME into named volumes ~/.rustup + ~/.cargo (toolchains.sh)

# Pre-create required directories
RUN mkdir -p /home/opencode/.local/share/opencode/log \
  /home/opencode/.config/opencode \
  /home/opencode/app && \
  chown -R opencode:opencode /home/opencode

WORKDIR /home/opencode/app

# Install opencode as the opencode user - version EPINGLEE (tarball npm officiel).
# Evite qu'un rebuild silencieux tire une version cassee (incident 2026-10-12).
# Bump = changer OPENCODE_VERSION + OPENCODE_SHA256 (sha1sum du .tgz npm).
ARG OPENCODE_VERSION=2.0.27
ARG OPENCODE_SHA1=36fac0c74e408f2b2228ad5b8923f17c17929dd3
USER opencode
RUN curl -fsSL --retry 3 -o /tmp/oc.tgz \
     "https://registry.npmjs.org/@opencode/cli-linux-arm64/-/cli-linux-arm64-${OPENCODE_VERSION}.tgz" \
  && echo "${OPENCODE_SHA1}  /tmp/oc.tgz" | sha1sum -c - \
  && mkdir -p ~/.opencode/bin \
  && tar -xzf /tmp/oc.tgz -C /tmp \
  && install -m 0755 /tmp/package/bin/opencode ~/.opencode/bin/opencode \
  && rm -rf /tmp/oc.tgz /tmp/package

# Configure npm for global user installs
RUN mkdir -p ~/.npm-global && \
  npm config set prefix '~/.npm-global'

ENV PATH="/home/opencode/.npm-global/bin:/home/opencode/.local/bin:/home/opencode/.opencode/bin:${PATH}"

# Install CLI tools for skills (uipro, GSD SDK)
RUN npm install -g uipro-cli get-shit-done-cc@latest defuddle-cli || true

# TPM (tmux plugin manager) — tmux.conf du host est monte en ro et active
# TPM partout ; le clone est ici, les plugins s'installent par prefix+I au 1er boot.
RUN git clone --depth 1 https://github.com/tmux-plugins/tpm /home/opencode/.tmux/plugins/tpm

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

# Copy entrypoint scripts (modular: common/* sourced by tui.sh and web.sh)
USER root
COPY entrypoints/ /usr/local/bin/entrypoints/
RUN chmod +x /usr/local/bin/entrypoints/*.sh /usr/local/bin/entrypoints/common/*.sh && \
  chown -R opencode:opencode /usr/local/bin/entrypoints

USER opencode
ENV PATH="/backups/bin:/home/opencode/.opencode/bin:/home/opencode/.npm-global/bin:/home/opencode/.local/bin:${PATH}"
# Persist /backups/bin in login-shell PATH too (profile.d drop-in, survives rebuild)
USER root
RUN echo 'export PATH="/backups/bin:/home/opencode/.opencode/bin:/home/opencode/.npm-global/bin:$PATH"' > /etc/profile.d/backups-bin.sh && chmod 0644 /etc/profile.d/backups-bin.sh
USER opencode
SHELL ["/bin/bash", "-c"]

# --- tmux (terminal multiplexer) ---
USER root
RUN apt-get update && apt-get install -y --no-install-recommends tmux && rm -rf /var/lib/apt/lists/*

COPY sshd_config.tui /etc/ssh/sshd_config.tui

# mount points owned by opencode
RUN install -d -m 0755 /run/sshd \
    && install -d -m 0700 -o opencode -g opencode /home/opencode/.ssh \
    && install -d -m 0755 -o opencode -g opencode /etc/ssh/hostkeys


# Runtime toolchain mount points (named volumes populated on first boot)
USER root
RUN install -d -m 0755 /usr/local/go \
    && install -d -m 0755 -o opencode -g opencode /home/opencode/.rustup /home/opencode/.cargo

# Defaut user = opencode (entrypoint fait le setup root puis drop via setpriv)
USER opencode

# Default entrypoint (override per service in docker-compose)
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoints/tui.sh"]
