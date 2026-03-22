FROM ubuntu:noble

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    gcc \
    ripgrep \
    unzip \
    # Added for Yanky & Telescope performance
    sqlite3 \
    libsqlite3-dev \
    # Added for system clipboard support
    xclip \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# Téléchargement direct de Neovim v0.11 (Nightly/Prerelease)
RUN curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz \
    && tar xzf nvim-linux-x86_64.tar.gz \
    && mv nvim-linux-x86_64/bin/nvim /usr/local/bin/ \
    && mv nvim-linux-x86_64/lib/nvim /usr/local/lib/ \
    && mv nvim-linux-x86_64/share/nvim /usr/local/share/ \
    && rm -rf nvim-linux-x86_64.tar.gz nvim-linux-x86_64

WORKDIR /root
CMD ["/usr/local/bin/nvim"]
