#!/bin/bash

set -e

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_POINT="/mnt/backup"

# Load config
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

source "$CONFIG_FILE"

# Validate credentials
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "❌ NAS credentials file not found: $CREDENTIALS_FILE"
  exit 1
fi

# Ensure mount point exists
mkdir -p "$MOUNT_POINT"

# Attempt to mount NAS share
echo "🔗 Mounting NAS share..."
mount -t cifs "//${NAS_IP}/${NAS_SHARE}" "$MOUNT_POINT" \
  -o credentials="$CREDENTIALS_FILE",vers=3.0,nounix,noserverino || {
    echo "❌ Failed to mount NAS share"
    read -p "Press Enter to continue..."
    exit 1
}

# Set backup filename
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$MOUNT_POINT/backup_$DATE.img.gz"

echo "🧩 Backing up SD card to: $BACKUP_FILE"
dd if=/dev/mmcblk0 bs=4M status=progress conv=sync,noerror | gzip > "$BACKUP_FILE"

# Cleanup old backups
echo "🧹 Cleaning up old backups (keeping latest $MAX_BACKUPS)..."
cd "$MOUNT_POINT"
ls -1tr backup_*.img.gz | head -n -"${MAX_BACKUPS}" | xargs -r rm -f

# Unmount NAS
echo "🔌 Unmounting NAS..."
umount "$MOUNT_POINT"

echo "✅ Backup completed successfully."
read -p "Press Enter to continue..."
