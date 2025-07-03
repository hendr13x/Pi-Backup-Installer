#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
PROFILE_SCRIPT="/etc/profile.d/backup-ui.sh"
KIAUH_PROMPT_SCRIPT="/etc/profile.d/kiauh-first-login.sh"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armhf" ;;
  *)
    echo "Unknown architecture: $ARCH"
    exit 1
    ;;
esac
echo "Detected architecture: $ARCH"

# Install dependencies
sudo apt-get update
sudo apt-get install -y git cifs-utils

# Clone or update Pi-Backup-Installer repo
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation at $INSTALL_DIR"
  sudo git -C "$INSTALL_DIR" reset --hard origin/main
  sudo git -C "$INSTALL_DIR" pull
else
  echo "Cloning Pi-Backup-Installer to $INSTALL_DIR"
  sudo git clone https://github.com/hendr13x/Pi-Backup-Installer.git "$INSTALL_DIR"
fi

# Set ownership and permissions
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

# Create necessary directories if missing
sudo mkdir -p "$INSTALL_DIR/backups" "$INSTALL_DIR/config" "$INSTALL_DIR/credentials"

# Create default config if missing
if [ ! -f "$INSTALL_DIR/config/settings.conf" ]; then
  sudo tee "$INSTALL_DIR/config/settings.conf" > /dev/null << EOF
NAS_IP=192.168.1.100
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

# Create default credentials if missing
if [ ! -f "$INSTALL_DIR/credentials/nas_creds" ]; then
  sudo tee "$INSTALL_DIR/credentials/nas_creds" > /dev/null << EOF
username=admin
password=YourPasswordHere
EOF
fi

sudo chmod 600 "$INSTALL_DIR/credentials/nas_creds"

# Add sudoers rule for backup script
sudo bash -c "echo '%sudo ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh' > /etc/sudoers.d/sdcard-backup"
sudo chmod 440 /etc/sudoers.d/sdcard-backup

# Install profile script to launch backup UI for all users
sudo tee "$PROFILE_SCRIPT" > /dev/null << EOF
#!/bin/bash
if [[ -n "\$SSH_TTY" && -t 0 && -x "$INSTALL_DIR/main.sh" ]]; then
  "$INSTALL_DIR/main.sh"
fi
EOF
sudo chmod +x "$PROFILE_SCRIPT"

# Create Kiauh first-login prompt for each user
sudo tee "$KIAUH_PROMPT_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
if [[ -n "$SSH_TTY" && -t 0 ]]; then
  if [[ ! -d "$HOME/kiauh" && ! -f "$HOME/.kiauh_prompted" ]]; then
    echo
    read -rp "Kiauh (Klipper Installation And Update Helper) is not installed. Install now? (y/n): " install_kiauh
    if [[ "$install_kiauh" =~ ^[Yy]$ ]]; then
      git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh" && echo "Kiauh installed successfully."
    else
      echo "Skipping Kiauh installation."
    fi
    touch "$HOME/.kiauh_prompted"
  fi
fi
EOF
sudo chmod +x "$KIAUH_PROMPT_SCRIPT"

echo "✅ Installation complete."
echo "Reboot or reconnect via SSH as any user to see the backup menu."
echo "Each user will be prompted once to install Kiauh on their first login."
