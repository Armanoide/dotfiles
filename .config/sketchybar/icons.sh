#!/bin/bash

get_icon() {
  app="$1"

  case "$app" in
    *Google\ Chrome*)                   echo "󰊯";;
    *Safari*)                           echo "";;
    *TV*)                               echo "";;
    *Messages*)                         echo "";;
    *Screen*)                           echo "󰍺";;
    *Tor*)                              echo "";;
    *Terminal*)                         echo "";;
    *Système*)                          echo "";;
    *Mots\ de\ passe*)                  echo "󰟵";;
    *Ghostty*)                          echo "󱙝";;
    *TextEdit*)                         echo "󰂮";;
    *Cleaner*)                          echo "󱝧";;
    *Finder*)                           echo "󰀶";;
    *Notes*)                            echo "󱞁";;
    *)                                  echo " ";;
  esac
}
