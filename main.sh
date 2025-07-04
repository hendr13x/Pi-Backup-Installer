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
    if [[ -f "$HOME/kiauh/kiauh.sh" ]]; then
      echo "2) Launch KIAUH"
    else
      echo "2) Install KIAUH"
    fi
    echo "q) Exit to terminal"
    echo
    read -rp "Select option: " choice
    case "$choice" in
      1) bash "$INSTALL_DIR/backup_menu.sh" ;;
      2)
        if [[ -f "$HOME/kiauh/kiauh.sh" ]]; then
          bash "$HOME/kiauh/kiauh.sh"
        else
          echo "[INFO] KIAUH not found. Installing to \$HOME/kiauh..."
          git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"
          echo "[INFO] Installation complete. You can now run it with: ./kiauh/kiauh.sh"
        fi
        ;;
      q|Q)
        clear
        break
        ;;
      *) echo "Invalid"; sleep 1 ;;
    esac
  done
}

show_main_menu

# Show Armbian welcome message again after menu exit
if [[ -f /etc/update-motd.d/30-armbian-sysinfo ]]; then
  /etc/update-motd.d/30-armbian-sysinfo
fi

exit 0
