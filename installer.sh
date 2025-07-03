#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"

echo "📦 Installing Pi-Backup-Installer to $INSTALL_DIR..."

# Detect Architecture
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armhf" ;;
  *) echo "❌ Unknown architecture: $ARCH"; exit 1 ;;
esac
echo "✅ Detected architecture: $ARCH"

# Install dependencies
sudo apt-get update
sudo apt-get install git cifs-utils -y

# Create install directory and clone repo if needed
if [[ ! -d "$INSTALL_DIR" ]]; then
  sudo git clone https://github.com/hendr13x/Pi-Backup-Installer.git "$INSTALL_DIR"
else
  echo "📁 Repo already exists at $INSTALL_DIR, updating..."
  sudo git -C "$INSTALL_DIR" reset --hard origin/main
  sudo git -C "$INSTALL_DIR" pull
fi

# Create required folders
sudo mkdir -p "$INSTALL_DIR/config" "$INSTALL_DIR/credentials" "$INSTALL_DIR/backups"

# Create default config file if missing
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

# Create default credentials file if missing
if [[ ! -f "$INSTALL_DIR/credentials/nas_creds" ]]; then
  sudo tee "$INSTALL_DIR/credentials/nas_creds" > /dev/null << EOF
username=admin
password=YourPasswordHere
EOF
fi

# Set secure permissions
sudo chmod 600 "$INSTALL_DIR/credentials/nas_creds"
sudo chmod -R 755 "$INSTALL_DIR"
sudo chown -R root:root "$INSTALL_DIR"

# Set script permissions
sudo find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

# Add sudo rule to allow passwordless backup execution
echo "$(whoami) ALL=(ALL) NOPASSWD: $INSTALL_DIR/backup_sdcard.sh" | sudo tee /etc/sudoers.d/sdcard-backup > /dev/null
sudo chmod 0440 /etc/sudoers.d/sdcard-backup

# Setup system-wide login UI (runs for all SSH users)
sudo tee /etc/profile.d/backup-ui.sh > /dev/null << EOF
#!/bin/bash
if [[ -n "\$SSH_TTY" && -z "\$SKIP_BACKUP_UI" ]]; then
  if [ -x "$INSTALL_DIR/main.sh" ]; then
    "$INSTALL_DIR/main.sh"
  else
    echo "⚠️ Backup UI script not found at $INSTALL_DIR/main.sh"
  fi
fi
EOF

sudo chmod +x /etc/profile.d/backup-ui.sh

# Setup per-user Kiauh prompt (only runs on FIRST login)
AUTO_KIAUH_SCRIPT="/etc/profile.d/kiauh-prompt.sh"
sudo tee "$AUTO_KIAUH_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash
if [[ -n "$SSH_TTY" && ! -f "$HOME/.kiauh_installed" ]]; then
  echo
  echo "⚙️  Kiauh (Klipper Installation And Update Helper) is not installed in your user profile."
  read -rp "Would you like to install Kiauh in ~/kiauh? (y/n): " reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    git clone https://github.com/dw-0/kiauh.git "$HOME/kiauh"
    echo "✅ Kiauh installed at ~/kiauh"
  fi
  touch "$HOME/.kiauh_installed"
fi
EOF

sudo chmod +x "$AUTO_KIAUH_SCRIPT"

echo "✅ Global installation complete!"
echo "ℹ️  Reconnect via SSH to launch the Backup UI for each user."
