#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

echo "Installing Pi-Backup-Installer to $INSTALL_DIR..."

# Clone or update the repo
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation..."
  cd "$INSTALL_DIR" || exit
  git fetch origin
  git reset --hard origin/main
  git pull
else
  echo "Cloning repository..."
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Set permissions
chmod -R +rx "$INSTALL_DIR"

# Setup the backup directory
mkdir -p "$INSTALL_DIR/backups"
chmod 755 "$INSTALL_DIR/backups"

# Create /etc/profile.d script for all users
PROFILE_SCRIPT="/etc/profile.d/backup-ui.sh"
echo '#!/bin/bash
if [[ -n "$SSH_TTY" && -z "$SKIP_BACKUP_UI" ]]; then
  if [ -x "/opt/Pi-Backup-Installer/main.sh" ]; then
    "/opt/Pi-Backup-Installer/main.sh"
  else
    echo "⚠️ Backup UI script not found at /opt/Pi-Backup-Installer/main.sh"
  fi
fi' > "$PROFILE_SCRIPT"

chmod +x "$PROFILE_SCRIPT"

echo "Installation complete."
echo "Users will see the backup UI on SSH login."
echo "Kiauh will prompt for installation per user on first login if not installed."

exit 0
