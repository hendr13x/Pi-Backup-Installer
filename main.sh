#!/bin/bash

INSTALL_DIR="$HOME/backup-installer"

get_last_backup_date() {
  latest_file=$(ls -t "$INSTALL_DIR"/backups/*.img.gz 2>/dev/null | head -n 1)
  [[ -n "$latest_file" ]] && date -r "$latest_file" || echo "No backups yet"
}

last_backup=$(get_last_backup_date)
kiauh_installed=false
[ -d "$HOME/kiauh" ] && kiauh_installed=true

while true; do
  clear
  echo "Welcome"
  echo "Last Backup: $last_backup"
  echo
  echo "1) SD Card Backup Utility"
  $kiauh_installed && echo "2) Run Kiauh"
  echo "3) Option 3 (Coming Soon)"
  echo "q) Exit to Shell"
  echo
  read -rp "Enter choice: " choice

  case "$choice" in
    1) "$INSTALL_DIR/backup_menu.sh" ;;
    2) $kiauh_installed && "$HOME/kiauh/kiauh.sh" ;;
    3) echo "Coming soon..."; sleep 1 ;;
    q|Q) exit 0 ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
