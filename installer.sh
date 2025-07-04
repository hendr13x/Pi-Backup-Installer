#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_POINT="/mnt/backup_nas"
BACKUP_GROUP="backup"

# Ensure the shared group exists
if ! getent group "$BACKUP_GROUP" > /dev/null; then
  sudo groupadd "$BACKUP_GROUP"
fi

mkdir -p "$MOUNT_POINT"

# Add system-wide backup UI autostart
sudo tee /etc/profile.d/pi-backup.sh > /dev/null << 'EOF'
#!/bin/bash
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" && -f /opt/Pi-Backup-Installer/main.sh ]]; then
  /opt/Pi-Backup-Installer/main.sh
fi
EOF

sudo chmod +x /etc/profile.d/pi-backup.sh

# Ensure required directories exist
sudo mkdir -p "$INSTALL_DIR/config"
sudo mkdir -p "$INSTALL_DIR/credentials"
sudo mkdir -p "$INSTALL_DIR/backups"

# Create default settings.conf if missing
if [[ ! -f "$CONFIG_FILE" ]]; then
  sudo tee "$CONFIG_FILE" > /dev/null << EOF
NAS_IP=192.168.1.100
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
BACKUP_BASENAME=sd_backup
EOF
fi

# Create default nas_creds if missing
if [[ ! -f "$CREDS_FILE" ]]; then
  sudo tee "$CREDS_FILE" > /dev/null << EOF
username=admin
password=YourPasswordHere
EOF
fi

# Set group and permissions
sudo chown -R root:"$BACKUP_GROUP" "$INSTALL_DIR"
sudo chmod -R 775 "$INSTALL_DIR"
sudo chmod 664 "$CONFIG_FILE"
sudo chmod 660 "$CREDS_FILE"

# Add current user to group
sudo usermod -aG "$BACKUP_GROUP" "$USER"

# Install dependencies
sudo apt-get update
sudo apt-get install git cifs-utils -y

# Update or clone Pi-Backup-Installer repo
if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "Updating Pi-Backup-Installer from GitHub..."
  sudo git -C "$INSTALL_DIR" reset --hard
  sudo git -C "$INSTALL_DIR" pull
else
  echo "Cloning Pi-Backup-Installer source files into $INSTALL_DIR..."
  sudo rm -rf "$INSTALL_DIR"
  sudo git clone https://github.com/hendr13x/Pi-Backup-Installer.git "$INSTALL_DIR"
fi

# Ask for Kiauh install
read -rp "Install Kiauh? (y/n): " install_kiauh
if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
  if [[ -d "$HOME/kiauh" ]]; then
    echo "⚠️  KIAUH already exists at \$HOME/kiauh. Skipping clone."
  else
    if git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"; then
      echo "✅ KIAUH successfully installed."
    else
      echo "❌ Failed to clone KIAUH. Check your network connection."
    fi
  fi
fi

# Set executable permissions
sudo chmod +x "$INSTALL_DIR"/*.sh

# Add passwordless sudo rule
if sudo -n true 2>/dev/null; then
  echo "$USER ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh" | sudo tee /etc/sudoers.d/sdcard-backup > /dev/null
  sudo chmod 0440 /etc/sudoers.d/sdcard-backup
else
  echo "⚠️  Sudo access is required to install passwordless rules. Skipping."
fi

# Trigger MOTD after install if available
if [[ -x /etc/update-motd.d/30-armbian-sysinfo ]]; then
  /etc/update-motd.d/30-armbian-sysinfo
fi

echo "✅ Installation complete. Reconnect via SSH to see the menu."
exit 0
