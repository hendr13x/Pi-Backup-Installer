#!/bin/bash

INSTALL_DIR="$HOME/backup-installer"
BACKUP_DIR="$INSTALL_DIR/backups"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config
source "$CONFIG_FILE"

# Function: get last backup file date
get_last_backup_date() {
  latest_file=$(ls -t "$BACKUP_DIR"/*.img.gz 2>/dev/null | head -n 1)
  [[ -n "$latest_file" ]] && date -r "$latest_file" || echo "No backups yet"
}

# Function: count existing backups
get_backup_count() {
  find "$BACKUP_DIR" -name "*.img.gz" 2>/dev/null | wc -l
}

# Function: total disk usage by backup folder
get_backup_size() {
  du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1
}

# Function: check next scheduled auto-backup time (if enabled)
get_next_backup_time() {
  if [[ "$AUTO_BACKUP_ENABLED" == "yes" ]]; then
    systemctl list-timers --all | grep sdcard-backup.timer | awk '{print $1, $2, $3}' || echo "Unknown"
  else
    echo "Disabled"
  fi
}

kiauh_installed=false
[ -d "$HOME/kiauh" ] && kiauh_installed=true

while true; do
  # Refresh data on each loop
  last_backup=$(get_last_backup_date)
  backup_count=$(get_backup_count)
  backup_size=$(get_backup_size)
  next_backup=$(get_next_backup_time)

  clear
  echo "Welcome"
  echo "────────────────────────────────────"
  echo "Last Backup:        $last_backup"
  echo "Total Backups:      $backup_count"
  echo "Disk Used (Backups): $backup_size"
  echo "Next Auto-Backup:   $next_backup"
  echo "────────────────────────────────────"
  echo
  echo "1) SD Card Backup Utility"
  if $kiauh_installed; then
    echo "2) Run Kiauh"
  fi
  echo "3) Option 3 (Coming Soon)"
  echo "q) Exit to Terminal"
  echo
  read -rp "Enter choice: " choice

  case "$choice" in
    1) bash "$INSTALL_DIR/backup_menu.sh" ;;
    2)
      if $kiauh_installed; then
        bash "$HOME/kiauh/kiauh.sh"
      else
        echo "Kiauh is not installed."
        sleep 1
      fi
      ;;
    3) echo "Coming soon..."; sleep 1 ;;
        q|Q)
      echo "Returning to terminal..."

      # Re-run MOTD if present
      if [ -d /etc/update-motd.d ]; then
        run-parts /etc/update-motd.d
      fi

      # Start a fresh shell session
      exec bash
      ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
