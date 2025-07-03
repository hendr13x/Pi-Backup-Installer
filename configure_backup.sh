#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Creating default config file at $CONFIG_FILE"
  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" <<EOF
# Pi Backup Installer Settings
AUTO_BACKUP_ENABLED=no
BACKUP_PATH=/opt/Pi-Backup-Installer/backups
EOF
fi

# Open config in nano (or your preferred editor)
nano "$CONFIG_FILE"
