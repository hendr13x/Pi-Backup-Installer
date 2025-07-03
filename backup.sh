#!/bin/bash
# backup.sh - Manual Backup Script

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
NAS_CREDENTIALS="$INSTALL_DIR/credentials/nas_creds"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Configuration file not found at $CONFIG_FILE"
  exit 1
fi

# Load NAS credentials
if [ -f "$NAS_CREDENTIALS" ]; then
  source "$NAS_CREDENTIALS"
else
  echo "⚠️ NAS credentials file not found at $NAS_CREDENTIALS"
  exit 1
fi

# Create backup directory
BACKUP_DIR="/mnt/backup"
mkdir -p "$BACKUP_DIR"

# Mount NAS share
mount -t cifs -o username="$NAS_USER",password="$NAS_PASS" "//${NAS_IP}/${NAS_SHARE}" "$BACKUP_DIR"
if [ $? -ne 0 ]; then
  echo "❌ Failed to mount NAS share"
  exit 1
fi

# Perform the backup (example: copying files)
rsync -av --delete / "$BACKUP_DIR/backup_$(date +%Y%m%d%H%M%S)"

# Unmount NAS share
umount "$BACKUP_DIR"

echo "✅ Backup completed successfully"
