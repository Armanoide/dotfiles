#!/bin/sh

if [[ -f /opt/homebrew/Cellar/ncurses/6.5/share/terminfo/78/xterm-ghostty ]]; then
    echo "skipping xterm-ghostty terminfo install"
else
  echo "Installing xterm-ghostty terminfo"
  mkdir -p /opt/homebrew/Cellar/ncurses/6.5/share/terminfo/78/
   cp x/xterm-ghostty /opt/homebrew/Cellar/ncurses/6.5/share/terminfo/78/ 
fi


