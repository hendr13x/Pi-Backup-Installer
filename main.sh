#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
BACKUP_DIR="$INSTALL_DIR/backups"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Config file not found at $CONFIG_FILE"
fi

# Functions

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

KIAUH_PATH="$HOME/kiauh"
KIAUH_PROMPT_FILE="$HOME/.kiauh_prompt_done"

kiauh_installed=false
[ -x "$KIAUH_PATH/kiauh.sh" ] && kiauh_installed=true

# Prompt to install Kiauh if not installed and not prompted before
if ! $kiauh_installed && [ ! -f "$KIAUH_PROMPT_FILE" ]; then
  echo
  echo "Kiauh (Klipper Installation And Update Helper) is not installed."
  read -rp "Would you like to install Kiauh now? (y/n): " install_kiauh
  if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
    echo "Installing Kiauh..."
    git clone https://github.com/dw-0/kiauh.git "$KIAUH_PATH"
    if [ $? -eq 0 ]; then
      echo "Kiauh installed successfully!"
      kiauh_installed=true
    else
      echo "Error installing Kiauh."
    fi
    sleep 2
  fi
  touch "$KIAUH_PROMPT_FILE"
fi

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
  if $kiauh_installed; then
    echo "2) Run Kiauh"
  fi
  echo "3) Option 3 (Coming Soon)"
  echo "q) Exit to Terminal"
  echo
  read -rp "Enter choice: " choice

  case "$choice" in
    1)
      bash "$INSTALL_DIR/backup_menu.sh"
      ;;
    2)
      if $kiauh_installed; then
        bash "$KIAUH_PATH/kiauh.sh"
      else
        echo "Kiauh is not installed."
        sleep 1
      fi
      ;;
    3)
      echo "Coming soon..."
      sleep 1
      ;;
    q|Q)
      echo "Returning to terminal..."
      # Re-run MOTD if present
      if [ -d /etc/update-motd.d ]; then
        run-parts /etc/update-motd.d
      fi
      # Start a fresh shell session
      exec bash
      ;;
    *)
      echo "Invalid option"
      sleep 1
      ;;
  esac
done
