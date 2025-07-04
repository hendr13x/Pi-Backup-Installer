#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_POINT="/mnt/backup_nas"

mkdir -p "$MOUNT_POINT"

# Load NAS config values
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if ! mount -t cifs "//${NAS_IP}/${NAS_SHARE}" "$MOUNT_POINT" -o credentials="$CREDS_FILE",vers=3.0 2>/dev/null; then
    echo -e "\n[WARNING] Could not connect to NAS at //${NAS_IP}/${NAS_SHARE}. Backup UI will still load.\n"
  fi
else
  echo -e "\n[WARNING] Missing NAS config. Skipping NAS mount attempt.\n"
fi

show_main_menu() {
  while true; do
    clear
    echo "Pi Backup Manager"
    echo "-------------------"
    echo "1) Launch SD Card Backup Utility"
    echo "2) Launch KIAUH (if installed)"
    echo "q) Exit to terminal"
    echo
    read -rp "Select option: " choice
    case "$choice" in
      1) bash "$INSTALL_DIR/backup_menu.sh" ;;
      2) [[ -f "$HOME/kiauh/kiauh.sh" ]] && bash "$HOME/kiauh/kiauh.sh" || echo "KIAUH not found at ~/kiauh" ;;
      q|Q) break ;;
      *) echo "Invalid"; sleep 1 ;;
    esac
  done
}

show_main_menu
clear

# Show Armbian welcome message again after menu exit
if [[ -f /etc/update-motd.d/30-armbian-sysinfo ]]; then
  /etc/update-motd.d/30-armbian-sysinfo
fi

exit 0
