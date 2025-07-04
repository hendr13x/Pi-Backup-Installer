#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDS_FILE="$INSTALL_DIR/credentials/nas_creds"
MOUNT_POINT="/mnt/backup_nas"

mkdir -p "$MOUNT_POINT"

# Load NAS config values
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if ! mount -t cifs "//${NAS_IP}/${NAS_SHARE}" "$MOUNT_POINT" -o credentials="$CREDS_FILE",vers=3.0 2>/dev/null; then
    echo -e "\n[WARNING] Could not connect to NAS at //${NAS_IP}/${NAS_SHARE}. Backup UI will still load.\n"
  fi
else
  echo -e "\n[WARNING] Missing NAS config. Skipping NAS mount attempt.\n"
fi

# Add backup-ui autostart to .bashrc with session guard
if ! grep -q "## backup-ui-start" "$HOME/.bashrc"; then
cat << 'EOF' >> "$HOME/.bashrc"

## backup-ui-start
if [[ -n "$SSH_TTY" && -z "$BACKUP_UI_SHOWN" ]]; then
  export BACKUP_UI_SHOWN=1
  if [[ -f /opt/Pi-Backup-Installer/main.sh ]]; then
    /opt/Pi-Backup-Installer/main.sh
  else
    echo "⚠️  Warning: Pi Backup UI not found at /opt/Pi-Backup-Installer/main.sh"
  fi
  exit
fi
## backup-ui-end
EOF
fi

# Ensure required directories exist
sudo mkdir -p "$INSTALL_DIR/config"
sudo mkdir -p "$INSTALL_DIR/credentials"

# Create default settings.conf if missing
if [[ ! -f "$INSTALL_DIR/config/settings.conf" ]]; then
  sudo tee "$INSTALL_DIR/config/settings.conf" > /dev/null << EOF
NAS_IP=192.168.1.100
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

# Create default nas_creds if missing
if [[ ! -f "$INSTALL_DIR/credentials/nas_creds" ]]; then
  sudo tee "$INSTALL_DIR/credentials/nas_creds" > /dev/null << EOF
username=admin
password=YourPasswordHere
EOF
fi

# Set secure permissions on credentials
sudo chmod 600 "$INSTALL_DIR/credentials/nas_creds"

# Install dependencies
sudo apt-get update

# Clone Pi-Backup-Installer if not already present
if [[ ! -f "$INSTALL_DIR/main.sh" ]]; then
  echo "Cloning Pi-Backup-Installer source files into $INSTALL_DIR..."
  sudo git clone https://github.com/hendr13x/Pi-Backup-Installer.git "$INSTALL_DIR"
else
  echo "Pi-Backup-Installer already exists at $INSTALL_DIR"
fi
sudo apt-get install git cifs-utils -y

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

# Set permissions
sudo chmod +x "$INSTALL_DIR"/*.sh

# Add passwordless sudo rule
if sudo -n true 2>/dev/null; then
  echo "$(whoami) ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh" | sudo tee /etc/sudoers.d/sdcard-backup > /dev/null
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
