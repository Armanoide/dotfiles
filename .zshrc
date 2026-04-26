# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

case "$(uname -s)" in
    Darwin) OS='mac' ;;
    Linux)  OS='linux' ;;
    *)      OS='unknown' ;;
esac

############################################################
# System & OS
############################################################

# Source private secrets
if [[ -f "$HOME/.zshrc_secret" ]]; then
    source "$HOME/.zshrc_secret"
fi

# You may need to manually set your language environmentj
unset LC_ALL
export LANG=en_US.UTF-8

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

export TERMINFO="$HOME/.config/terminfo"
if [[ "$OS" == "mac" ]]; then
  # Override system ncurses for better compatibility with some tools
  export PATH="/opt/homebrew/opt/ncurses/bin:$PATH"
  if [[ -z "$TERMINFO_DIRS" ]]; then
      export TERMINFO_DIRS="/opt/homebrew/Cellar/ncurses/6.5/share/terminfo:$TERMINFO_DIRS"
  else
      export TERMINFO_DIRS="/opt/homebrew/Cellar/ncurses/6.5/share/terminfo:$TERMINFO_DIRS"
  fi
  export TERMINFO_DIRS="/opt/homebrew/Cellar/ncurses/6.5/share/terminfo:$TERMINFO_DIRS"
  # Force program to use Ghostty feature such as yazi with preview
  export TERM_PROGRAM=Ghostty
fi

# custom binary
PATH="$HOME/.local/rbin:$PATH"
PATH="$HOME/.local/bin:$PATH"

# SSH Agent Symlink Fix (Server-only)
if [[ "$USE_AUTH_SOCK" == "true" ]]; then
  TARGET="$HOME/.ssh/ssh_auth_sock"
  if [[ -n "$SSH_CONNECTION" && -S "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$TARGET" ]]; then
      # Ensure the directory exists first
      mkdir -p "$(dirname "$TARGET")"
      ln -sf "$SSH_AUTH_SOCK" "$TARGET"
  fi
  if [[ -S "$TARGET" ]]; then
      export SSH_AUTH_SOCK="$TARGET"
  fi
fi
 # tmux auto-attach when in SSH
 if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -n "$PS1" ]]; then
    tmux attach || tmux new
    eval $(tmux showenv -s | grep -E '^(SSH|DISPLAY)')
 fi

############################################################
#  UI & Prompt & Colors
############################################################

source $ZSH/oh-my-zsh.sh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# vivid colors for ls
export LS_COLORS="$(vivid generate catppuccin-mocha)"

# zsh completion
fpath+=~/.zfunc; autoload -Uz compinit; compinit

# fzf → fuzzy search, completion, and keybindings
source <(fzf --zsh)
if [[ "$OS" == "mac" ]]; then
  [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  [ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

############################################################
# Homebrew Setup
############################################################

if [[ "$OS" == "mac" ]]; then
  # Ensure Homebrew bin in PATH
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

  # Install Homebrew if not present
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Load Homebrew into PATH (Apple Silicon)
  eval "$(/opt/homebrew/bin/brew shellenv)"

  export HOMEBREW_EDITOR=nvim
fi

############################################################
# Languages & tools
############################################################

if [[ "$OS" == "mac" ]]; then
  export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
  # The following lines have been added by Docker Desktop to enable Docker CLI completions.
  fpath=(/Volumes/EXT1_SSD/Users/user1/.docker/completions $fpath)
  autoload -Uz compinit
  compinit
  # End of Docker CLI completions
fi

# Ruby
if [[ "$OS" == "mac" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
  eval "$(rbenv init -)"
  export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
  export PATH="$HOME/.rbenv/shims:$PATH"
fi

# Python & pip
if [[ "$OS" == "mac" ]]; then
 export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
 alias pip3='python3 -m pip'
fi

# Pyenv
if [[ "$OS" == "mac" ]]; then
  eval "$(pyenv init -)"
fi

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Rust & Cargo
if [[ "$OS" == "mac" ]]; then
  . "$HOME/.cargo/env"
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# NVM
if [[ "$OS" == "mac" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Bun completions
[ -s "/$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# QT for UIC
export PATH="/opt/homebrew/Cellar/qt/6.7.3/share/qt/libexec:$PATH"

# Anaconda
if [[ "$OS" == "mac" ]]; then
  export PATH="/opt/homebrew/anaconda3/bin:$PATH"
fi

# LM Studio CLI
if [[ "$OS" == "mac" ]]; then
  # Added by LM Studio CLI (lms)
  export PATH="$PATH:$HOME/.lmstudio/bin"
  # End of LM Studio CLI section
fi

############################################################
# Mobile Development
############################################################

if [[ "$OS" == "mac" ]]; then
  # Maestro
  export PATH=$PATH:$HOME/.maestro/bin
  alias maestro_upgrade="curl -Ls "https://get.maestro.mobile.dev" | bash"

  # Android SDK
  export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
  export ANDROID_HOME=$ANDROID_SDK_ROOT
  export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
  export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
  export PATH=$PATH:$ANDROID_SDK_ROOT/tools
  alias android-fix-server="adb kill-server && adb start-server && adb reverse tcp:8081 tcp:8081"
fi

############################################################
# Aliases
############################################################

# ls
alias l=eza
alias ls=eza
alias ll='eza -la --group-directories-first --icons'

# cat
alias b=bat

# Tailscale
if [[ "$OS" == "mac" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
fi

# Xcode
if [[ "$OS" == "mac" ]]; then
  alias xcodeclean='sudo rm -rf ~/Library/Developer/Xcode/DerivedData'
fi

# General
if [[ "$OS" == "mac" ]]; then
  alias allow_app='sudo xattr -rd com.apple.quarantine --'
fi

# Apply Brewfile
if [[ "$OS" == "mac" ]]; then
  alias brew_restore='brew bundle --file="$HOME/.config/homebrew/Brewfile"'
  alias brew_dump='brew bundle dump --file=$HOME/.config/homebrew/Brewfile --force'
fi

# zoxide → smarter directory jumps
eval "$(zoxide init zsh --cmd cd)"
alias z=zoxide

alias garage="docker exec -ti garage /garage"
alias picoclaw="docker exec -ti picoclaw_gateway picoclaw"
alias opencode="docker exec -ti opencode opencode"

# ############################################################
# # 🔑 bitwarden SSH Agent
# ############################################################

if [ -S "$HOME/.bitwarden-ssh-agent.sock" ]; then
  export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
fi



