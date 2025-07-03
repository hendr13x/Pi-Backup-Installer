#!/bin/bash

# Get the path of this script (absolute)
INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect Architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armhf" ;;
  *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac
echo "Detected architecture: $ARCH"

# Install dependencies
sudo apt-get update
sudo apt-get install git cifs-utils -y

# Create config and credentials directories if missing
mkdir -p "$INSTALL_DIR/config"
mkdir -p "$INSTALL_DIR/credentials"

# If settings.conf missing, create default
if [[ ! -f "$INSTALL_DIR/config/settings.conf" ]]; then
  cat << EOF > "$INSTALL_DIR/config/settings.conf"
NAS_IP=192.168.1.100
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

# If nas_creds missing, create default (empty password)
if [[ ! -f "$INSTALL_DIR/credentials/nas_creds" ]]; then
  cat << EOF > "$INSTALL_DIR/credentials/nas_creds"
username=admin
password=YourPasswordHere
EOF
fi

# Set secure permissions on credentials file automatically
chmod 600 "$INSTALL_DIR/credentials/nas_creds"

# Ask for Kiauh install
read -rp "Install Kiauh? (y/n): " install_kiauh
if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
  git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"
fi

# Set script permissions
chmod +x "$INSTALL_DIR"/*.sh

# Add passwordless sudo rule for backup script
echo "$(whoami) ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh" | sudo tee /etc/sudoers.d/sdcard-backup > /dev/null
sudo chmod 0440 /etc/sudoers.d/sdcard-backup

# Setup SSH login UI
if ! grep -q "## backup-ui-start" "$HOME/.bashrc"; then
cat << EOF >> "$HOME/.bashrc"

## backup-ui-start
if [[ -n "\$SSH_TTY" ]]; then
  $INSTALL_DIR/main.sh
  exit
fi
## backup-ui-end
EOF
fi

echo "✅ Installation complete. Reconnect via SSH to see the menu."
