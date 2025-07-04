#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"

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
BACKUP_BASENAME=sd_backup
EOF
fi

show_backup_config_menu() {
  while true; do
    clear
    unset NAS_SHARE; source "$CONFIG_FILE"; NAS_USER="$(grep '^username=' "$CREDS_FILE" | cut -d'=' -f2)"
    source "$CREDS_FILE" 2>/dev/null || true
    backup_count=$(ls "$INSTALL_DIR/backups"/*.img.gz 2>/dev/null | wc -l)
    echo "Configure Backup Settings:"
    echo "1) NAS IP/Hostname         (Current: $NAS_IP)"
    echo "2) NAS Share               (Current: ${NAS_SHARE//\\/\\\\})"
    echo "3) NAS Username            (Current: $NAS_USER)"
    echo "4) NAS Password            (Stored)"
    echo "5) Max Backups to Keep     (Current: $MAX_BACKUPS; Saved: $backup_count)"
    echo "6) Automatic Backups       (Enabled: $AUTO_BACKUP_ENABLED; Schedule: $AUTO_BACKUP_SCHEDULE)"
    echo "7) Backup Filename Prefix  (Current: ${BACKUP_BASENAME:-sd_backup})"
    echo "q) Return to Backup Menu"
    echo
    read -rp "Select option: " opt
    case $opt in
      1) read -rp "New NAS IP: " v; sed -i "s/^NAS_IP=.*/NAS_IP=$v/" "$CONFIG_FILE" ;;
      2) read -rp "New Share: " v; v_escaped="${v//\\/\\\\}"; sed -i "s|^NAS_SHARE=.*|NAS_SHARE=$v_escaped|" "$CONFIG_FILE" ;;
      3) read -rp "New Username: " v; sed -i "s/^username=.*/username=$v/" "$CREDS_FILE" || echo "username=$v" >> "$CREDS_FILE" ;;
      4) read -rp "New Password: " v; sed -i "s/^password=.*/password=$v/" "$CREDS_FILE" || echo "password=$v" >> "$CREDS_FILE" ;;
      5)
        read -rp "Max backups to keep (1-50): " v
        if [[ "$v" =~ ^[0-9]+$ ]] && (( v >= 1 && v <= 50 )); then
          sed -i "s/^MAX_BACKUPS=.*/MAX_BACKUPS=$v/" "$CONFIG_FILE"
        else
          echo "[WARNING] Please enter a number between 1 and 50."; sleep 2
        fi
        ;;
      6)
        read -rp "Enable auto backup (yes/no): " en
        read -rp "Schedule (daily/weekly): " sch
        sed -i "s/^AUTO_BACKUP_ENABLED=.*/AUTO_BACKUP_ENABLED=$en/" "$CONFIG_FILE"
        sed -i "s/^AUTO_BACKUP_SCHEDULE=.*/AUTO_BACKUP_SCHEDULE=$sch/" "$CONFIG_FILE"
        ;;
      7)
        read -rp "New backup filename prefix: " v
        if grep -q '^BACKUP_BASENAME=' "$CONFIG_FILE"; then
          sed -i "s/^BACKUP_BASENAME=.*/BACKUP_BASENAME=$v/" "$CONFIG_FILE"
        else
          echo "BACKUP_BASENAME=$v" >> "$CONFIG_FILE"
        fi
        ;;
      q|Q) break ;;
      *) echo "Invalid"; sleep 1 ;;
    esac
  done
}

while true; do
  clear
  echo
  echo "SD Card Backup Utility"
  echo "------------------------"
  echo "1) Run Manual Backup Now"
  echo "2) Configure Backup Settings"
  echo "q) Return to Main Menu"
  echo
  read -rp "Select option: " bchoice

  case "$bchoice" in
    1) "$INSTALL_DIR/backup_sdcard.sh" ;;
    2) show_backup_config_menu ;;
    q|Q) break ;;
    *) echo "Invalid"; sleep 1 ;;
  esac
done
