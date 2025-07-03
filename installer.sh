#!/bin/bash

# Pi-Backup-Installer - Full Setup Script
set -e

REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"
INSTALL_DIR="/opt/Pi-Backup-Installer"
PROFILE_SCRIPT="/etc/profile.d/backup-ui.sh"

echo "🔄 Installing Pi-Backup-Installer..."

# Clone or update the repository
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "📁 Repo exists. Pulling latest changes..."
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" reset --hard origin/main
else
  echo "📥 Cloning from GitHub..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Make sure all key scripts exist
REQUIRED_SCRIPTS=(main.sh backup_menu.sh configure_backup.sh)
for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "$INSTALL_DIR/$script" ]; then
    echo "❌ Missing script: $script"
    exit 1
  fi
done

# Set proper permissions
echo "🔐 Setting permissions..."
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR/credentials/nas_creds" 2>/dev/null || true

# Create config and credentials directories if missing
mkdir -p "$INSTALL_DIR/config" "$INSTALL_DIR/credentials"

# Create default config if missing
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  cat << EOF > "$CONFIG_FILE"
NAS_IP=192.168.0.75
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

# Create default NAS credentials file
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  cat << EOF > "$CREDENTIALS_FILE"
username=admin
password=YourPasswordHere
EOF
  chmod 600 "$CREDENTIALS_FILE"
fi

# Set up login UI for all users
echo "🧩 Configuring login UI..."
cat << 'EOF' > "$PROFILE_SCRIPT"
#!/bin/bash
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" ]]; then
  if [ -x "/opt/Pi-Backup-Installer/main.sh" ]; then
    /opt/Pi-Backup-Installer/main.sh
  else
    echo "⚠️ Backup UI script not found at /opt/Pi-Backup-Installer/main.sh"
  fi
fi
EOF

chmod +x "$PROFILE_SCRIPT"

echo "✅ Installation complete!"
echo "👉 Reconnect via SSH or run: /opt/Pi-Backup-Installer/main.sh"
