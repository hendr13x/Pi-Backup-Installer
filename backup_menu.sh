#!/bin/bash

INSTALL_DIR="$HOME/backup-installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

mkdir -p "$INSTALL_DIR/backups"

# Create default config if missing
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat << EOF > "$CONFIG_FILE"
NAS_IP=192.168.1.100
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

show_backup_config_menu() {
  while true; do
    source "$CONFIG_FILE"
    backup_count=$(ls "$INSTALL_DIR/backups"/*.img.gz 2>/dev/null | wc -l)
    clear
    echo "Configure Backup Settings:"
    echo "1) NAS IP/Hostname         (Current: $NAS_IP)"
    echo "2) NAS Share               (Current: $NAS_SHARE)"
    echo "3) NAS Username            (Current: $NAS_USER)"
    echo "4) Max Backups to Keep     (Current: $MAX_BACKUPS; Saved: $backup_count)"
    echo "5) Automatic Backups       (Enabled: $AUTO_BACKUP_ENABLED; Schedule: $AUTO_BACKUP_SCHEDULE)"
    echo "6) Return to Backup Menu"
    echo
    read -rp "Select option: " opt
    case $opt in
      1) read -rp "New NAS IP: " v; sed -i "s/^NAS_IP=.*/NAS_IP=$v/" "$CONFIG_FILE" ;;
      2) read -rp "New Share: " v; sed -i "s/^NAS_SHARE=.*/NAS_SHARE=$v/" "$CONFIG_FILE" ;;
      3) read -rp "New Username: " v; sed -i "s/^NAS_USER=.*/NAS_USER=$v/" "$CONFIG_FILE" ;;
      4) read -rp "Max backups to keep: " v; sed -i "s/^MAX_BACKUPS=.*/MAX_BACKUPS=$v/" "$CONFIG_FILE" ;;
      5)
        read -rp "Enable auto backup (yes/no): " en
        read -rp "Schedule (daily/weekly): " sch
        sed -i "s/^AUTO_BACKUP_ENABLED=.*/AUTO_BACKUP_ENABLED=$en/" "$CONFIG_FILE"
        sed -i "s/^AUTO_BACKUP_SCHEDULE=.*/AUTO_BACKUP_SCHEDULE=$sch/" "$CONFIG_FILE"
        ;;
      6) break ;;
      *) echo "Invalid"; sleep 1 ;;
    esac
  done
}

echo
echo "SD Card Backup Utility"
echo "------------------------"
echo "1) Run Manual Backup Now"
echo "2) Configure Backup Settings"
echo "3) Return to Main Menu"
echo
read -rp "Select option: " bchoice

case "$bchoice" in
  1) "$INSTALL_DIR/backup_sdcard.sh" ;;
  2) show_backup_config_menu ;;
  3) ;;
  *) echo "Invalid"; sleep 1 ;;
esac
