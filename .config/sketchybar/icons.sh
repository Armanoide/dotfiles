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
    *Aperçu*)                           echo ":preview:";;
    *App\ Cleaner*)                     echo ":app_cleaner:";;
    *Moniteur\ d*activité*)             echo ":activity_monitor:";;
    *Finder*)                           echo ":finder:";;
    *Notes*)                            echo ":notes:";;
    *Leader\ Key*)                      echo ":leader_key:";;
    *Raycast*)                          echo ":raycast:";;
    *)                                  echo ":default:";;
  esac
}
