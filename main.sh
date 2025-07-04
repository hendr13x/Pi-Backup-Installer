#!/bin/bash

# Attempt to mount the NAS using stored config and credentials
CONFIG_FILE="/opt/Pi-Backup-Installer/config/settings.conf"
CREDS_FILE="/opt/Pi-Backup-Installer/credentials/nas_creds"
MOUNT_POINT="/mnt/backup_nas"

mkdir -p "$MOUNT_POINT"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if ! mount -t cifs "//${NAS_IP}/${NAS_SHARE}" "$MOUNT_POINT" -o credentials="$CREDS_FILE",vers=3.0; then
        echo -e "\n[WARNING] Could not connect to NAS at //${NAS_IP}/${NAS_SHARE}. Backup UI will still load.\n"
    fi
else
    echo -e "\n[WARNING] Missing NAS config. Skipping NAS mount attempt.\n"
fi

# Proceed to load the backup menu UI regardless of NAS mount success
/opt/Pi-Backup-Installer/backup_menu.sh
