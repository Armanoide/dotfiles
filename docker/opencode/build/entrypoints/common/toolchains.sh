#!/bin/bash
# Toolchains module — Go + Rust installed at RUNTIME into named volumes.
# Idempotent: installs only when missing, then persists across rebuilds.
# Volumes: /usr/local/go (goroot), ~/.rustup (rustup), ~/.cargo (cargo).

GO_VERSION="${GO_VERSION:-1.22.5}"

setup_runtime_toolchains() {
    # Go — named volume mounted at /usr/local/go (empty dir baked in image)
    if [ ! -x /usr/local/go/bin/go ]; then
        echo "Installing Go ${GO_VERSION} into /usr/local/go (first boot, ~1 min)..."
        sudo mkdir -p /usr/local/go
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz" \
            | sudo tar -C /usr/local -xz
        echo "Go installed: $(/usr/local/go/bin/go version)"
    fi

    # Rust — named volumes mounted at ~/.rustup + ~/.cargo (empty dirs baked in image)
    if [ ! -x "$HOME/.cargo/bin/cargo" ]; then
        echo "Installing rustup into ~/.rustup + ~/.cargo (first boot, ~2 min)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --no-modify-path
        echo "Rust installed: $($HOME/.cargo/bin/cargo --version)"
    fi

    export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"
    # Persist PATH for login shells: volumes mount over ~/.cargo at runtime,
    # so the hook must live in profile.d (written every boot, idempotent).
    echo 'export PATH="$HOME/.cargo/bin:/usr/local/go/bin:$PATH"' | sudo tee /etc/profile.d/runtime-toolchains.sh > /dev/null
    sudo chmod 0644 /etc/profile.d/runtime-toolchains.sh
}
