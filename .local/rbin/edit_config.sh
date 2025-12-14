#!/bin/zsh

edit-config() {
  # 'typeset -A' creates an associative array in Zsh
  typeset -A configs
  configs=(
    "lazyvim/nvim"    "$HOME/.config/nvim"
    "ghostty"    "$HOME/.config/ghostty/config"
    "aerospace"  "$HOME/.config/aerospace/aerospace.toml"
    "sketchybar" "$HOME/.config/sketchybar"
    "leader-key" "$HOME/.config/leader-key/config.json"
    "zshrc"      "$HOME/.zshrc"
  )

  # Get keys using Zsh syntax: ${(k)configs}
  local choice=$(printf "%s\n" "${(@k)configs}" | fzf --prompt="Edit Config ❯ " --height=40% --layout=reverse --border)

  if [[ -n "$choice" ]]; then
    local target="${configs[$choice]}"

    # Check if target is a directory
    if [[ -d "$target" ]]; then
      cd "$target"
    else
      # If it's a file, cd into the directory containing the file
      cd "${target:h}"
    fi

    # Now open nvim (either the directory or the file)
    nvim "$target"
  fi
}

# Run the function
edit-config
