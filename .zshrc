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

source $ZSH/oh-my-zsh.sh

############################################################
# 🛠️ Homebrew Setup
############################################################
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

############################################################
# ✏️ Editor
############################################################
export HOMEBREW_EDITOR=nvim
export EDITOR="nvim"
export VISUAL="nvim"


############################################################
# 🐘 Databases
############################################################
# PostgreSQL
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
alias postgresql_bg='/opt/homebrew/opt/postgresql@15/bin/postgres -D /opt/homebrew/var/postgresql@15'

# libpq (psql client tools)
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"


############################################################
# 💎 Ruby (rbenv)
############################################################
export PATH="$HOME/.rbenv/bin:$PATH"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
eval "$(rbenv init -)"
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"


############################################################
# 🐍 Python
############################################################
# Python & pip
export PATH="/opt/homebrew/opt/python@3.13/bin:$PATH"
alias pip3='python3 -m pip'

# pyenv
eval "$(pyenv init -)"


############################################################
# 📱 Mobile Development
############################################################
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


############################################################
# ☕ Java
############################################################
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"


############################################################
# 🦀 Rust & Cargo
############################################################
. "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"


############################################################
# 🧰 Other Languages & Tools
############################################################
# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Bun
export PATH="/Volumes/EXT1_SSD/Users/user1/.bun/bin:$PATH"

# QT for UIC
export PATH="/opt/homebrew/Cellar/qt/6.7.3/share/qt/libexec:$PATH"

# Elasticsearch
export ES_JAVA_HOME=/opt/homebrew/opt/openjdk

############################################################
# ☁️ Cloud & CLI
############################################################
# Google Cloud SDK
if [ -f '/Volumes/EXT1_SSD/Users/user1/Projects/Scripts/Combo/combo-cli/google-cloud-sdk/path.zsh.inc' ]; then
  . '/Volumes/EXT1_SSD/Users/user1/Projects/Scripts/Combo/combo-cli/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/Volumes/EXT1_SSD/Users/user1/Projects/Scripts/Combo/combo-cli/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Volumes/EXT1_SSD/Users/user1/Projects/Scripts/Combo/combo-cli/google-cloud-sdk/completion.zsh.inc'
fi


############################################################
# 🤖 AI / ML
############################################################
# LM Studio
export PATH="$PATH:/Volumes/EXT1_SSD/Users/user1/.lmstudio/bin"

# Windsurf
export PATH="/Volumes/EXT1_SSD/Users/user1/.codeium/windsurf/bin:$PATH"

# Ollama
export OLLAMA_BACKEND=mlx


############################################################
# ⚡ Aliases
############################################################
# Xcode
alias xcodeclean='sudo rm -rf ~/Library/Developer/Xcode/DerivedData'

# Combo CLI shortcuts
alias combo-download=combo-cli
alias combo-ra=k9s
alias combo-logs=stern

# General
alias allow_app='sudo xattr -rd com.apple.quarantine --'

# Apply Brewfile
alias brew_restore='brew bundle --file="$HOME/.config/homebrew/Brewfile"'
alias brew_dump='brew bundle dump --file=$HOME/.config/homebrew/Brewfile --force'

############################################################
# 📂 Navigation & File Tools
############################################################

# ls
alias l=eza
alias ls=eza
# ls 
alias ll='eza -la --group-directories-first --icons'
# cat
alias b=bat


############################################################
# 🔍 Productivity: fzf & zoxide
############################################################
# fzf → fuzzy search, completion, and keybindings
source <(fzf --zsh)
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh

# zoxide → smarter directory jumps
eval "$(zoxide init zsh --cmd cd)"
alias z=zoxide


############################################################
# 🎨 UI/Prompt/Colors
############################################################
# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# vivid colors for ls
export LS_COLORS="$(vivid generate catppuccin-mocha)"


############################################################
# 🔧 Init Shell
############################################################

# You may need to manually set your language environmentj
export LANG=en_US.UTF-8

# Override system ncurses for better compatibility with some tools
export PATH="/opt/homebrew/opt/ncurses/bin:$PATH"
export TERMINFO_DIRS="/opt/homebrew/Cellar/ncurses/6.5/share/terminfo:$TERMINFO_DIRS"
export TERMINFO="$HOME/.config/terminfo"
# Force program to use Ghostty feature such as yazi with preview
export TERM_PROGRAM=Ghostty
# export TERM=xterm-ghostty
# zsh completion
fpath+=~/.zfunc; autoload -Uz compinit; compinit

 # tmux auto-attach when in SSH
 if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -t 1 ]]; then
     tmux attach || tmux new
 fi
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
alias postgresql_bg='/opt/homebrew/opt/postgresql@15/bin/postgres -D /opt/homebrew/var/postgresql@15'
