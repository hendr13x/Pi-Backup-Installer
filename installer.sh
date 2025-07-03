#!/bin/bash

REPO_URL="https://github.com/hendr13x/Pi-Backup-Installer.git"
INSTALL_DIR="/opt/Pi-Backup-Installer"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

echo "Installing/updating Pi-Backup-Installer to $INSTALL_DIR..."

# Clone or update the repo
if [ ! -d "$INSTALL_DIR" ]; then
  git clone "$REPO_URL" "$INSTALL_DIR"
else
  cd "$INSTALL_DIR" || exit
  git fetch origin
  git reset --hard origin/main
  git pull
fi

# Deploy fixed backup_menu.sh
cat > "$INSTALL_DIR/backup_menu.sh" << 'EOF'
#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

while true; do
  clear
  echo "SD Card Backup Utility"
  echo "------------------------"
  echo "1) Run Manual Backup Now"
  echo "2) Configure Backup Settings"
  echo "3) Return to Main Menu"
  echo
  read -rp "Select option: " choice

  case "$choice" in
    1)
      bash "$INSTALL_DIR/manual_backup.sh"
      ;;
    2)
      bash "$INSTALL_DIR/configure_backup.sh"
      ;;
    3)
      break
      ;;
    *)
      echo "Invalid option, please try again."
      sleep 1
      ;;
  esac
done
EOF

# Deploy configure_backup.sh
cat > "$INSTALL_DIR/configure_backup.sh" << 'EOF'
#!/bin/bash

INSTALL_DIR="/opt/Pi-Backup-Installer"
CONFIG_FILE="$INSTALL_DIR/config/settings.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Creating default config file at $CONFIG_FILE"
  mkdir -p "$(dirname "$CONFIG_FILE")"
  cat > "$CONFIG_FILE" <<EOC
# Pi Backup Installer Settings
AUTO_BACKUP_ENABLED=no
BACKUP_PATH=/opt/Pi-Backup-Installer/backups
EOC
fi

# Open config in nano (or your preferred editor)
nano "$CONFIG_FILE"
EOF

# Make sure scripts are executable
chmod +x "$INSTALL_DIR/backup_menu.sh" "$INSTALL_DIR/configure_backup.sh"

# Fix ownership and permissions to allow users to execute
chown -R root:root "$INSTALL_DIR"
chmod -R a+rx "$INSTALL_DIR"

echo "Installation complete."
echo "You can now access the Backup UI by SSH login."
