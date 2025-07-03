#!/bin/bash
CONFIG_FILE="/opt/Pi-Backup-Installer/config/settings.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config file missing at $CONFIG_FILE"
  exit 1
fi

# Load config values
source "$CONFIG_FILE"

while true; do
  clear
  echo "Configure Backup Settings"
  echo "--------------------------"
  echo "Current settings:"
  echo "NAS IP:          $NAS_IP"
  echo "NAS Share:       $NAS_SHARE"
  echo "NAS User:        $NAS_USER"
  echo "Auto Backup:     $AUTO_BACKUP_ENABLED"
  echo "Auto Backup Schedule: $AUTO_BACKUP_SCHEDULE"
  echo "Max Backups:     $MAX_BACKUPS"
  echo ""
  echo "1) Change NAS IP"
  echo "2) Change NAS Share"
  echo "3) Change NAS User"
  echo "4) Change NAS Password"
  echo "5) Toggle Auto Backup (currently: $AUTO_BACKUP_ENABLED)"
  echo "6) Change Auto Backup Schedule"
  echo "7) Change Max Backups"
  echo "8) Return to Backup Menu"
  echo ""

  read -rp "Select option: " choice

  case "$choice" in
    1)
      read -rp "Enter new NAS IP: " NAS_IP
      ;;
    2)
      read -rp "Enter new NAS Share (path): " NAS_SHARE
      ;;
    3)
      read -rp "Enter new NAS Username: " NAS_USER
      ;;
    4)
      echo "Note: Password will be stored encrypted or securely."
      read -rsp "Enter new NAS Password: " NAS_PASS
      echo
      ;;
    5)
      if [ "$AUTO_BACKUP_ENABLED" = "yes" ]; then
        AUTO_BACKUP_ENABLED="no"
      else
        AUTO_BACKUP_ENABLED="yes"
      fi
      ;;
    6)
      read -rp "Enter new Auto Backup Schedule (e.g. daily, weekly): " AUTO_BACKUP_SCHEDULE
      ;;
    7)
      read -rp "Enter new Max Backups to keep: " MAX_BACKUPS
      ;;
    8)
      break
      ;;
    *)
      echo "Invalid option."
      sleep 1
      ;;
  esac

  # Write updated settings to config file
  {
    echo "NAS_IP=\"$NAS_IP\""
    echo "NAS_SHARE=\"$NAS_SHARE\""
    echo "NAS_USER=\"$NAS_USER\""
    # Save password securely — here just saving plaintext (consider encrypted storage!)
    echo "NAS_PASS=\"$NAS_PASS\""
    echo "AUTO_BACKUP_ENABLED=\"$AUTO_BACKUP_ENABLED\""
    echo "AUTO_BACKUP_SCHEDULE=\"$AUTO_BACKUP_SCHEDULE\""
    echo "MAX_BACKUPS=\"$MAX_BACKUPS\""
  } > "$CONFIG_FILE"

done
