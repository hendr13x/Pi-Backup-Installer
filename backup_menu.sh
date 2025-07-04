#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"

function configure_settings() {
  while true; do
    unset NAS_IP NAS_SHARE MAX_BACKUPS AUTO_BACKUP_ENABLED AUTO_BACKUP_SCHEDULE BACKUP_BASENAME
    unset username password
    source "$CONFIG_FILE" 2>/dev/null
    source "$CREDS_FILE" 2>/dev/null
    clear
    echo "Configure Backup Settings:"
    echo "1) NAS IP/Hostname         (Current: $NAS_IP)"
    echo "2) NAS Share               (Current: ${NAS_SHARE//\\/\\\\})"
    echo "3) NAS Username            (Current: $username)"
    echo "4) NAS Password            (Stored)"
    echo "5) Max Backups to Keep     (Current: $MAX_BACKUPS)"
    echo "6) Automatic Backups       (Enabled: $AUTO_BACKUP_ENABLED; Schedule: $AUTO_BACKUP_SCHEDULE)"
    echo "7) Backup Filename Prefix  (Current: $BACKUP_BASENAME)"
    echo "q) Return to Backup Menu"
    echo
    read -rp "Select option: " opt

    case $opt in
      1)
        read -rp "New NAS IP: " v
        echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_config NAS_IP
        ;;
      2)
        read -rp "New Share: " v
        echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_config NAS_SHARE
        ;;
      3)
        read -rp "New Username: " v
        echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_cred username
        ;;
      4)
        read -rp "New Password: " v
        echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_cred password
        ;;
      5)
        read -rp "Max backups to keep (1–50): " v
        if [[ "$v" =~ ^[0-9]+$ ]] && (( v >= 1 && v <= 50 )); then
          echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_config MAX_BACKUPS
        else
          echo "Invalid input. Must be a number between 1 and 50."
          sleep 2
        fi
        ;;
      6)
        read -rp "Enable Auto Backup (yes/no): " en
        read -rp "Schedule (daily/weekly/monthly): " sch
        echo "$en" | sudo "$INSTALL_DIR/write_config.sh" set_config AUTO_BACKUP_ENABLED
        echo "$sch" | sudo "$INSTALL_DIR/write_config.sh" set_config AUTO_BACKUP_SCHEDULE
        ;;
      7)
        read -rp "Backup filename prefix: " v
        echo "$v" | sudo "$INSTALL_DIR/write_config.sh" set_config BACKUP_BASENAME
        ;;
      q|Q)
        return
        ;;
      *)
        echo "Invalid option"
        sleep 2
        ;;
    esac
  done
}

function backup_menu() {
  while true; do
    clear
    echo "SD Card Backup Utility"
    echo "------------------------"
    echo "1) Run Manual Backup Now"
    echo "2) Configure Backup Settings"
    echo "q) Return to Main Menu"
    echo
    read -rp "Select option: " opt
    case $opt in
      1)
        sudo "$INSTALL_DIR/backup_sdcard.sh"
        read -rp "Press Enter to return..."
        ;;
      2)
        configure_settings
        ;;
      q|Q)
        break
        ;;
      *)
        echo "Invalid option"
        sleep 2
        ;;
    esac
  done
}

backup_menu
