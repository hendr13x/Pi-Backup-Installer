#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"

# Load config
source "$CONFIG_FILE"

MOUNT_POINT="/opt/backup_mount"
BACKUP_DIR="$MOUNT_POINT/$NAS_SHARE"

# Create mount point if missing
if [ ! -d "$MOUNT_POINT" ]; then
  sudo mkdir -p "$MOUNT_POINT"
  sudo chown root:backup "$MOUNT_POINT"
  sudo chmod 775 "$MOUNT_POINT"
fi

# Mount NAS if not mounted
if ! mountpoint -q "$MOUNT_POINT"; then
  echo "🔗 Mounting NAS share..."
  sudo mount -t cifs "//$NAS_IP/$NAS_SHARE" "$MOUNT_POINT" -o credentials="$CREDENTIALS_FILE",rw,vers=3.0,uid=$(id -u),gid=$(id -g),file_mode=0664,dir_mode=0775
  if [ $? -ne 0 ]; then
    echo "❌ Failed to mount NAS share"
    read -rp "Press Enter to continue..."
    exit 1
  fi
fi

# Prepare backup file name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/sdcard_backup_$TIMESTAMP.img.gz"

# Create backup directory if missing (inside mounted NAS)
mkdir -p "$BACKUP_DIR"

echo "💾 Starting SD card backup to $BACKUP_FILE ..."

# Run the backup with sudo (needs no-password sudo for dd)
sudo dd if=/dev/mmcblk0 bs=4M status=progress | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "✅ Backup completed successfully!"
else
  echo "❌ Backup failed!"
fi

read -rp "Press Enter to continue..."

# Optional: unmount NAS (commented out to keep it mounted)
# sudo umount "$MOUNT_POINT"
