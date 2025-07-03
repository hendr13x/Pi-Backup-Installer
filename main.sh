#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
BACKUP_DIR="$INSTALL_DIR/backups"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config
source "$CONFIG_FILE"

# Detect Kiauh prompt marker
KIAUH_PROMPT_FLAG="$HOME/.config/.kiauh_prompted"

# Prompt user to install Kiauh on first login
if [[ ! -f "$KIAUH_PROMPT_FLAG" ]]; then
  echo
  echo "🔧 Would you like to install KIAUH (Klipper Installation And Update Helper)?"
  read -rp "Install KIAUH to ~/kiauh? (y/n): " install_kiauh
  if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
    git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"
    echo "✅ KIAUH installed to ~/kiauh"
  else
    echo "❌ KIAUH installation skipped"
  fi
  mkdir -p "$HOME/.config"
  touch "$KIAUH_PROMPT_FLAG"
  sleep 2
fi

# Runtime info helpers
get_last_backup_date() {
  latest_file=$(ls -t "$BACKUP_DIR"/*.img.gz 2>/dev/null | head -n 1)
  [[ -n "$latest_file" ]] && date -r "$latest_file" || echo "No backups yet"
}

get_backup_count() {
  find "$BACKUP_DIR" -name "*.img.gz" 2>/dev/null | wc -l
}

get_backup_size() {
  du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1
}

get_next_backup_time() {
  if [[ "$AUTO_BACKUP_ENABLED" == "yes" ]]; then
    systemctl list-timers --all | grep sdcard-backup.timer | awk '{print $1, $2, $3}' || echo "Unknown"
  else
    echo "Disabled"
  fi
}

# Check if Kiauh exists in user home
kiauh_installed=false
[ -d "$HOME/kiauh" ] && kiauh_installed=true

# UI Loop
while true; do
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
  $kiauh_installed && echo "2) Run KIAUH (Klipper Installation And Update Helper)"
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
        echo "KIAUH not found in your home directory."
        sleep 1
      fi
      ;;
    3) echo "Coming soon..."; sleep 1 ;;
    q|Q)
      echo "Returning to terminal..."
      # Re-run MOTD if available
      if [ -d /etc/update-motd.d ]; then
        run-parts /etc/update-motd.d
      fi
      exec bash
      ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
