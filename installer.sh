#!/bin/bash

set -e

REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"
INSTALL_DIR="/opt/Pi-Backup-Installer"
PROFILE_SCRIPT="/etc/profile.d/backup-ui.sh"
SUDOERS_FILE="/etc/sudoers.d/backup-nopasswd"
BACKUP_GROUP="backup"

echo "🔄 Installing Pi-Backup-Installer..."

# 1) Create backup group if it doesn't exist
if ! getent group "$BACKUP_GROUP" >/dev/null; then
  echo "👥 Creating group '$BACKUP_GROUP'..."
  groupadd "$BACKUP_GROUP"
else
  echo "👥 Group '$BACKUP_GROUP' already exists."
fi

# 2) Add all regular users to the backup group (optional: customize user list here)
echo "👤 Adding users to '$BACKUP_GROUP' group..."
for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
  usermod -aG "$BACKUP_GROUP" "$user" && echo "  Added $user"
done

# 3) Create sudoers file for passwordless mount, umount, dd for backup group
echo "🔐 Configuring sudoers for '$BACKUP_GROUP' group..."
cat << EOF > "$SUDOERS_FILE"
# Allow users in '$BACKUP_GROUP' group to run mount, umount, and dd without password
%$BACKUP_GROUP ALL=(ALL) NOPASSWD: /bin/mount, /bin/umount, /bin/dd
EOF
chmod 440 "$SUDOERS_FILE"

# 4) Clone or update the repository
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "📁 Repo exists. Pulling latest changes..."
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" reset --hard origin/main
else
  echo "📥 Cloning from GitHub..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 5) Make sure required scripts exist
REQUIRED_SCRIPTS=(main.sh backup_menu.sh configure_backup.sh backup.sh)
for script in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "$INSTALL_DIR/$script" ]; then
    echo "❌ Missing script: $script"
    exit 1
  fi
done

# 6) Set proper permissions
echo "🔐 Setting permissions..."
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR/credentials/nas_creds" 2>/dev/null || true

# 7) Create config and credentials directories if missing
mkdir -p "$INSTALL_DIR/config" "$INSTALL_DIR/credentials"

# 8) Create default config if missing
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

# 9) Create default NAS credentials file
CREDENTIALS_FILE="$INSTALL_DIR/credentials/nas_creds"
if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  cat << EOF > "$CREDENTIALS_FILE"
username=admin
password=YourPasswordHere
EOF
  chmod 600 "$CREDENTIALS_FILE"
fi

# 10) Set up login UI for all users
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
echo "ℹ️ Users added to '$BACKUP_GROUP' group can run backup commands without sudo password."
