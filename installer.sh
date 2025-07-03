#!/bin/bash

# Use $HOME for current user
INSTALL_DIR="$HOME/Pi-Backup-Installer"

# Detect Architecture (unchanged)
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armhf" ;;
  *) echo "Unknown architecture: $ARCH"; exit 1 ;;
esac
echo "Detected architecture: $ARCH"

# Install dependencies (sudo needed)
sudo apt-get update
sudo apt-get install git cifs-utils -y

# Clone or pull the repo in user home (idempotent)
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation at $INSTALL_DIR"
  git -C "$INSTALL_DIR" pull
else
  echo "Cloning Pi-Backup-Installer into $INSTALL_DIR"
  git clone https://github.com/hendr13x/Pi-Backup-Installer.git "$INSTALL_DIR"
fi

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

chmod 600 "$INSTALL_DIR/credentials/nas_creds"

# Ask for Kiauh install
read -rp "Install Kiauh? (y/n): " install_kiauh
if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
  git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"
fi

# Make scripts executable
chmod +x "$INSTALL_DIR"/*.sh

# Add passwordless sudo rule for backup script (for current user)
echo "$(whoami) ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh" | sudo tee /etc/sudoers.d/sdcard-backup > /dev/null
sudo chmod 0440 /etc/sudoers.d/sdcard-backup

# Setup global login script to run UI dynamically for any user
sudo tee /etc/profile.d/backup-ui.sh > /dev/null << 'EOF'
#!/bin/bash
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" ]]; then
  INSTALL_DIR="$HOME/Pi-Backup-Installer"
  if [ -x "$INSTALL_DIR/main.sh" ]; then
    "$INSTALL_DIR/main.sh"
  else
    echo "⚠️ Backup UI script not found at $INSTALL_DIR/main.sh"
    echo "Dropping to terminal..."
  fi
fi
EOF

sudo chmod +x /etc/profile.d/backup-ui.sh

echo "✅ Installation complete for user $(whoami). Reconnect via SSH to see the menu."
