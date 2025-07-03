#!/bin/bash
# Main UI menu script for Pi-Backup-Installer

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Config file not found at $CONFIG_FILE"
fi

# Functions to get backup info
BACKUP_DIR="$INSTALL_DIR/backups"

get_last_backup_date() {
  latest_file=$(ls -t "$BACKUP_DIR"/*.img.gz 2>/dev/null | head -n 1)
  [[ -n "$latest_file" ]] && date -r "$latest_file" "+%Y-%m-%d %H:%M:%S" || echo "No backups yet"
}

get_backup_count() {
  find "$BACKUP_DIR" -name "*.img.gz" 2>/dev/null | wc -l
}

get_backup_size() {
  du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "0"
}

get_next_backup_time() {
  if [[ "$AUTO_BACKUP_ENABLED" == "yes" ]]; then
    systemctl list-timers --all | grep sdcard-backup.timer | awk '{print $1, $2, $3}' || echo "Unknown"
  else
    echo "Disabled"
  fi
}

# Detect if Kiauh is installed for this user
KIAUH_PATH="$HOME/kiauh"
kiauh_installed=false
[ -x "$KIAUH_PATH/kiauh.sh" ] && kiauh_installed=true

while true; do
  last_backup=$(get_last_backup_date)
  backup_count=$(get_backup_count)
  backup_size=$(get_backup_size)
  next_backup=$(get_next_backup_time)

  clear
  echo "Welcome to Pi-Backup-Installer UI"
  echo "────────────────────────────────────"
  echo "Last Backup:        $last_backup"
  echo "Total Backups:      $backup_count"
  echo "Disk Used (Backups): $backup_size"
  echo "Next Auto-Backup:   $next_backup"
  echo "────────────────────────────────────"
  echo ""
  echo "1) SD Card Backup Utility"
  if $kiauh_installed; then
    echo "2) Run Kiauh (Klipper Installation And Update Helper)"
    echo "3) Option 3 (Coming Soon)"
    echo "q) Exit to Terminal"
  else
    echo "2) Option 2 (Coming Soon)"
    echo "3) Option 3 (Coming Soon)"
    echo "q) Exit to Terminal"
  fi
  echo ""
  read -rp "Enter choice: " choice

  case "$choice" in
    1)
      bash "$INSTALL_DIR/backup_menu.sh"
      ;;
    2)
      if $kiauh_installed; then
        bash "$KIAUH_PATH/kiauh.sh"
      else
        echo "Option 2 is not available."
        sleep 1
      fi
      ;;
    3)
      echo "Coming soon..."
      sleep 1
      ;;
    q|Q)
      echo "Exiting to terminal..."
      # Optionally run MOTD scripts here
      if [ -d /etc/update-motd.d ]; then
        run-parts /etc/update-motd.d
      fi
      exec bash
      ;;
    *)
      echo "Invalid choice."
      sleep 1
      ;;
  esac
done
