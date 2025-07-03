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

# Ensure all required directories
mkdir -p "$INSTALL_DIR/config" "$INSTALL_DIR/credentials"

# Make sure key scripts exist
REQUIRED_SCRIPTS=(main.sh backup_menu.sh configure_backup.sh)
for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "$INSTALL_DIR/$script" ]; then
    echo "❌ Missing script: $script"
    exit 1
  fi
done

# Deploy backup.sh if missing
BACKUP_SCRIPT="$INSTALL_DIR/backup.sh"
if [[ ! -f "$BACKUP_SCRIPT" ]]; then
  echo "⚙️  Creating backup.sh..."
  cat << 'EOF' > "$BACKUP_SCRIPT"
#!/bin/bash
# backup.sh - Manual Backup Script

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"

# Load config
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "⚠️ Configuration file not found."
  exit 1
fi

# Load credentials
if [ -f "$CREDENTIALS_FILE" ]; then
  source "$CREDENTIALS_FILE"
else
  echo "⚠️ NAS credentials file not found."
  exit 1
fi

BACKUP_DIR="/mnt/backup"
mkdir -p "$BACKUP_DIR"

# Mount NAS share
mount -t cifs -o username="$NAS_USER",password="$NAS_PASS" "//${NAS_IP}/${NAS_SHARE}" "$BACKUP_DIR"
if [ $? -ne 0 ]; then
  echo "❌ Failed to mount NAS share"
  exit 1
fi

# Create backup file (example only, adjust as needed)
BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d%H%M%S).tar.gz"
tar -czf "$BACKUP_FILE" /etc

# Unmount
umount "$BACKUP_DIR"

echo "✅ Backup completed: $BACKUP_FILE"
EOF
fi

# Set permissions
echo "🔐 Setting permissions..."
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR/credentials/nas_creds" 2>/dev/null || true
chmod +x "$INSTALL_DIR/backup.sh"

# Create default config if missing
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "📝 Creating default settings.conf..."
  cat << EOF > "$CONFIG_FILE"
NAS_IP=192.168.0.75
NAS_SHARE=Backups
NAS_USER=admin
MAX_BACKUPS=5
AUTO_BACKUP_ENABLED=no
AUTO_BACKUP_SCHEDULE=daily
EOF
fi

# Create default NAS credentials
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "📝 Creating default NAS credentials..."
  cat << EOF > "$CREDENTIALS_FILE"
NAS_USER=admin
NAS_PASS=YourPasswordHere
EOF
  chmod 600 "$CREDENTIALS_FILE"
fi

# Create login profile script
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
