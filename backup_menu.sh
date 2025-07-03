#!/bin/bash
INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Config file missing at $CONFIG_FILE"
fi

while true; do
  clear
  echo "SD Card Backup Utility"
  echo "------------------------"
  echo "1) Run Manual Backup Now"
  echo "2) Configure Backup Settings"
  echo "3) Return to Main Menu"
  echo ""
  read -rp "Select option: " opt

  case "$opt" in
    1)
      # Run manual backup script (you need to implement backup.sh or equivalent)
      if [ -x "$INSTALL_DIR/backup.sh" ]; then
        bash "$INSTALL_DIR/backup.sh"
      else
        echo "Backup script not found."
      fi
      read -rp "Press Enter to continue..."
      ;;
    2)
      bash "$INSTALL_DIR/configure_backup.sh"
      ;;
    3)
      break
      ;;
    *)
      echo "Invalid option."
      sleep 1
      ;;
  esac
done
