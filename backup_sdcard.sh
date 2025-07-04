#!/bin/bash

# Re-run as sudo if not root
[[ $EUID -ne 0 ]] && exec sudo "$0" "$@"

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_DIR="/mnt/backup_nas"
mkdir -p "$MOUNT_DIR"
mkdir -p "$INSTALL_DIR/backups"

# Load configuration
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[ERROR] Missing config file at $CONFIG_FILE"
  exit 1
fi
if [[ ! -f "$CREDS_FILE" ]]; then
  echo "[ERROR] Missing credentials file at $CREDS_FILE"
  exit 1
fi

source "$CONFIG_FILE"
source "$CREDS_FILE"

MAX_BACKUPS=${MAX_BACKUPS:-5}
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
IMG_NAME="sd_backup_$TIMESTAMP.img.gz"
LOG_FILE="$INSTALL_DIR/backups/backup_$TIMESTAMP.log"

echo "[INFO] Mounting NAS..." | tee "$LOG_FILE"
if mountpoint -q "$MOUNT_DIR"; then
  echo "[INFO] NAS already mounted at $MOUNT_DIR" | tee -a "$LOG_FILE"
else
  if ! mount -t cifs "//${NAS_IP}/${NAS_SHARE}" "$MOUNT_DIR" -o credentials="$CREDS_FILE",vers=3.0; then
    echo "[ERROR] Mount failed." | tee -a "$LOG_FILE"
    exit 1
  fi
fi

echo "[INFO] Backing up /dev/mmcblk0..." | tee -a "$LOG_FILE"
dd if=/dev/mmcblk0 bs=4M status=progress conv=fsync 2>>"$LOG_FILE" | gzip > "$MOUNT_DIR/$IMG_NAME"

# Rotate old backups
backups=( $(ls -tp "$MOUNT_DIR"/*.img.gz 2>/dev/null | grep -v '/$') )
if (( ${#backups[@]} > MAX_BACKUPS )); then
  for old in "${backups[@]:MAX_BACKUPS}"; do
    echo "[INFO] Deleting old: $old" | tee -a "$LOG_FILE"
    rm -f "$old"
  done
fi

echo "[INFO] Unmounting NAS..." | tee -a "$LOG_FILE"
umount "$MOUNT_DIR"

echo "[DONE] Backup complete: $IMG_NAME" | tee -a "$LOG_FILE"
read -rp "Press Enter to return..."
