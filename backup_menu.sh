#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Config file not found at $CONFIG_FILE"
  exit 1
fi

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
    # Call your manual backup script or function here
    bash "$INSTALL_DIR/manual_backup.sh"
    ;;
  2)
    # Call your configuration script or function here
    bash "$INSTALL_DIR/configure_backup.sh"
    ;;
  3)
    # Return to main menu (just exit this script)
    ;;
  *)
    echo "Invalid option."
    sleep 1
    ;;
esac
