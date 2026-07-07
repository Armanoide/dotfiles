FROM ubuntu:noble

ARG CONTAINER_UID
ARG CONTAINER_GID

RUN apt-get update && apt-get install -y \
    curl \
    git \
    tini \
    build-essential \
    gcc \
    ripgrep \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    xclip \
    fzf \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz \
    && tar xzf nvim-linux-x86_64.tar.gz \
    && mv nvim-linux-x86_64/bin/nvim /usr/local/bin/ \
    && mv nvim-linux-x86_64/lib/nvim /usr/local/lib/ \
    && mv nvim-linux-x86_64/share/nvim /usr/local/share/ \
    && rm -rf nvim-linux-x86_64.tar.gz nvim-linux-x86_64

# Create nvim user (handles UID/GID conflicts gracefully)
RUN create_user() { \
      useradd -m -u "${CONTAINER_UID}" -g "${CONTAINER_GID}" -s /bin/bash nvim 2>/dev/null && return 0; \
      useradd -m -u "${CONTAINER_UID}" -s /bin/bash nvim 2>/dev/null && return 0; \
      userdel -f "$(id -un ${CONTAINER_UID} 2>/dev/null)" 2>/dev/null; \
      useradd -m -u "${CONTAINER_UID}" -g "${CONTAINER_GID}" -s /bin/bash nvim 2>/dev/null && return 0; \
      useradd -m -u "${CONTAINER_UID}" -s /bin/bash nvim; \
    }; \
    create_user

# Entrypoint: --root runs as root, otherwise runs as nvim
RUN printf '#!/bin/bash\n' > /usr/local/bin/entrypoint.sh && \
    printf 'if [[ "$*" == *"--root"* ]]; then\n' >> /usr/local/bin/entrypoint.sh && \
    printf '  exec /usr/local/bin/nvim "${@//--root/}"\n' >> /usr/local/bin/entrypoint.sh && \
    printf 'else\n' >> /usr/local/bin/entrypoint.sh && \
    printf '  export HOME="/home/nvim"\n' >> /usr/local/bin/entrypoint.sh && \
    printf '  export XDG_CONFIG_HOME="$HOME/.config"\n' >> /usr/local/bin/entrypoint.sh && \
    printf '  exec su -s /bin/bash nvim -c '"'"'export HOME="$HOME"; export XDG_CONFIG_HOME="$XDG_CONFIG_HOME"; /usr/local/bin/nvim "$@"'"'"' _ "$@"\n' >> /usr/local/bin/entrypoint.sh && \
    printf 'fi\n' >> /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /home/nvim
USER nvim
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/nvim"]
