#!/bin/bash

get_icon() {
  app="$1"

  case "$app" in
    *Google\ Chrome*)                   echo ":google_chrome:";;
    *Safari*)                           echo ":safari:";;
    *TV*)                               echo ":tv:";;
    *Messages*)                         echo ":messages:";;
    *Screen*)                           echo "󰍺";;
    *Tor*)                              echo ":tor_browser:";;
    *Terminal*)                         echo ":terminal:";;
    *Système*)                          echo ":gear:";;
    *Xcode*)                            echo ":xcode:";;
    *Mots\ de\ passe*)                  echo ":passwords:";;
    *Ghostty*)                          echo ":ghostty:";;
    *TextEdit*)                         echo "󰂮";;
    *Cleaner*)                          echo "󱝧";;
    *Finder*)                           echo ":finder:";;
    *Notes*)                            echo ":notes:";;
    *)                                  echo ":default:";;
  esac
}
