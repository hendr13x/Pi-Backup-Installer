#!/bin/bash
set -e

INSTALL_DIR="/opt/Pi-Backup-Installer"
REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"
PROFILE_D="/etc/profile.d/backup-ui.sh"

echo "Starting Pi-Backup-Installer setup..."

echo "Installing required packages..."
apt-get update
apt-get install -y git cifs-utils

if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation at $INSTALL_DIR..."
  cd "$INSTALL_DIR"
  git fetch origin
  git reset --hard origin/main
else
  echo "Cloning Pi-Backup-Installer to $INSTALL_DIR..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo "Setting permissions on $INSTALL_DIR..."
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"

echo "Deploying updated main.sh..."
cat > "$INSTALL_DIR/main.sh" << 'EOF'
# Paste the entire main.sh content here exactly as above
EOF

chmod +x "$INSTALL_DIR/main.sh"

echo "Creating login UI launcher at $PROFILE_D..."
cat > "$PROFILE_D" << 'EOP'
#!/bin/bash
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" ]]; then
  if [ -x "/opt/Pi-Backup-Installer/main.sh" ]; then
    exec /opt/Pi-Backup-Installer/main.sh
  else
    echo "⚠️ Backup UI script not found at /opt/Pi-Backup-Installer/main.sh"
  fi
fi
EOP

chmod +x "$PROFILE_D"

echo "Setup complete! Backup UI will appear on SSH login for all users."
echo "Kiauh will be installed individually when users select that option in the UI."

exit 0
