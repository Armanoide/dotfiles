#!/usr/bin/env bash
# Télécharge les thèmes catppuccin (accent mauve) pour atuin depuis le repo officiel.
# Idempotent : relançable à volonté, écrase les fichiers existants.
# https://github.com/catppuccin/atuin
set -euo pipefail

DEST="${XDG_CONFIG_HOME:-$HOME/.config}/atuin/themes"
mkdir -p "$DEST"

for flavor in mocha macchiato frappe latte; do
  curl -fsSL -o "$DEST/catppuccin-$flavor-mauve.toml" \
    "https://raw.githubusercontent.com/catppuccin/atuin/main/themes/$flavor/catppuccin-$flavor-mauve.toml"
  echo "OK catppuccin-$flavor-mauve"
done
