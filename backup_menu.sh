#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

while true; do
  clear
  echo "SD Card Backup Utility"
  echo "------------------------"
  echo "1) Run Manual Backup Now"
  echo "2) Configure Backup Settings"
  echo "3) Return to Main Menu"
  echo
  read -rp "Select option: " choice

  case "$choice" in
    1)
      bash "$INSTALL_DIR/manual_backup.sh"
      ;;
    2)
      bash "$INSTALL_DIR/configure_backup.sh"
      ;;
    3)
      break
      ;;
    *)
      echo "Invalid option, please try again."
      sleep 1
      ;;
  esac
done
