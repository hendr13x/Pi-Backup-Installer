#!/bin/bash

set -e

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_POINT="/mnt/backup"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILENAME="backup_$DATE.img.gz"
NAS_TARGET_PATH="$MOUNT_POINT/$BACKUP_FILENAME"

# Load settings
source "$CONFIG_FILE"

# Read credentials securely
if [[ ! -r "$CREDENTIALS_FILE" ]]; then
  echo "❌ Missing or unreadable NAS credentials at $CREDENTIALS_FILE"
  exit 1
fi

source "$CREDENTIALS_FILE"

# Mount NAS share
echo "🔗 Mounting NAS share at $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"
sudo mount -t cifs "//$NAS_IP/$NAS_SHARE" "$MOUNT_POINT" \
  -o username="$username",password="$password",rw,vers=3.0,uid=$(id -u),gid=$(id -g)

# Backup directly to NAS
echo "💾 Creating SD card backup directly to NAS..."
sudo dd if=/dev/mmcblk0 bs=4M status=progress conv=fsync | gzip > "$NAS_TARGET_PATH"

# Unmount
echo "🔌 Unmounting NAS share..."
sudo umount "$MOUNT_POINT"

echo "✅ Backup complete: $NAS_TARGET_PATH"
read -rp "Press Enter to continue..."
